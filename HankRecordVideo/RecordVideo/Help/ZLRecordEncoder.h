//
//  ZLRecordEncoder.h
//  我要留学
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//  编码类

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZLRecordEncoder : NSObject

/**
    文件写入路径
 */
@property (nonatomic, readonly) NSString *path;

/**
 *  @param path 媒体存发路径
 *  @param cy   视频分辨率的高
 *  @param cx   视频分辨率的宽
 *  @param ch   音频通道
 *  @param rate 音频的采样比率
 */
+ (ZLRecordEncoder*)encoderForPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;
- (instancetype)initPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;

/**
 *  录制完成回到block
 */
- (void)finishWithCompletionHandler:(void (^)(void))handler;

/**
 *  通过这个方法写入数据
 *
 *  @param sampleBuffer 写入的数据
 *  @param isVideo      是否写入的是视频 否为音频
 *
 *  @return 写入是否成功
 */
- (BOOL)encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;
@end
