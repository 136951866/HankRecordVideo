//
//  ZLVideoLIstCell.m
//  HankRecordVideo
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016 Hank. All rights reserved.
//

#import "ZLVideoLIstCell.h"
#import <AVFoundation/AVFoundation.h>


@interface ZLVideoLIstCell(){
    ALAsset *_model;
}

@property (weak, nonatomic) IBOutlet UIView *viewBack;
@property (weak, nonatomic) IBOutlet UILabel *lblSelect;
@property (weak, nonatomic) IBOutlet UIImageView *imgPic;
@property (weak, nonatomic) IBOutlet UIView *viewplayer;

@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation ZLVideoLIstCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma Setter Getter

- (void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    _viewBack.hidden = _lblSelect.hidden = _viewplayer.hidden=!isSelect;
}

- (void)setUIWithModel:(ALAsset *)model{
    _imgPic.image = [UIImage imageWithCGImage:[model thumbnail]];
    _model = model;
}

- (void)setPlayer{
    NSURL *videoUrl = [_model valueForProperty:ALAssetPropertyAssetURL];
    self.playerItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = _viewplayer.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_viewplayer.layer insertSublayer:self.playerLayer atIndex:0];
    self.player.volume = 0;
    [self.player play];
}

- (void)removePlayer{
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
}

@end
