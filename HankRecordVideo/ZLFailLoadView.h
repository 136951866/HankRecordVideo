//
//  ZLFailLoadView.h
//  HankRecordVideo
//
//  Created by Hank on 10/13/16.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLFailLoadView;

#define kDefaultNodataPrompt @"未能找到你想要的结果";
typedef void (^editFailLoadVIewBlock)(ZLFailLoadView *);

@interface ZLFailLoadView : UIView


@property (nonatomic,strong) UIView *viewOfContentNoData;
@property (nonatomic,strong) UIImageView *imgvOfNoData;
@property (nonatomic,strong) UILabel *lblOfNodata;

+ (void)showInView:(UIView *)aView refreshBlock:(BasicBlock)block editHandle:(editFailLoadVIewBlock)aBlock;

+ (void)showInView:(UIView *)aView response:(id)response allData:(NSArray *)arrData refreshBlock:(BasicBlock)blockRefresh editHandle:(editFailLoadVIewBlock)blockEdit;

+ (void)removeFromView:(UIView *)aView;

@end
