//
//  ZLVideoLIstVC.m
//  HankRecordVideo
//
//  Created by Hank on 2016/12/20.
//  Copyright © 2016 Hank. All rights reserved.
//

#import "ZLVideoLIstVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLVideoLIstCell.h"
#import "ZLRecordVideoVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZLRecordTool.h"
//#import <Photos/Photos.h>
//#import <Photos/PHFetchResult.h>
#import "ZLRecordVideoPublicTool.h"
#import "ZLAlertView.h"
#import "ZLFailLoadView.h"

#define kColumnNum 2
#define kMargin  (14 * kFrameScaleX())
#define kCellWidth ((SCREEN_WIDTH - ((kColumnNum + 1) * kMargin))/kColumnNum)
#define kCellHeight (85 * kFrameScaleX())
#define kMaxTime 30
#define kTBMargin (28 * kFrameScaleY())
#define kRLMargin kMargin

const static CGFloat kbtnRecordWH = 44;


@interface ZLVideoLIstVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSMutableArray *_groupArr; //相册数组
    NSMutableArray *_arrData;//数据源
    NSUInteger _selectRow;
}

@property (strong, nonatomic) ALAssetsGroup                 *videoGroup;
@property (strong, nonatomic) UICollectionView              *collectionView;
@property (strong, nonatomic) MPMoviePlayerViewController   *playerVC;
@property (strong, nonatomic) ZLRecordTool                  *recordEngine;
@property (strong, nonatomic) UIButton                      *btnRecord;
@property (strong, nonatomic) NSTimer                       *timer;
@property (strong, nonatomic) ALAssetsLibrary               *libAss;//相册数据
@end

@implementation ZLVideoLIstVC

- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
}

+ (void)presentVideoVCWithDataHandler:(VideoModelBlock)dataBlock{
    ZLVideoLIstVC *videoListVC = [[ZLVideoLIstVC alloc]init];
    videoListVC.dataBlock = dataBlock;
    [ZLPublicTool presentViewController:videoListVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择视频";
    [self scan];
    [self initSomeThing];
    if (kIsIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)scan{
    _selectRow = -1;
    _groupArr = [NSMutableArray array];
    _arrData = [NSMutableArray array];
    
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus) {
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:{
            ZLAlertView *alert = [[ZLAlertView alloc] initWithTitle:@"打开相册/相机失败" message:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-照片/相机”选项中，允许%@访问你的照片／相机",@"我要留学"]];
            [alert addButtonWithTitle:@"我知道了" block:^{
                [ZLPublicTool dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addButtonWithTitle:@"设置" block:^{
                NSString *urlStr = kIsIOS8 ? UIApplicationOpenSettingsURLString : @"prefs:root=General&path=INTERNET_TETHERING";
                NSURL *url = [NSURL URLWithString:urlStr];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            [alert show];
        }
            break;
        case PHAuthorizationStatusNotDetermined:{
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanAuthorized) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
        }
            break;
        case PHAuthorizationStatusAuthorized:{
            [self initSomeThing];
        }
            break;
        default:
            break;
    }
}

- (void)scanAuthorized{
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusAuthorized){
        [self.timer invalidate];
        self.timer = nil;
        [self initSomeThing];
    }
}

- (void)initSomeThing{

    /*
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
    WEAKSELF
    for (NSInteger i = 0; i < assetsFetchResults.count; i++) {
        // 获取一个资源（PHAsset）
        PHAsset *phAsset = assetsFetchResults[i];
        if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            
            PHImageManager *manager = [PHImageManager defaultManager];
            
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                STRONGSELF
                float videoDurationSeconds = CMTimeGetSeconds(asset.duration);
                if(videoDurationSeconds >0 && videoDurationSeconds<=kMaxTime){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf->_arrData addObject:asset];
                    });
                    
                }
            }];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        strongSelf.navigationItem.rightBarButtonItem = [UIBarButtonItem unborderItemWithTarget:weakSelf act:@selector(editAction:) title:@"编辑" selectTitle:@"完成"];
        [strongSelf.navigationItem.rightBarButtonItem setTextItemTextColor:kGuideYellow];
        [strongSelf.view addSubview:strongSelf.collectionView];
        [strongSelf->_collectionView reloadData];
    });
    WEAKSELF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem unborderItemWithTarget:weakSelf act:@selector(editAction:) title:@"编辑" selectTitle:@"完成"];
        
        [self.navigationItem.rightBarButtonItem setTextItemTextColor:kGuideYellow];
        [self.view addSubview:self.collectionView];
        
    });
    */
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showMessage:@"获取视频中" toView:self.view];
    __block BOOL reloaded = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WEAKSELF
        ALAssetsLibraryAccessFailureBlock errBlock = ^(NSError *myerror){
            if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized){
                
            }
        };
        [self.libAss enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            STRONGSELF
            if(!group){
                NSLog(@"group == nil");
                return;
            }
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            if ([group numberOfAssets]<1) {
                return;
            }
            [strongSelf->_groupArr addObject:group];
            if(reloaded){
                [strongSelf->_collectionView reloadData];
            }
        } failureBlock:errBlock];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            reloaded = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [strongSelf.view addSubview:strongSelf.collectionView];
            [strongSelf.view addSubview:strongSelf.btnRecord];
            if (!strongSelf.videoGroup && _groupArr.count>0) {
                strongSelf.videoGroup = [_groupArr lastObject];
            }
            [strongSelf showFailLoadView];
        });
    });
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_selectRow == -1){
        return;
    }
    ZLVideoLIstCell *selectCell = (ZLVideoLIstCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectRow inSection:0]];
    [selectCell removePlayer];
    selectCell.isSelect = NO;
    _selectRow = -1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == _selectRow){
        ALAsset *model = _arrData[indexPath.row];
        ZLVideoLIstCell *cell = (ZLVideoLIstCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectRow inSection:indexPath.section]];
        cell.isSelect = NO;
        [cell removePlayer];
