//
//  Macros.h
//  HankRecordVideo
//
//  Created by Hank on 2017/2/14.
//  Copyright © 2017年 Hank. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define kCurrentWindow [[UIApplication sharedApplication].windows firstObject]

#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT   ([[UIScreen mainScreen] bounds].size.height)

#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

#pragma mark - BLOCK

typedef void (^BasicBlock)(void);
typedef void (^BOOLBlock)(BOOL);
typedef void (^IndexBlock)(NSInteger index);
typedef void (^TextBlock)(NSString *str);
typedef void (^ObjBlock)(id object);
typedef void (^FloatBlock)(CGFloat num);
typedef bool (^ReturnBlock)(void);
typedef void (^DictionaryBlock)(NSDictionary *dic);
typedef void (^ArrBlock)(NSArray *);
typedef void (^MutableArrBlock)(NSMutableArray *arr);
typedef void (^ViewBlock)(UIView *view);
typedef void (^BtnBlock)(UIButton *btn);
typedef void (^LblBlock)(UILabel *lable);
typedef void (^dataBlock)(NSData *data);
typedef void (^imgBlock)(UIImage *img);
typedef id (^ReturnObjectWithOtherObjectBlock)(id);
typedef UIImage *(^ReturnImgWithImgBlock)(UIImage *);

#define TCallBlock(block, ...) if(block) block(__VA_ARGS__)

#pragma mark - Color
//色值
#define kGuideYellow [UIColor colorWithHexString:@"ffd800"]
#define kLightBlue [UIColor colorWithHexString:@"3498db"]
#define kOfferBlack [UIColor colorWithHexString:@"0f0f0f"]
#define kNoteGray [UIColor colorWithHexString:@"aaaaaa"]
#define kLightGray [UIColor colorWithHexString:@"f0f0f0"]

#pragma mark - Scale

NS_INLINE CGFloat kFrameScaleX(){
    static CGFloat frameScaleX = 1.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frameScaleX = SCREEN_WIDTH/375.0;
    });
    return frameScaleX;
}

NS_INLINE CGFloat kFrameScaleY(){
    static CGFloat frameScaleY = 1.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frameScaleY = SCREEN_HEIGHT/667.0;
    });
    return frameScaleY;
}
//系统版本
NS_INLINE CGFloat device_version(){
    return [[[UIDevice currentDevice] systemVersion] doubleValue];
}

//是否ios7以上系统
#define kIsIOS7 (device_version() >=7.0)
//是否ios8以上系统
#define kIsIOS8 (device_version() >=8.0)
//ios7以上视图中包含状态栏预留的高度
#define kHeightInViewForStatus (kIsIOS7?20:0)
//状态条占的高度
#define kHeightForStatus (kIsIOS7?0:20)
//导航栏高度
#define kNavBarHeight (kIsIOS7?64:44)
#endif /* Macros_h */
