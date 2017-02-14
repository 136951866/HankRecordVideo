//
//  ZLPublicTool.h
//  我要留学
//
//  Created by Hank on 9/28/16.
//  Copyright © 2016 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZLLastTime @"ZLLastTime"
#define ZLAppVersion @"100"

#define ZLMustImplementedDataInitMethod() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"不能用init初始化"] \
userInfo:nil]

#define  ZLMustImplementedDataInit() - (instancetype)init{ \
    ZLMustImplementedDataInitMethod(); \
}

@interface ZLPublicTool : NSObject

/**
 *  模态相关
 */
+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
+ (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;



@end
