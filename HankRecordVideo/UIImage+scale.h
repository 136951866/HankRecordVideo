//
//  UIImage+UIImage_scale.h
//  FTCoreText
//
//  Created by 缪 大彪 on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  图片缩小等处理

#import <UIKit/UIKit.h>


#define kDefaultImgQuality 0.5

@interface UIImage (scale)
-(UIImage *)getSubImage:(CGRect)rect;
//等比例缩放
-(UIImage *)scaleToSize:(CGSize)size;
/**
 *  非等比例压缩
 *
 *  @param size 压缩后图片尺寸
 *
 *  @return 压缩后的图片
 */
-(UIImage *)unProportionScaleToSize:(CGSize)size;

-(UIImage *)scaleToFit;

-(UIImage *)resizedInRect:(CGRect)thumbRect;
@end
