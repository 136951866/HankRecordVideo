//
//  ZLPublicTool.h
//  HankRecordVideo
//
//  Created by Hank on 9/28/16.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <Foundation/Foundation.h>

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
