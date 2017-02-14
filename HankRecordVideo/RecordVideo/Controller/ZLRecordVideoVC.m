//
//  ZLRecordVideoVC.m
//  我要留学
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLRecordVideoVC.h"
#import "ZLRecordTool.h"
#import "ZLRecordEncoder.h"
#import "ZLRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>


typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface ZLRecordVideoVC ()<ZLRecordToolDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton               *btnflashLight;
@property (weak, nonatomic) IBOutlet UIButton               *btnChangeCamera;
@property (weak, nonatomic) IBOutlet UIButton               *btnRecordNext;
@property (weak, nonatomic) IBOutlet UIButton               *btnRecord;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *consTopViewTop;
@property (weak, nonatomic) IBOutlet ZLRecordProgressView   *progressView;

@property (strong, nonatomic) MPMoviePlayerViewController   *playerVC;
@property (strong, nonatomic) ZLRecordTool                  *recordEngine;
@property (assign, nonatomic) BOOL                          allowRecord;//允许录制
@property (assign, nonatomic) UploadVieoStyle               videoStyle;//视频的类型

@end

@implementation ZLRecordVideoVC

- (void)dealloc {
    _recordEngine = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (kIsIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.allowRecord = YES;
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}

#pragma mark - Private Method

- (void)adjustViewFrame {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.btnRecord.selected) {
            self.consTopViewTop.constant = -64;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            self.consTopViewTop.constant = 20;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self recordAction:self.btnRecord];
}

#pragma mark - ZLRecordToolDelegate

- (void)recordProgress:(CGFloat)progress{
    if (progress >= 1) {
        [self recordAction:self.btnRecord];
        self.allowRecord = NO;
    }
    self.progressView.progress = progress;
}

#pragma mark - Action

- (IBAction)dismissAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeCameraAction:(id)sender {
    self.btnChangeCamera.selected = !self.btnChangeCamera.selected;
    if (self.btnChangeCamera.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.btnflashLight.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

//发送点击事件
- (IBAction)recordNextAction:(id)sender {
    if (_recordEngine.videoPath.length > 0) {
        WEAKSELF
        [MBProgressHUD showMessage:@"压缩文件中" toView:self.view];
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            [weakSelf.recordEngine changeMovToMp4:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath] dataBlock:^(UIImage *movieImage) {
                STRONGSELF
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                NSURL *URL = [NSURL fileURLWithPath:strongSelf.recordEngine.videoPath];
                ZLVideoModel *videoModel = [ZLVideoModel modelWithVideoImage:movieImage fileUrl:URL];
                TCallBlock(strongSelf.dataBlock,videoModel);
                [strongSelf.navigationController popViewControllerAnimated:NO];
            }];
        }];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请录制视频" message:@"是否录制视频" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

//闪光灯
- (IBAction)flashLightAction:(id)sender {
    if (self.btnChangeCamera.selected == NO) {
        self.btnflashLight.selected = !self.btnflashLight.selected;
        if (self.btnflashLight.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}

//录制
- (IBAction)recordAction:(UIButton *)sender {
    if (self.allowRecord) {
        self.videoStyle = VideoRecord;
        self.btnRecord.selected = !self.btnRecord.selected;
        if (self.btnRecord.selected) {
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
            }else {
                [self.recordEngine startCapture];
            }
        }else {
            [self.recordEngine pauseCapture];
        }
        [self adjustViewFrame];
    }
}

#pragma mark - Setter Getter

- (ZLRecordTool *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[ZLRecordTool alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}


@end
