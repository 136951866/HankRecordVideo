//
//  ZLPublicTool.m
//  我要留学
//
//  Created by Hank on 9/28/16.
//  Copyright © 2016 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLPublicTool.h"


@implementation ZLPublicTool

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewControllerToPresent];
    UIViewController *rootVc  = [kCurrentWindow rootViewController];
    while (rootVc.presentedViewController) {
        rootVc = rootVc.presentedViewController;
    }
    [rootVc presentViewController:nav animated:flag completion:completion];
}

+ (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion{
    UIViewController *rootVc = [kCurrentWindow rootViewController];
    while (rootVc.presentedViewController) {
        rootVc = rootVc.presentedViewController;
    }
    [rootVc dismissViewControllerAnimated:flag completion:completion];
}



@end
