//
//  ZLFailLoadView.m
//  我要留学
//
//  Created by Hank on 10/13/16.
//  Copyright © 2016 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLFailLoadView.h"
#import "UIView+subview.h"

@interface ZLFailLoadView()

@property (nonatomic,strong) BasicBlock block_refresh;

@end

@implementation ZLFailLoadView

- (id)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        //load noData
        self.backgroundColor = [UIColor whiteColor];
        _viewOfContentNoData = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 145)];
        _viewOfContentNoData.centerY = self.height/2;
        _imgvOfNoData = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_noData"]];
        _imgvOfNoData.center = CGPointMake(_viewOfContentNoData.width/2, _imgvOfNoData.height/2+1);
        _lblOfNodata = [[UILabel alloc]initWithFrame:CGRectMake(0, _imgvOfNoData.bottom+26, _viewOfContentNoData.width, 20)];
        _lblOfNodata.textAlignment = NSTextAlignmentCenter;
        _lblOfNodata.font = [UIFont systemFontOfSize:15];
        _lblOfNodata.text = kDefaultNodataPrompt;
        [_viewOfContentNoData addSubview:_imgvOfNoData];
        [_viewOfContentNoData addSubview:_lblOfNodata];
        [self addSubview:_viewOfContentNoData];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - EVENT

- (void)tapAction:(UITapGestureRecognizer *)sender{
    if(self.block_refresh){
        self.block_refresh();
        if (_viewOfContentNoData.hidden) {
            [self removeFromSuperview];
        }
    }
}

#pragma mark - CLASS METHOD

+ (void)removeFromView:(UIView *)aView{
    ZLFailLoadView *failView = (ZLFailLoadView *)[aView subViewOfClass:[ZLFailLoadView class]];
    if ([failView isKindOfClass:[ZLFailLoadView class]]) {
        [failView removeFromSuperview];
    }
}

+ (void)showInView:(UIView *)aView refreshBlock:(BasicBlock)block editHandle:(editFailLoadVIewBlock)aBlock{
    [self removeFromView:aView];
    CGFloat y = 0;
    if ([aView isKindOfClass:[UITableView class]]) {
        UITableView *table = (UITableView *)aView;
        if (table.tableHeaderView) {
            y = table.tableHeaderView.height;
        }
    }
    ZLFailLoadView *failVIew = [[ZLFailLoadView alloc]initWithFrame:CGRectMake(0, y, aView.width, aView.height-y)];
    failVIew.block_refresh = block;
    if (aBlock) {
        aBlock(failVIew);
    }
    failVIew.viewOfContentNoData.hidden = NO;
    [aView addSubview:failVIew];
}

+ (void)showInView:(UIView *)aView response:(id)response allData:(NSArray *)arrData refreshBlock:(BasicBlock)blockRefresh editHandle:(editFailLoadVIewBlock)blockEdit{
    BOOL hasData = arrData.count>0?YES:NO;
    if(!hasData){
        [ZLFailLoadView showInView:aView refreshBlock:blockRefresh editHandle:^(ZLFailLoadView *failView) {
            if (blockEdit) {
                blockEdit(failView);
            }
        }];
    }
}

@end
