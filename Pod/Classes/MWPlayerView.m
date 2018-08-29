//
//  MWPlayerView.m
//  MWPhotoBrowser-iOS7.0
//
//  Created by Junyang Wu on 2018/7/16.
//

#import "MWActionView+AVPlayer.h"
#import "UIImage+MWPhotoBrowser.h"
#import "MWPhotoBrowser.h"


@interface MWPlayerView ()

@property(nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;

@property(nonatomic, assign) BOOL isDraging;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) CGFloat duration;
@property(nonatomic, assign) CGFloat fps;
@property(nonatomic, assign) BOOL isObservering;

@property(nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;
@property(nonatomic, strong) UITapGestureRecognizer *tap;

@property(nonatomic, weak) id<MWActionViewPlayerDelegate> playerDelegate;
@property(nonatomic, strong) id periodObserver;

@end

@implementation MWPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (CGFloat)duration {
    if (isnan(_duration) || isinf(_duration) || _duration == 0) {
        return 24*3600;
    }
    return _duration;
}

- (CGFloat)fps {
    if (isinf(_fps) || isnan(_fps) || _fps == 0) {
        return 24; // 24fps
    }
    return _fps;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayerItem *)playerItem {
    return [self player].currentItem;
}

- (AVPlayer *)player {
    return [[self playerLayer] player];
}

- (void)layoutSubviewsExtension {
    
    self.slider.frame = CGRectMake(3, CGRectGetHeight(self.bottomView.bounds)-54, CGRectGetWidth(self.bottomView.bounds)-6, 18);
    self.playButton.frame = CGRectMake(8, CGRectGetMaxY(self.slider.frame), 30, 30);
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+4, CGRectGetMidY(self.playButton.frame)-10, 120, 20);
    self.loadingIndicatorView.center = self.center;
}

- (UISlider *)slider {
    if (!_slider) {
        MWPlayerSlider *slider = [[MWPlayerSlider alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageSlider" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
        [slider setThumbImage:image forState:UIControlStateNormal];
        slider.minimumTrackTintColor = [UIColor colorWithRed:1.0*0xc8/0xff green:1.0*0x17/0xff blue:1.0*0x1e/0xff alpha:1.0];
        slider.maximumTrackTintColor = [UIColor colorWithRed:1.0*0x8c/0xff green:1.0*0x8c/0xff blue:1.0*0x8c/0xff alpha:1.0];
        [slider addTarget:self action:@selector(sliderDidTouchDown:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self.bottomView addSubview:slider];
        self.slider = slider;
        slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _slider;
}

- (UIButton *)playButton {
    if (!_playButton) {
        UIButton *button = [MWShapeButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:button];
        self.playButton = button;
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _playButton;
}

- (UILabel *)timeLable {
    if (!_timeLable) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:1.0*0x55/0xff green:1.0*0x55/0xff blue:1.0*0x55/0xff alpha:1.0];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
        label.textAlignment = NSTextAlignmentLeft;
        [self.bottomView addSubview:label];
        self.timeLable = label;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _timeLable;
}

- (UIActivityIndicatorView *)loadingIndicatorView {
    if (!_loadingIndicatorView) {
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        aiv.hidesWhenStopped = YES;
        [self addSubview:aiv];
        self.loadingIndicatorView = aiv;
    }
    return _loadingIndicatorView;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tap setNumberOfTouchesRequired:1];
        [self.slider addGestureRecognizer:tap];
        self.tap = tap;
    }
    return _tap;
}

#pragma mark -
- (void)addPlayNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinishedCallback:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self playerItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFailedCallback:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:[self playerItem]];
    
    CMTime interval = CMTimeMake(1, self.fps);
    __weak typeof(self) weakSelf = self;
    _periodObserver = [[self player] addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isDraging) {
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *timeText = [NSString stringWithFormat:@"%@/%@", [weakSelf convertTime:currentTime], [weakSelf convertTime:weakSelf.duration]];
            weakSelf.timeLable.text = timeText;
            [weakSelf.slider setValue:(currentTime/weakSelf.duration) animated:YES];
        }
    }];
}