//        AVURLAsset *urlAsset = (AVURLAsset *)model;
//        NSURL *videoUrl = urlAsset.URL;
        NSURL *videoUrl = [model valueForProperty:ALAssetPropertyAssetURL];
        WEAKSELF
        [MBProgressHUD showMessage:@"压缩文件中" toView:self.view];
        [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
            STRONGSELF
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            NSURL *URL = [NSURL fileURLWithPath:weakSelf.recordEngine.videoPath];
            ZLVideoModel *videoModel = [ZLVideoModel modelWithVideoImage:movieImage fileUrl:URL];
            [ZLPublicTool dismissViewControllerAnimated:YES completion:^{
                STRONGSELF
                TCallBlock(strongSelf.dataBlock,videoModel);
            }];
        }];
    }else{
        if(_selectRow !=-1){
            ZLVideoLIstCell *cell = (ZLVideoLIstCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectRow inSection:indexPath.section]];
            cell.isSelect = NO;
            [cell removePlayer];
        }
        _selectRow = indexPath.row;
        ZLVideoLIstCell *selectCell = (ZLVideoLIstCell *)[collectionView cellForItemAtIndexPath:indexPath];
        selectCell.isSelect = YES;
        [selectCell setPlayer];
        //[self.collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZLVideoLIstCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZLVideoLIstCell class]) forIndexPath:indexPath];
    ALAsset *model = _arrData[indexPath.row];
    cell.isSelect = _selectRow == indexPath.row;
    [cell setUIWithModel:model];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(kTBMargin, kRLMargin, kTBMargin, kRLMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kCellWidth, kCellHeight);
}

#pragma mark - event

- (void)returnAction:(UIButton *)sender{
    [ZLPublicTool dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordAction:(UIButton *)sender{
    ZLRecordVideoVC *vc = [[ZLRecordVideoVC alloc]init];
    WEAKSELF
    vc.dataBlock = ^(ZLVideoModel *videoModel){
        [ZLPublicTool dismissViewControllerAnimated:YES completion:^{
            STRONGSELF
            TCallBlock(strongSelf.dataBlock,videoModel);
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Setter Getter

- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kNavBarHeight) collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ZLVideoLIstCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZLVideoLIstCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (void)setVideoGroup:(ALAssetsGroup *)videoGroup{
    _videoGroup = videoGroup;
    _arrData = [NSMutableArray array];
    [_videoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            NSString *strDuration = [result valueForProperty:ALAssetPropertyDuration];
            CGFloat duration = [strDuration floatValue];
            if(duration <= kMaxTime && duration > 0){
                [_arrData addObject:result];
            }
        }
    }];
}

- (ZLRecordTool *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[ZLRecordTool alloc] init];
    }
    return _recordEngine;
}

- (UIButton *)btnRecord{
    if(!_btnRecord){
        _btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRecord.frame = CGRectMake(SCREEN_WIDTH - kbtnRecordWH - kMargin, SCREEN_HEIGHT  - kMargin - kbtnRecordWH, kbtnRecordWH, kbtnRecordWH);
        [_btnRecord setImage:[UIImage imageNamed:@"circlewrite_btn_video"] forState:UIControlStateNormal];
        [_btnRecord addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRecord;
}

- (void)showFailLoadView{
        if(_arrData.count >0){
             [self.collectionView reloadData];
        }else{
            [ZLFailLoadView showInView:self.collectionView refreshBlock:^{
                if (!self) {
                    return;
                }
                [self initSomeThing];
            } editHandle:^(ZLFailLoadView *failView) {
                failView.lblOfNodata.text = @"没有视频";
            }];
        }
}

- (ALAssetsLibrary *)libAss{
    if(!_libAss){
        _libAss = [[ALAssetsLibrary alloc]init];
    }
    return _libAss;
}

@end
