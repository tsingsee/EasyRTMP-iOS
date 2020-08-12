
#import <UIKit/UIKit.h>
#import "VideoView.h"
#import "URLModel.h"

typedef NS_OPTIONS(NSInteger, IVideoLayout) {
    IVL_One = 1,
    IVL_Four = 4,
    IVL_Nine = 9,
};

@protocol VideoPanelDelegate;

@interface VideoPanel : UIView

@property (nonatomic, weak) id<VideoPanelDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *resuedViews;
@property (nonatomic, strong) VideoView *activeView;

@property (nonatomic, assign) IVideoLayout layout;
@property (nonatomic, strong) NSArray<URLModel *> *urlModels;

- (VideoView *) nextAvailableContainer;

// 重启全部视频的播放
- (void) restore;

// 停止全部视频的播放
- (void) stopAll;

// 开始全部视频的播放
- (void) startAll:(NSArray<URLModel *> *)urlModels;

// 设置分屏
- (void)setLayout:(IVideoLayout)layout URLs:(NSArray<URLModel *> *)urlModels;

// 隐藏底部按钮
- (void) hideBtnView;

// 是否切换成横屏了
- (void) changeHorizontalScreen:(BOOL) horizontal;

@end

@protocol VideoPanelDelegate <NSObject>

@optional
- (void) activeViewDidiUpdateStream:(VideoView *)view;
- (void) didSelectVideoView:(VideoView *)view;
- (void) activeVideoViewRendStatusChanged:(VideoView *)view;

- (void) videoViewWillAnimateToFullScreen:(VideoView *)view;
- (void) videoViewWillAnimateToNomarl:(VideoView *)view;

// 添加新视频源
- (void) videoViewWillAddNewRes:(VideoView *)view index:(int)index;

- (void) back;

@end
