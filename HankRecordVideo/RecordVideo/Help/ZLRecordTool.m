//
//  ZLRecordTool.m
//  我要留学
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLRecordTool.h"
#import "ZLRecordEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ZLRecordVideoPublicTool.h"

@interface ZLRecordTool ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate> {
    CMTime _timeOffset;
    CMTime _lastVideo;
    CMTime _lastAudio;
    
    NSInteger _cx;
    NSInteger _cy;
    int _channels;
    Float64 _samplerate;
}

@property (strong, nonatomic) ZLRecordEncoder            *recordEncoder;
@property (strong, nonatomic) AVCaptureSession           *recordSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;
@property (strong, nonatomic) AVCaptureDeviceInput       *audioMicInput;
@property (copy  , nonatomic) dispatch_queue_t           captureQueue;
@property (strong, nonatomic) AVCaptureConnection        *audioConnection;
@property (strong, nonatomic) AVCaptureConnection        *videoConnection;
@property (strong, nonatomic) AVCaptureVideoDataOutput   *videoOutput;
@property (strong, nonatomic) AVCaptureAudioDataOutput   *audioOutput;
@property (atomic, assign) BOOL isCapturing;
@property (atomic, assign) BOOL isPaused;
@property (atomic, assign) BOOL discont;
@property (atomic, assign) CMTime startTime;
@property (atomic, assign) CGFloat currentRecordTime;

@end

@implementation ZLRecordTool

- (void)dealloc {
    [_recordSession stopRunning];
    _captureQueue     = nil;
    _recordSession    = nil;
    _previewLayer     = nil;
    _backCameraInput  = nil;
    _frontCameraInput = nil;
    _audioOutput      = nil;
    _videoOutput      = nil;
    _audioConnection  = nil;
    _videoConnection  = nil;
    _recordEncoder    = nil;
}

- (instancetype)init{
    if (self = [super init]) {
        self.maxRecordTime = 30;
    }
    return self;
}

#pragma mark -  Public Method

- (void)startUp {
    NSLog(@"启动录制功能");
    self.startTime = CMTimeMake(0, 0);
    self.isCapturing = NO;
    self.isPaused = NO;
    self.discont = NO;
    [self.recordSession startRunning];
}

//关闭录制功能
- (void)shutdown {
    _startTime = CMTimeMake(0, 0);
    if (_recordSession) {
        [_recordSession stopRunning];
    }
    [_recordEncoder finishWithCompletionHandler:^{
        NSLog(@"录制完成");
    }];
}

- (void)finishWithCompletionHandler {
    _startTime = CMTimeMake(0, 0);
    if (_recordSession) {
        [_recordSession stopRunning];
    }
    [_recordEncoder finishWithCompletionHandler:^{
                NSLog(@"关闭录制功能");
    }];
}

- (void)startCapture {
    @synchronized(self) {
        if (!self.isCapturing) {
            NSLog(@"开始录制");
            self.recordEncoder = nil;
            self.isPaused = NO;
            self.discont = NO;
            _timeOffset = CMTimeMake(0, 0);
            self.isCapturing = YES;
        }
    }
}

- (void)pauseCapture {
    @synchronized(self) {
        if (self.isCapturing) {
            NSLog(@"暂停录制");
            self.isPaused = YES;
            self.discont = YES;
        }
    }
}

- (void)resumeCapture {
    @synchronized(self) {
        if (self.isPaused) {
            NSLog(@"继续录制");
            self.isPaused = NO;
        }
    }
}

- (void)stopCaptureHandler:(void (^)(UIImage *movieImage))handler {
    @synchronized(self) {
        if (self.isCapturing) {
            NSLog(@"停止录制");
            NSString* path = self.recordEncoder.path;
            NSURL* url = [NSURL fileURLWithPath:path];
            self.isCapturing = NO;
            dispatch_async(_captureQueue, ^{
                [self.recordEncoder finishWithCompletionHandler:^{
                    //录制完成
                    self.isCapturing = NO;
                    self.recordEncoder = nil;
                    self.startTime = CMTimeMake(0, 0);
                    self.currentRecordTime = 0;
                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                        });
                    }
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        NSLog(@"保存成功");
                    }];
                    [ZLRecordVideoPublicTool movieToImageWithPath:self.videoPath Handler:handler];
                }];
            });
        }
    }
}


