//
//  ZLAlertView.h
//  HankRecordVideo
//
//  Created by Hank on 2016/12/21.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLAlertView : NSObject

@property(nonatomic,copy)       NSString    *title;
@property(nonatomic,copy)       NSString    *message;
@property(nonatomic,readonly)   NSInteger   numberOfButtons;

// create an alert view
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

// add buttons
- (void)addButtonWithTitle:(NSString *)title block:(BasicBlock)block;
- (void)addButtonWithTitle:(NSString *)title;
- (void)show;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

// perform common delegate tasks
- (void)setWillDismissBlock:(BasicBlock)block;
- (void)setDidDismissBlock:(BasicBlock)block;
- (void)setWillPresentBlock:(BasicBlock)block;
- (void)setDidPresentBlock:(BasicBlock)block;

@end
