//
//  UIView+subview.h
//  我要留学
//
//  Created by 深圳市智联天下国际教育有限公司 on 16/9/27.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (subview)
#pragma mark - For subView

-(UIView *)subViewOfClass:(Class)aClass;

-(UIView *)subViewOfContainDescription:(NSString *)aString;
@end
