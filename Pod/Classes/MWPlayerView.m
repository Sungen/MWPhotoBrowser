//
//  MWPlayerView.m
//  MWPhotoBrowser-iOS7.0
//
//  Created by Junyang Wu on 2018/7/16.
//

#import "MWPlayerView.h"
#import "UIImage+MWPhotoBrowser.h"

@interface MWPlayerSlider : UISlider

@end

@implementation MWPlayerSlider

@end

@interface MWPlayerView()

@property(nonatomic, strong) MWPlayerSlider *slider;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;

@property(nonatomic, assign) BOOL isDraging;

@end

@implementation MWPlayerView {
    id _periodObserver;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

+ (instancetype)playerViewWithURL:(NSURL *)url frame:(CGRect)frame {
    MWPlayerView *playerView = [[MWPlayerView alloc] initWithFrame:frame];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    [[playerView playerLayer] setPlayer:player];
    return playerView;
}

// 透明背景 空白区域 不接受对自己的点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayerItem *)playerItem {
    return [self player].currentItem;
}

- (AVPlayer *)player {
    return [self.playerLayer player];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.slider.frame = CGRectMake(3, CGRectGetHeight(self.bounds)-54+8, CGRectGetWidth(self.bounds)-6, 2);
    self.playButton.frame = CGRectMake(8, CGRectGetMaxY(self.slider.frame)+8, 30, 30);
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+4, CGRectGetMidY(self.playButton.frame)-10, 120, 20);
}

- (void)setupView {
    MWPlayerSlider *slider = [[MWPlayerSlider alloc] initWithFrame:CGRectZero];
    UIImage *image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageSlider" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
    [slider setThumbImage:image forState:UIControlStateNormal];
    slider.minimumTrackTintColor = [UIColor colorWithRed:1.0*0xc8/0xff green:1.0*0x17/0xff blue:1.0*0x1e/0xff alpha:1.0];
    slider.maximumTrackTintColor = [UIColor colorWithRed:1.0*0x8c/0xff green:1.0*0x8c/0xff blue:1.0*0x8c/0xff alpha:1.0];
    [slider addTarget:self action:@selector(sliderDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addSubview:slider];
    self.slider = slider;
    slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.playButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:1.0*0x55/0xff green:1.0*0x55/0xff blue:1.0*0x55/0xff alpha:1.0];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:label];
    self.timeLable = label;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)addPlayNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinishedCallback:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self playerItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFailedCallback:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:[self playerItem]];
    
    Float64 duration = CMTimeGetSeconds([self playerItem].asset.duration);
    CMTime interval = duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
    __weak typeof(self) weakSelf = self;
    _periodObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isDraging) {
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *timeText = [NSString stringWithFormat:@"%@/%@", [weakSelf convertTime:currentTime], [weakSelf convertTime:duration]];
            weakSelf.timeLable.text = timeText;
            weakSelf.slider.value = currentTime/duration;
        }
    }];
}

- (void)removePlayNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self playerItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:[self playerItem]];
    if (_periodObserver) {
        [self.player removeTimeObserver:_periodObserver];
        _periodObserver = nil;
    }
}

#pragma mark -

- (void)play {
    [self removePlayNotifications];
    
    [self addPlayNotifications];
    
    [[self player] play];
}

- (void)pause {
    [self removePlayNotifications];
    [[self player] pause];
}

#pragma mark -

- (void)playAction:(UIButton *)button {
    if (button.tag == 1) {
        button.tag = 2;
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePause" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePauseTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [self pause];
    }else if (button.tag == 2){
        button.tag = 1;
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [self play];
    }
}

- (void)sliderValueDidChanged:(UISlider *)slider {
    Float64 duration = CMTimeGetSeconds([self playerItem].asset.duration);
    Float64 now = slider.value * duration;
    [self.player seekToTime:CMTimeMake(now, 1)];
    NSLog(@"==>>sliderValueDidChanged");
}

- (void)sliderDidTouchUp:(UISlider *)slider {
    NSLog(@"==>>sliderDidTouchUp");
    self.isDraging = NO;
}

- (void)sliderDidTouchDown:(UISlider *)slider {
    NSLog(@"==>>sliderDidTouchDown");
    self.isDraging = YES;
}

#pragma mark -

- (NSString *)convertTime:(CGFloat)time{
    int hour = time / 3600;
    int minute = (time - hour*3600)/60;
    int second = (time - hour*3600 - minute*60);
    if (hour) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }else {
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}

- (void)videoFailedCallback:(NSNotification*)notification {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(playerViewDidFinishWithError:)]) {
        [self.delegate playerViewDidFinishWithError:nil];
    }
}

- (void)videoFinishedCallback:(NSNotification*)notification {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(playerViewDidFinishWithError:)]) {
        [self.delegate playerViewDidFinishWithError:nil];
    }
}

@end
