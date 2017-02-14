//
//  ZLRecordVideoPublicTool.h
//  我要留学
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_INLINE NSString *kFilePathForVideo(){
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}

@interface ZLRecordVideoPublicTool : NSObject


/**
 获取第一帧图片

 @param path 视频地址
 @param handler 返回图片的block
 */
+ (void)movieToImageWithPath:(NSString *)path  Handler:(void (^)(UIImage *movieImage))handler;


/**
 调整媒体数据的时间

 @param sample 媒体数据
 @param offset 偏移的时间
 @return 偏移的媒体数据
 */
+ (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset;

/**
 获取视频第一帧

 @param videoURL 视频url
 @return image
 */
+ (UIImage *)getThumbnailImage:(NSURL *)videoURL;

/**
 删除视频文件

 @param url 视频url
 @return 是否删除成功
 */
+ (BOOL)deleteVideoFileWithUrl:(NSURL *)url;
@end
