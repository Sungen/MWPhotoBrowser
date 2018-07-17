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

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect trackRect = [super trackRectForBounds:bounds];
    if (trackRect.size.height > 2) {
        trackRect.origin.y -= trackRect.size.height - 2;
        trackRect.size.height = 2;
    }
    return trackRect;
}

@end

#pragma mark -

@interface MWPlayerView()

@property(nonatomic, strong) MWPlayerSlider *slider;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;
@property(nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;

@property(nonatomic, assign) BOOL isDraging;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) Float64 duration;
@property(nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation MWPlayerView {
    id _periodObserver;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupPlayerUI];
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
    return [[self playerLayer] player];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.slider.frame = CGRectMake(3, CGRectGetHeight(self.bottomView.bounds)-54, CGRectGetWidth(self.bottomView.bounds)-6, 18);
    self.playButton.frame = CGRectMake(8, CGRectGetMaxY(self.slider.frame), 30, 30);
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+4, CGRectGetMidY(self.playButton.frame)-10, 120, 20);
    self.loadingIndicatorView.center = self.center;
}

- (void)setupPlayerUI {
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 2;
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePause" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePauseTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:button];
    self.playButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:1.0*0x55/0xff green:1.0*0x55/0xff blue:1.0*0x55/0xff alpha:1.0];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    label.textAlignment = NSTextAlignmentLeft;
    [self.bottomView addSubview:label];
    self.timeLable = label;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    aiv.hidesWhenStopped = YES;
    [self addSubview:aiv];
    self.loadingIndicatorView = aiv;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [tap setNumberOfTouchesRequired:1];
    [self.slider addGestureRecognizer:tap];
    self.tap = tap;
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
    self.duration = duration;
    CMTime interval = duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
    __weak typeof(self) weakSelf = self;
    _periodObserver = [[self player] addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isDraging) {
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *timeText = [NSString stringWithFormat:@"%@/%@", [weakSelf convertTime:currentTime], [weakSelf convertTime:duration]];
            weakSelf.timeLable.text = timeText;
            [weakSelf.slider setValue:(currentTime/duration) animated:YES];
        }
    }];
    [[self playerItem] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removePlayNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self playerItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:[self playerItem]];
    if (_periodObserver) {
        [[self player] removeTimeObserver:_periodObserver];
        _periodObserver = nil;
        [[self playerItem] removeObserver:self forKeyPath:@"status"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
//        AVPlayerItem *item = (AVPlayerItem *)object;
        [self.loadingIndicatorView stopAnimating];
    }
}

#pragma mark -

- (void)setVideoURL:(NSURL *)url {
    [self pause];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    [[self playerLayer] setPlayer:player];
}

- (void)play {
    if (self.isPlaying) return;
    self.isPlaying = YES;
    [self.loadingIndicatorView startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self removePlayNotifications];
    
    [self addPlayNotifications];
    
    [[self player] play];
}

- (void)pause {
    if (!self.isPlaying) return;
    self.isPlaying = NO;
    [self.loadingIndicatorView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self removePlayNotifications];
    [[self player] pause];
}

#pragma mark -

- (void)setViewAlpha:(CGFloat)alpha {
    for (UIView *subView in self.subviews) {
        subView.alpha = alpha;
    }
}

- (CGFloat)viewAlpha {
    return [[[self subviews] lastObject] alpha];
}

#pragma mark -

- (void)playAction:(UIButton *)button {
    if (button.tag == 1) {
        button.tag = 2;
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePause" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePauseTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [self play];
    }else if (button.tag == 2){
        button.tag = 1;
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [self pause];
    }
}

- (void)sliderValueDidChanged:(UISlider *)slider {
    NSLog(@"==>>sliderValueDidChanged");
    Float64 duration = self.duration;
    Float64 now = slider.value * duration;
    NSString *timeText = [NSString stringWithFormat:@"%@/%@", [self convertTime:now], [self convertTime:duration]];
    self.timeLable.text = timeText;
    [self.slider setValue:(now/duration) animated:YES];
    [[self player] seekToTime:CMTimeMake(now, 1)];
}

- (void)sliderDidTouchUp:(UISlider *)slider {
    NSLog(@"==>>sliderDidTouchUp");
    self.isDraging = NO;
    self.tap.enabled = YES;
    if (self.isPlaying) {
        [[self player] play];
    }
}

- (void)sliderDidTouchDown:(UISlider *)slider {
    NSLog(@"==>>sliderDidTouchDown");
    self.isDraging = YES;
    self.tap.enabled = NO;
    if (self.isPlaying) {
        [[self player] pause];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    NSLog(@"==>>tap");
    CGPoint point = [tap locationInView:self.slider];
    CGFloat value = point.x / CGRectGetWidth(self.slider.frame);
    [self.slider setValue:value animated:YES];
    Float64 duration = self.duration;
    CMTime time = CMTimeMake(duration * value, 1);
    [[self player] seekToTime:time];
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
