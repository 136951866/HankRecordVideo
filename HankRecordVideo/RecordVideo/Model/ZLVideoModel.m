//
//  ZLVideoModel.m
//  我要留学
//
//  Created by Hank on 2016/12/21.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLVideoModel.h"

@implementation ZLVideoModel

+ (instancetype)modelWithVideoImage:(UIImage *)videoImage fileUrl:(NSURL *)fileUrl{
    ZLVideoModel *model = [[ZLVideoModel alloc]init];
    model.videoImage = videoImage;
    model.fileUrl = fileUrl;
    return model;
}

- (void)setVideoData:(NSData *)videoData{
    _videoData = videoData;
    CGFloat totalSize = (float)videoData.length / 1024 / 1024;
    _size = [NSString stringWithFormat:@"%fMb",totalSize];
}

- (void)setFileUrl:(NSURL *)fileUrl{
    _fileUrl = fileUrl;
    self.videoData = [NSData dataWithContentsOfURL:_fileUrl];
}

@end
