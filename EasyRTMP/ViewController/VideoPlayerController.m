
#import "VideoPlayerController.h"
#import "RecordViewController.h"
#import "VideoPanel.h"
#import "AudioManager.h"

@interface VideoPlayerController () <VideoPanelDelegate>

@property (nonatomic, retain) NSArray *urlModels;
@property (nonatomic, strong) VideoPanel *panel;

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) CGRect panelFrame;

@end

@implementation VideoPlayerController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 最多是9分屏，最多9个URL
    self.model.useHWDecoder = YES;
    self.model.isAutoAudio = YES;
    self.model.isAutoRecord = NO;
    _urlModels = @[ self.model ];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >=7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = self.model.url;
    self.view.backgroundColor = UIColorFromRGB(0xfefefe);
    
    [[AudioManager sharedInstance] activateAudioSession];
    
    self.panelFrame = CGRectMake(0, 0, EasyScreenWidth, EasyScreenWidth);
    self.panel = [[VideoPanel alloc] initWithFrame:self.panelFrame];
    self.panel.delegate = self;
    [self.view addSubview:self.panel];
    [self.panel setLayout:IVL_One URLs:_urlModels];
    [self.panel startAll:_urlModels];
    
    [self regestAppStatusNotification];
    
    // 监听屏幕方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // 当手机的重力感应打开的时候, 如果用户旋转手机, 系统会抛发UIDeviceOrientationDidChangeNotification 事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flie"] style:UIBarButtonItemStyleDone target:self action:@selector(fileList)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.panel restore];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self normalScreenWithDuration:0];// 回归竖屏
    
    [self.panel stopAll];
}

- (void)dealloc {
    [[AudioManager sharedInstance] deactivateAudioSession];
    [self removeAppStutusNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void) fileList {
//    RecordViewController *controllr = [[RecordViewController alloc] initWithStoryborad];
//    controllr.url = self.model.url;
//    [self.navigationController pushViewController:controllr animated:YES];
}

#pragma mark - 根据屏幕状态，旋转UI

- (void)orientationChanged:(NSNotification *)notification {
    // 获取屏幕的方向
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeRight) {// 右横屏
        [self crossScreenWithDuration:0.5 isLeftCrossScreen:NO];
        [self.panel changeHorizontalScreen:YES];
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {// 左横屏
        [self crossScreenWithDuration:0.5 isLeftCrossScreen:YES];
        [self.panel changeHorizontalScreen:YES];
    } else if (orientation == UIDeviceOrientationPortrait) {// 正竖屏
        [self normalScreenWithDuration:0.5];
        [self.panel changeHorizontalScreen:NO];
    }
}

#pragma mark - 横竖屏设置

- (void) crossScreenWithDuration:(NSTimeInterval)duration isLeftCrossScreen:(BOOL)isLeft {
    [UIView animateWithDuration:duration animations:^{
        [self.navigationController setNavigationBarHidden:YES];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.statusBarHidden = NO;
        [self prefersStatusBarHidden];
        
        self.panel.frame = CGRectMake(0, 0, EasyScreenHeight, EasyScreenWidth);
        self.panel.center = self.view.center;
        
        if (isLeft) {
            self.panel.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else {
            self.panel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    }];
}

- (void) normalScreenWithDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        [self.navigationController setNavigationBarHidden:NO];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.statusBarHidden = YES;
        [self prefersStatusBarHidden];
        
        self.panel.frame = self.panelFrame;
        self.panel.transform = CGAffineTransformIdentity;
    }];
    
    for (VideoView *v in self.panel.resuedViews) {
        v.landspaceButton.selected = NO;
    }
}

#pragma mark - click event

- (void)goBack:(id)sender {
    [self.panel stopAll];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)enterBackground {
    [[AudioManager sharedInstance] deactivateAudioSession];
    [self.panel stopAll];
}

#pragma mark - VideoPanelDelegate

- (void)activeViewDidiUpdateStream:(VideoView *)view {
    
}

- (void)didSelectVideoView:(VideoView *)view {
    BOOL enable = view.videoStatus == Rendering;
    NSLog(@"%d", enable);
}

- (void)activeVideoViewRendStatusChanged:(VideoView *)view {
    
}

- (void)videoViewWillAddNewRes:(VideoView *)view index:(int)index {
    
}

- (void)videoViewWillAnimateToFullScreen:(VideoView *)view {
//    [self.panel setLayout:IVL_One URLs:_urlModels];// 先转成1分频
    [self crossScreenWithDuration:0.5 isLeftCrossScreen:YES];// 再全屏
}

- (void)videoViewWillAnimateToNomarl:(VideoView *)view {
    [self normalScreenWithDuration:0.5];
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification

- (void)regestAppStatusNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeAppStutusNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Notification 实现方法

- (void)becomeActive {
    [[AudioManager sharedInstance] activateAudioSession];
    [self.panel restore];
}

#pragma mark - StatusBar

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

@end
