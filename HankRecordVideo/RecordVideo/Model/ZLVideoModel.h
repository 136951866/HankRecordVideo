//
//  ZLVideoModel.h
//  HankRecordVideo
//
//  Created by Hank on 2016/12/21.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZLVideoModel : NSObject

/**
    视频的data
 */
@property (nonatomic, strong)NSData *videoData;

/**
    视频的第一帧图片
 */
@property (nonatomic, strong)UIImage *videoImage;

/**
    视频的大小
 */
@property (nonatomic, strong)NSString *size;

/**
    视频的URL
 */
@property (nonatomic, strong)NSURL *fileUrl;

+ (instancetype)modelWithVideoImage:(UIImage *)videoImage fileUrl:(NSURL *)fileUrl;

@end
