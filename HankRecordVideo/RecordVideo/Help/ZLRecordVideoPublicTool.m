//
//  ZLRecordVideoPublicTool.m
//  HankRecordVideo
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016 Hank. All rights reserved.
//

#import "ZLRecordVideoPublicTool.h"
#import "UIImage+scale.h"

@implementation ZLRecordVideoPublicTool

+ (void)movieToImageWithPath:(NSString *)path  Handler:(void (^)(UIImage *movieImage))handler{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 600);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
    [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

+ (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

+ (UIImage *)getThumbnailImage:(NSURL *)videoURL{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newImageName=[self getImagePath:[videoURL path]];//imageName为图片名称
    if(![fileManager fileExistsAtPath:newImageName]){
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        NSData *imageData = UIImageJPEGRepresentation(thumb, 1.0f);//currentImage是传过来的UIImage
        BOOL operation = [imageData writeToFile:newImageName options:NSAtomicWrite error:nil];
        if(!operation){
            NSLog(@"保存失败");
        }
        CGImageRelease(image);
        return thumb;
    }else{
        return [UIImage imageWithContentsOfFile:newImageName];
    }
}

+ (NSString*)getImagePath:(NSString *)name{
    NSArray *path =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finalPath = [docPath stringByAppendingPathComponent:name];
    [fileManager createDirectoryAtPath:[finalPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    return finalPath;
}

+ (BOOL)deleteVideoFileWithUrl:(NSURL *)url{
    return YES;
}



@end
