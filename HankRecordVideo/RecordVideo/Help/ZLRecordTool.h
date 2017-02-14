//
//  ZLRecordTool.h
//  我要留学
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//  录制工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@protocol ZLRecordToolDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end

@interface ZLRecordTool : NSObject

#pragma mark -
/**
    正在录制
 */
@property (atomic, assign, readonly) BOOL isCapturing;

/**
    是否暂停
 */
@property (atomic, assign, readonly) BOOL isPaused;

/**
    当前录制时间
 */
@property (atomic, assign, readonly) CGFloat currentRecordTime;

/**
    录制最长时间 默认0x3cs
 */
@property (atomic, assign) CGFloat maxRecordTime;

/**
    delegate
 */
@property (weak, nonatomic) id<ZLRecordToolDelegate>delegate;

/**
    视频路径
 */
@property (atomic, strong) NSString *videoPath;

#pragma mark -


/**
 捕获到的视频

 @return 视频呈现的layer
 */
- (AVCaptureVideoPreviewLayer *)previewLayer;

/**
    启动录制功能
 */
- (void)startUp;

/**
    关闭录制功能
 */
- (void)shutdown;

/**
    开始录制
 */
- (void) startCapture;

/**
    暂停录制
 */
- (void) pauseCapture;

/**
    停止录制
 */
- (void) stopCaptureHandler:(void (^)(UIImage *movieImage))handler;

/**
    继续录制
 */
- (void) resumeCapture;

/**
    开启闪光灯
 */
- (void)openFlashLight;

/**
    关闭闪光灯
 */
- (void)closeFlashLight;

/**
    切换前后置摄像头
 @param isFront 是否为前置摄像头
 */
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;

/**
 将mov的视频转成mp4

 @param mediaURL 视频文件的url
 @param handler 返回的image
 */
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;

@end
