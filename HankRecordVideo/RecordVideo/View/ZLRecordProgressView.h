//
//  ZLRecordProgressView.h
//  HankRecordVideo
//
//  Created by Hank on 2016/12/16.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLRecordProgressView : UIView

/**
    当前进度
 */
@property (assign, nonatomic) IBInspectable CGFloat progress;

/**
    进度条背景颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *progressBgColor;

/**
    进度条颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *progressColor;

/**
    加载好的进度
 */
@property (assign, nonatomic) CGFloat loadProgress;

/**
    已经加载好的进度颜色
 */
@property (strong, nonatomic) UIColor *loadProgressColor;

@end
