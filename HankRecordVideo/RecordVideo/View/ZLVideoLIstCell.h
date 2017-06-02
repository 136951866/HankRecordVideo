//
//  ZLVideoLIstCell.h
//  HankRecordVideo
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016 Hank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLVideoLIstCell : UICollectionViewCell

@property (assign, nonatomic) BOOL isSelect;

- (void)setUIWithModel:(ALAsset *)model;
- (void)setPlayer;
- (void)removePlayer;

@end
