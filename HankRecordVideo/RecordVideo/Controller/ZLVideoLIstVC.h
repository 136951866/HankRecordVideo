//
//  ZLVideoLIstVC.h
//  HankRecordVideo
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016 Hank. All rights reserved.
//

#import "ZLVideoModel.h"

typedef void (^VideoModelBlock)(ZLVideoModel *videomodel);

@interface ZLVideoLIstVC : UIViewController

//选择视频压缩返回的data
@property (nonatomic, copy)VideoModelBlock dataBlock;
+ (void)presentVideoVCWithDataHandler:(VideoModelBlock)dataBlock;
@end
