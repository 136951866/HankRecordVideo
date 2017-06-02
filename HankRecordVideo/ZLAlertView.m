//
//  ZLAlertView.m
//  HankRecordVideo
//
//  Created by Hank on 2016/12/21.
//  Copyright © 2016 Hank. All rights reserved.
//

#import "ZLAlertView.h"
#import <objc/runtime.h>

static NSString *GCAlertViewWillPresentKey = @"GCAlertViewWillPresentAction";
static NSString *GCAlertViewDidPresentKey = @"GCAlertViewDidPresentAction";
static NSString *GCAlertViewWillDismissKey = @"GCAlertViewWillDismissAction";
static NSString *GCAlertViewDidDismissKey = @"GCAlertViewDidDismissAction";


@interface ZLAlertController : UIAlertController
@property (nonatomic, copy) BasicBlock blockWillPresent;
@property (nonatomic, copy) BasicBlock blockDidPresent;
@property (nonatomic, copy) BasicBlock blockWillDismiss;
@property (nonatomic, copy) BasicBlock blockDidDismiss;

@end

@implementation ZLAlertController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _blockWillPresent ? _blockWillPresent() : NULL;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _blockDidPresent ? _blockDidPresent() : NULL;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _blockWillDismiss ? _blockWillDismiss() : NULL;
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    objc_removeAssociatedObjects(self);
    _blockDidDismiss ? _blockDidDismiss() : NULL;
}

@end

@interface ZLAlertView () {
    NSMutableDictionary *_arrActions;
    UIAlertView *_alertView;
    ZLAlertController *_alertController;
    BOOL _hasRootVC;
}

@end

@implementation ZLAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super init];
    if (self) {
        UIViewController *rootVc  = [kCurrentWindow rootViewController];
        while (rootVc.presentedViewController) {
            rootVc = rootVc.presentedViewController;
        }
        if (rootVc) {
            _hasRootVC = YES;
        }
        if ([self CanShowAlertController]) {
            _alertController = [ZLAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            objc_setAssociatedObject(_alertController, "TDelegate", self, OBJC_ASSOCIATION_RETAIN);  //防止self被提前释放
        } else {
            _arrActions = [NSMutableDictionary dictionary];
            _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            objc_setAssociatedObject(_alertView, "TDelegate", self, OBJC_ASSOCIATION_RETAIN);  //防止self被提前释放
        }
        
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title{
    [self addButtonWithTitle:title block:nil];
}

- (void)addButtonWithTitle:(NSString *)title block:(BasicBlock)block {
    
    if ([self CanShowAlertController]) {
        [_alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            block ? block() : NULL;
        }]];
    } else {
        if ([_arrActions objectForKey:title]) { return; }
        [_alertView addButtonWithTitle:title];
        if (block) {
            BasicBlock action = block;
            [_arrActions setObject:action forKey:title];
        }
    }
}

- (void)show{
    if ([self CanShowAlertController]) {
        UIViewController *rootVc  = [kCurrentWindow rootViewController];
        while (rootVc.presentedViewController) {
            rootVc = rootVc.presentedViewController;
        }
        [rootVc presentViewController:_alertController animated:YES completion:nil];
    } else {
        [_alertView show];
    }
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    if ([UIAlertController class]) {
        UIAlertAction *action = _alertController.actions[buttonIndex];
        return action.title;
    } else {
        return [_alertView buttonTitleAtIndex:buttonIndex];
    }
}

- (BOOL)CanShowAlertController{
    if([UIAlertController class] && _hasRootVC){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - Setter & Getter

- (void)setTitle:(NSString *)title{
    [self CanShowAlertController] ? (_alertController.title = title) : (_alertView.title = title);
}

- (NSString *)title{
    return [self CanShowAlertController] ? _alertController.title : _alertView.title;
}

- (void)setMessage:(NSString *)message{
    [self CanShowAlertController] ? (_alertController.message = message) : (_alertView.message = message);
}

- (NSString *)message{
    return [self CanShowAlertController] ? _alertController.message : _alertView.message;
}

- (NSInteger)numberOfButtons{
    return [self CanShowAlertController] ? _alertController.actions.count : _alertView.numberOfButtons;
}

- (void)setWillPresentBlock:(BasicBlock)block {
    if ([self CanShowAlertController]) {
        [_alertController setBlockWillPresent:block];
    } else {
        if (block) {
            BasicBlock action = block;
            [_arrActions setObject:action forKey:GCAlertViewWillPresentKey];
        }
        else {
            [_arrActions removeObjectForKey:GCAlertViewWillPresentKey];
        }
    }
}

- (void)setDidPresentBlock:(BasicBlock)block {
    if ([self CanShowAlertController]) {
        [_alertController setBlockDidPresent:block];
    } else {
        if (block) {
            BasicBlock action = block;
            [_arrActions setObject:action forKey:GCAlertViewDidPresentKey];
        }
        else {
            [_arrActions removeObjectForKey:GCAlertViewDidPresentKey];
        }
    }
}

- (void)setWillDismissBlock:(BasicBlock)block {
    if ([self CanShowAlertController]) {
        [_alertController setBlockWillDismiss:block];
    } else {
        if (block) {
            BasicBlock action = block;
            [_arrActions setObject:action forKey:GCAlertViewWillDismissKey];
        }
        else {
            [_arrActions removeObjectForKey:GCAlertViewWillDismissKey];
        }
    }
}

- (void)setDidDismissBlock:(BasicBlock)block {
    if ([self CanShowAlertController]) {
        [_alertController setBlockDidDismiss:block];
    } else {
        if (block) {
            BasicBlock action = block;
            [_arrActions setObject:action forKey:GCAlertViewDidDismissKey];
        }
        else {
            [_arrActions removeObjectForKey:GCAlertViewDidDismissKey];
        }
    }
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0 && buttonIndex < alertView.numberOfButtons) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        BasicBlock action = [_arrActions objectForKey:title];
        if (action) { action(); }
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    BasicBlock action = [_arrActions objectForKey:GCAlertViewWillPresentKey];
    if (action) { action(); }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    BasicBlock action = [_arrActions objectForKey:GCAlertViewDidPresentKey];
    if (action) { action(); }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BasicBlock action = [_arrActions objectForKey:GCAlertViewWillDismissKey];
    if (action) { action(); }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BasicBlock action = [_arrActions objectForKey:GCAlertViewDidDismissKey];
    objc_removeAssociatedObjects(alertView);
    if (action) { action(); }
}


@end
