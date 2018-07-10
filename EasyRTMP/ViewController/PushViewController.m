//
//  ViewController.m
//  EasyCapture
//
//  Created by lyy on 9/7/18.
//  Copyright © 2018 lyy. All rights reserved.
//

#import "PushViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCellularData.h>
#import "ResolutionViewController.h"
#import "SettingViewController.h"
#import "InfoViewController.h"
#import "NoNetNotifieViewController.h"
#import "URLTool.h"

@interface PushViewController ()<SetDelegate, EasyResolutionDelegate, ConnectDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewMarginTop;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resolutionBtn;
@property (weak, nonatomic) IBOutlet UIButton *reverseBtn;
@property (weak, nonatomic) IBOutlet UIButton *screenBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UIButton *pushBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prev;

@end

@implementation PushViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PushViewController"];
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    [self setUI];
    
    // 推流器
    encoder = [[CameraEncoder alloc] init];
    encoder.delegate = self;
    [encoder initCameraWithOutputSize:CGSizeMake(480, 640)];
    encoder.previewLayer.frame = self.view.bounds;
    [self.contentView.layer addSublayer:encoder.previewLayer];
    
    self.prev = encoder.previewLayer;
    [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.prev.frame = CGRectMake(0, 0, HRGScreenWidth, HRGScreenHeight - 49);
    
    encoder.previewLayer.hidden = NO;
    [encoder startCapture];
    [encoder changeCameraStatus];
    
    // 根据应用生命周期的通知来设置推流器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someMethod:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someMethod:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.resolutionBtn setTitle:[NSString stringWithFormat:@"分辨率：%@", [URLTool gainResolition]] forState:UIControlStateNormal];
    self.bitrateLabel.text = @"帧率:20 码率:100Kbps";// TODO
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UI

- (void)setUI {
    self.topViewMarginTop.constant = HRGBarHeight + 10;
    
    [self.resolutionBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.resolutionBtn setTitleColor:UIColorFromRGB(ThemeColor) forState:UIControlStateHighlighted];
    [self.infoBtn setImage:[UIImage imageNamed:@"version"] forState:UIControlStateNormal];
    [self.infoBtn setImage:[UIImage imageNamed:@"version_click"] forState:UIControlStateHighlighted];
    [self.settingBtn setImage:[UIImage imageNamed:@"tab_setting"] forState:UIControlStateNormal];
    [self.settingBtn setImage:[UIImage imageNamed:@"tab_setting_click"] forState:UIControlStateHighlighted];
    [self.settingBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.settingBtn setTitleColor:UIColorFromRGB(ThemeColor) forState:UIControlStateHighlighted];
    
    [self.reverseBtn setImage:[UIImage imageNamed:@"reverse"] forState:UIControlStateNormal];
    [self.reverseBtn setImage:[UIImage imageNamed:@"reverse_click"] forState:UIControlStateSelected];
    [self.screenBtn setImage:[UIImage imageNamed:@"screen"] forState:UIControlStateNormal];
    [self.screenBtn setImage:[UIImage imageNamed:@"screen_click"] forState:UIControlStateSelected];
    [self.pushBtn setImage:[UIImage imageNamed:@"tab_push"] forState:UIControlStateNormal];
    [self.pushBtn setImage:[UIImage imageNamed:@"tab_push_click"] forState:UIControlStateSelected];
    [self.pushBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.pushBtn setTitleColor:UIColorFromRGB(ThemeColor) forState:UIControlStateSelected];
    [self.recordBtn setImage:[UIImage imageNamed:@"tab_record"] forState:UIControlStateNormal];
    [self.recordBtn setImage:[UIImage imageNamed:@"tab_record_click"] forState:UIControlStateSelected];
    [self.recordBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.recordBtn setTitleColor:UIColorFromRGB(ThemeColor) forState:UIControlStateSelected];
    
    [self.pushBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 20, 0, 0)];
    [self.pushBtn setTitleEdgeInsets:UIEdgeInsetsMake(24, -32, 0, 0)];
    [self.recordBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 20, 0, 0)];
    [self.recordBtn setTitleEdgeInsets:UIEdgeInsetsMake(24, -32, 0, 0)];
    [self.settingBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 20, 0, 0)];
    [self.settingBtn setTitleEdgeInsets:UIEdgeInsetsMake(24, -32, 0, 0)];
}