//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}

//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}

- (void)changeCameraInputDeviceisFront:(BOOL)isFront {
    if (isFront) {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.frontCameraInput];
        }
    }else {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.backCameraInput];
        }
    }
}

- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler {
    AVAsset *video = [AVAsset assetWithURL:mediaURL];
    
    /*
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video.duration)
                        ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, video.duration);
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:video.duration];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);

    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
     */
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPresetMediumQuality];
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition
//                                                                      presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.videoComposition = mainCompositionInst;
    self.videoPath = [kFilePathForVideo() stringByAppendingPathComponent:[self getUploadFile_type:@"video" fileType:@"mp4"]];
    exportSession.outputURL = [NSURL fileURLWithPath:self.videoPath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        [ZLRecordVideoPublicTool movieToImageWithPath:self.videoPath Handler:handler];
    }];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size{
    CATextLayer *layerText = [[CATextLayer alloc] init];
    [layerText setFont:@"Helvetica-Bold"];
    [layerText setFontSize:36];
    [layerText setFrame:CGRectMake(0, 0, size.width, 100)];
    [layerText setAlignmentMode:kCAAlignmentCenter];
    [layerText setForegroundColor:[[UIColor whiteColor] CGColor]];
    layerText.string = @"来自我要留学APP";
    
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:layerText];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


#pragma  mark - Private Method

- (NSString *)getUploadFile_type:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString *timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}


- (void)changeCameraAnimation{
    CATransition *changeAnimation = [CATransition animation];
    changeAnimation.delegate = self;
    changeAnimation.duration = 0.45;
    changeAnimation.type = @"oglFlip";
    changeAnimation.subtype = kCATransitionFromRight;
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:changeAnimation forKey:@"hank Create"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)animation{
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.recordSession startRunning];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

//写数据
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES; //是否是当前video输出
    @synchronized(self) {
        if (!self.isCapturing  || self.isPaused) {
            return;
        }
        if (captureOutput != self.videoOutput) {
            isVideo = NO;
        }
        if ((self.recordEncoder == nil) && !isVideo) {
            //设置编码器
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            //音频
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
            _samplerate = asbd->mSampleRate;
            _channels = asbd->mChannelsPerFrame;
            //视频
            NSString *videoName = [self getUploadFile_type:@"video" fileType:@"mp4"];
            self.videoPath = [kFilePathForVideo() stringByAppendingPathComponent:videoName];
            self.recordEncoder = [ZLRecordEncoder encoderForPath:self.videoPath Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
        if (self.discont) {
            //暂停
            if (isVideo) {
                return;
            }
            self.discont = NO;
            // 计算暂停的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = isVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (_timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                if (_timeOffset.value == 0) {
                    _timeOffset = offset;
                }else {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整 去掉暂停的部分
            sampleBuffer = [ZLRecordVideoPublicTool adjustTime:sampleBuffer by:_timeOffset];
        }
        // 记录暂停上一次录制的时间
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            _lastVideo = pts;
        }else {
            _lastAudio = pts;
        }
    }
    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.startTime.value == 0) {
        self.startTime = dur;
    }
    CMTime sub = CMTimeSubtract(dur, self.startTime);
    self.currentRecordTime = CMTimeGetSeconds(sub);
    if (self.currentRecordTime > self.maxRecordTime) {
        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                });
            }
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        });
    }
    // 进行数据编码
    [self.recordEncoder encodeFrame:sampleBuffer isVideo:isVideo];
    CFRelease(sampleBuffer);
}

#pragma mark - Setter Getter

- (AVCaptureSession *)recordSession {
    if (!_recordSession) {
        _recordSession = [[AVCaptureSession alloc] init];
        _recordSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        //添加后置摄像头的输出 后置麦克风的输出 视频输出 音频输出 视频录制的方向
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
            //的分辨率
            _cx = 480;
            _cy = 640;
        }
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }

        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _recordSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"error backCameraInput");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"error frontCameraInput");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"error audioMicInput");
        }
    }
    return _audioMicInput;
}

//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    return _videoConnection;
}

//音频连接
- (AVCaptureConnection *)audioConnection {
    if (_audioConnection == nil) {
        _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("hank create", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}


#pragma mark - About Video

//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

@end
