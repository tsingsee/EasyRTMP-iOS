
#import <UIKit/UIKit.h>
#import "PlayerDataReader.h"

typedef enum {
    Stopped,    // 停止
    Suspend,    // 暂停
    Connecting, // 连接中
    Rendering,  // 播放中
}IVideoStatus;

@protocol VideoViewDelegate;

@interface VideoView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *container;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *landspaceButton;  // 全屏按钮

@property (nonatomic, weak) id<VideoViewDelegate> delegate;

// 流媒体地址
@property (nonatomic, copy) NSString *url;
// 传输协议：TCP/UDP(EASY_RTP_CONNECT_TYPE：0x01，0x02)
@property (nonatomic, assign) EASY_RTP_CONNECT_TYPE transportMode;
// 发送保活包(心跳：0x00 不发送心跳， 0x01 OPTIONS， 0x02 GET_PARAMETER)
@property (nonatomic, assign) int sendOption;

@property (nonatomic, copy) NSString *recordFilePath;   // 录像地址
@property (nonatomic, copy) NSString *screenShotPath;   // 截图地址

@property (nonatomic, strong) PlayerDataReader *reader;
@property (nonatomic, assign) IVideoStatus videoStatus;

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL useHWDecoder;        // 是否启用硬解
@property (nonatomic, assign) BOOL isAutoAudio;         // 是否自动开启音频
@property (nonatomic, assign) BOOL isAutoRecord;        // 是否自动播放音频
@property (nonatomic, assign) BOOL showAllRegon;        //
@property (nonatomic, assign) BOOL showActiveStatus;    //

- (void)beginTransform;
- (void)endTransform;

- (void) hideBtnView;
- (void) changeHorizontalScreen:(BOOL) horizontal;

- (void) setVideoViewFrame:(CGRect)frame;

// ----------------- 播放控制 -----------------
- (void)stopAudio;
- (void)startPlay;
- (void)stopPlay;
- (void)flush;

@end

@protocol VideoViewDelegate <NSObject>

@optional

- (void)videoViewDidiUpdateStream:(VideoView *)view;
- (void)videoViewBeginActive:(VideoView *)view;

// 全屏(横屏)
- (void)videoViewWillAnimateToFullScreen:(VideoView *)view;
// 竖屏
- (void)videoViewWillAnimateToNomarl:(VideoView *)view;

// 连接视频源
- (void)videoViewWillTryToConnect:(VideoView *)view;

- (void) back;

@end
