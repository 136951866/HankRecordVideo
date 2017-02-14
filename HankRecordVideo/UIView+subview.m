//
//  UIView+subview.m
//  我要留学
//
//  Created by 深圳市智联天下国际教育有限公司 on 16/9/27.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "UIView+subview.h"

@implementation UIView (subview)
#pragma mark - For subView

-(UIView *)subViewOfClass:(Class)aClass{
    UIView *aView = nil;
    NSMutableArray *views = [self.subviews mutableCopy];
    while (!aView && views.count>0) {
        UIView *temp = [views firstObject];
        if ([temp isKindOfClass:aClass]) {
            aView = temp;
        }else{
            [views addObjectsFromArray:temp.subviews];
            [views removeObject:temp];
        }
    }
    return aView;
}

-(UIView *)subViewOfContainDescription:(NSString *)aString{
    if(![aString isKindOfClass:[NSString class]]){
        NSLog(@"%s,%d,aString is Not String", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    UIView *aView = nil;
    NSMutableArray *views = [self.subviews mutableCopy];
    while (!aView && views.count>0) {
        UIView *temp = [views firstObject];
        if ([temp.description rangeOfString:aString].length>0) {
            aView = temp;
        }else{
            [views addObjectsFromArray:temp.subviews];
            [views removeObject:temp];
        }
    }
    return aView;
}
@end
