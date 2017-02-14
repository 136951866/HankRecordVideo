//
//  ZLVideoLIstVC.h
//  我要留学
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016年 深圳市智联天下国际教育有限公司. All rights reserved.
//

#import "ZLVideoModel.h"

typedef void (^VideoModelBlock)(ZLVideoModel *videomodel);

@interface ZLVideoLIstVC : UIViewController

//选择视频压缩返回的data
@property (nonatomic, copy)VideoModelBlock dataBlock;
+ (void)presentVideoVCWithDataHandler:(VideoModelBlock)dataBlock;
@end