- (void)removePlayNotifications {
    if (self.isObservering) {
        self.isObservering = NO;
        [[self playerItem] removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self playerItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:[self playerItem]];
    if (_periodObserver) {
        [[self player] removeTimeObserver:_periodObserver];
        _periodObserver = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self.loadingIndicatorView stopAnimating];
            self.duration = CMTimeGetSeconds(item.asset.duration);
            self.fps = [[[item.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] nominalFrameRate];
            [self makeControllerEnable:YES];
            [self addPlayNotifications];
        }else if (item.status == AVPlayerItemStatusFailed) {
            [self videoFailedCallback:nil];
        }
    }
}

- (void)clean {
    self.timeLable.text = @"00:00/--:--";
    self.slider.value = 0;
    self.playButton.tag = 2;
    [self makeControllerEnable:NO];
    [self pause];
}

- (void)makeControllerEnable:(BOOL)enable {
    self.playButton.enabled = self.slider.enabled = enable;
}

#pragma mark -

- (void)showPlayerControllers:(BOOL)flag withDelegate:(id<MWActionViewPlayerDelegate>)delegate {
    self.slider.hidden = self.playButton.hidden = self.timeLable.hidden = !flag;
    self.tap.enabled = flag;
    self.delegate = delegate;
}

- (void)setVideoURL:(NSURL *)url {
    [self clean];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [[self playerLayer] setPlayer:player];
}

- (void)play {
    if (self.isPlaying) return;
    self.isPlaying = YES;
    [self.loadingIndicatorView startAnimating];
    
    self.isObservering = YES;
    [[self playerItem] addObserver:self
                        forKeyPath:@"status"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
    [self doPlay];
}

- (void)pause {
    if (!self.isPlaying) return;
    self.isPlaying = NO;
    [self.loadingIndicatorView stopAnimating];
    
    [self removePlayNotifications];
    [self doPause];
}

#pragma mark -

- (void)setViewAlpha:(CGFloat)alpha {
    for (UIView *subView in self.subviews) {
        subView.alpha = alpha;
    }
    if (alpha == 0) {
        self.menuView.hidden = YES;
    }
}

- (CGFloat)viewAlpha {
    return [[[self subviews] lastObject] alpha];
}

- (void)doPause {
    self.playButton.tag = 1;
    [self.playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [[self player] pause];
}

- (void)doPlay {
    self.playButton.tag = 2;
    [self.playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePause" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePauseTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [[self player] play];
}

#pragma mark -

- (void)playAction:(UIButton *)button {
    if (button.tag == 2) {
        [self doPause];
    }else if (button.tag == 1){
        [self doPlay];
    }
}

- (void)sliderValueDidChanged:(UISlider *)slider {
    MWLog(@"==>>sliderValueDidChanged");
    Float64 duration = self.duration;
    Float64 current = slider.value * duration;
    NSString *timeText = [NSString stringWithFormat:@"%@/%@", [self convertTime:current], [self convertTime:duration]];
    self.timeLable.text = timeText;
    
    CMTime time = CMTimeMakeWithSeconds(current, self.fps);
    [[self player] seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)sliderDidTouchUp:(UISlider *)slider {
    MWLog(@"==>>sliderDidTouchUp");
    self.isDraging = NO;
    self.tap.enabled = YES;
    if (self.isPlaying) {
        [self doPlay];
    }
}

- (void)sliderDidTouchDown:(UISlider *)slider {
    MWLog(@"==>>sliderDidTouchDown");
    self.isDraging = YES;
    self.tap.enabled = NO;
    if (self.isPlaying) {
        [self doPause];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    MWLog(@"==>>tap");
    CGPoint point = [tap locationInView:self.slider];
    CGFloat value = point.x / CGRectGetWidth(self.slider.frame);
    [self.slider setValue:value animated:YES];
    
    if (self.isPlaying) {
        [self doPause];
    }
    
    Float64 duration = self.duration;
    CMTime time = CMTimeMakeWithSeconds(duration * value, self.fps);
    
    __weak typeof(self) weakSelf = self;
    [[self player] seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (weakSelf.isPlaying) {
            [weakSelf doPlay];
        }
    }];
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
    if ([self.playerDelegate respondsToSelector:@selector(playerViewDidFinishWithError:)]) {
        [self.playerDelegate playerViewDidFinishWithError:nil];
    }
}

- (void)videoFinishedCallback:(NSNotification*)notification {
    [self pause];
    if ([self.playerDelegate respondsToSelector:@selector(playerViewDidFinishWithError:)]) {
        [self.playerDelegate playerViewDidFinishWithError:nil];
    }
}

@end