#pragma mark - 处理通知

- (void)someMethod:(NSNotification *)sender {
    if ([sender.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        if (self.pushBtn.selected && encoder) {
             [encoder startCamera];
        }
    } else {
        if (self.pushBtn.selected && encoder) {
            [encoder stopCamera];
        }
    }
}

#pragma mark - SetDelegate

// 设置页面修改了分辨率后的操作
- (void)setFinish {
    [encoder changeCameraStatus];
}

#pragma mark - EasyResolutionDelegate

- (void)onSelecedesolution:(NSInteger)resolutionNo {
    [encoder swapResolution];
    [self.resolutionBtn setTitle:[NSString stringWithFormat:@"分辨率：%@", [URLTool gainResolition]] forState:UIControlStateNormal];
}

#pragma mark - ConnectDelegate

- (void)getConnectStatus:(NSString *)status isFist:(int)tag {
//    __block UILabel *label = (UILabel *)[self.view viewWithTag:3000];
//    if (tag == 1) {
//        if (label) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    label.text = [NSString stringWithFormat:@"%@",status];
//                });
//            });
//        } else {
////            statusString = status;
//        }
//    } else {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *url = [URLTool gainURL];
//                label.text = [NSString stringWithFormat:@"%@\n%@",status,url];
//            });
//        });
//    }
}

#pragma mark - click event

// 分辨率
- (IBAction)resolution:(id)sender {
    if (encoder.running) {
        return;
    }
    
    ResolutionViewController *controller = [[ResolutionViewController alloc] init];
    controller.delegate = self;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

// 切换前后摄像头
- (IBAction)reverse:(id)sender {
    self.reverseBtn.selected = !self.reverseBtn.selected;
    [encoder swapFrontAndBackCameras];
}

// 横竖屏
- (IBAction)changeScreen:(id)sender {
    self.screenBtn.selected = !self.screenBtn.selected;
    
    if (self.screenBtn.selected) {
        // 竖屏时调整为左横屏
        [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        encoder.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else {
        // 竖屏
        [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        encoder.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

// 关于
- (IBAction)info:(id)sender {
    if (encoder.running) {
        return;
    }
    
    InfoViewController *controller = [[InfoViewController alloc] initWithStoryboard];
    [self basePushViewController:controller];
}

// 推送
- (IBAction)push:(id)sender {
    __weak typeof(self)weakSelf = self;
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
        // 获取联网状态
        switch (state) {
            case kCTCellularDataRestricted:
                NSLog(@"Restricrted");
                [weakSelf showAuthorityView];
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"Not Restricted");
                break;
            case kCTCellularDataRestrictedStateUnknown: {
                [weakSelf showAuthorityView];
                return;
            }
                break;
            default:
                break;
        };
    };
    
    self.pushBtn.selected = !self.pushBtn.selected;
    if (self.pushBtn.selected) {
        self.settingBtn.enabled = NO;
        self.infoBtn.enabled = NO;
        
        [encoder startCamera];
    } else {
        self.settingBtn.enabled = YES;
        self.infoBtn.enabled = YES;
        
        [encoder stopCamera];
    }
}

// 录像
- (IBAction)record:(id)sender {
    self.recordBtn.selected = !self.recordBtn.selected;
    
    // TODO
}

// 设置
- (IBAction)setting:(id)sender {
    if (encoder.running) {
        return;
    }
    
    SettingViewController *controller = [[SettingViewController alloc] initWithStoryboard];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showAuthorityView {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NoNetNotifieViewController *vc = [[NoNetNotifieViewController alloc] init];
            [weakSelf presentViewController:vc animated:YES completion:nil];
        });
    });
}

@end
