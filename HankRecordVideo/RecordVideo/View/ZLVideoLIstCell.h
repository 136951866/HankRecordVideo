//
//  ZLVideoLIstCell.h
//  我要留学
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLVideoLIstCell : UICollectionViewCell

@property (assign, nonatomic) BOOL isSelect;

- (void)setUIWithModel:(ALAsset *)model;
- (void)setPlayer;
- (void)removePlayer;

@end
