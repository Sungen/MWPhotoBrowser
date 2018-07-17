//
//  UIView+MWActionView.m
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by Junyang Wu on 2018/7/15.
//

#import "MWActionView.h"
#import "UIImage+MWPhotoBrowser.h"

@implementation MWShapeButton
+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CAShapeLayer *borderLayer = (CAShapeLayer *)self.layer;
    borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;
//    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:CGRectGetWidth(borderLayer.bounds)/2].CGPath;
    borderLayer.lineWidth = 1. / [[UIScreen mainScreen] scale];
    //虚线边框
    borderLayer.lineDashPattern = @[@4, @4];
    //实线边框
//    borderLayer.lineDashPattern = nil;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
}

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


@implementation MWActionView

// 透明背景 空白区域 不接受对自己的点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.bottomView) {
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.prevButton.frame = CGRectMake(16, CGRectGetMidY(self.bounds)-15, 30, 30);
    self.nextButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-16-30, CGRectGetMinY(self.prevButton.frame), 30, 30);
    self.menuButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-20-30, CGRectGetHeight(self.bounds)-72-30, 30, 30);
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-54, CGRectGetWidth(self.bounds), 54);
    self.moreButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds)-16-30, CGRectGetHeight(self.bottomView.bounds)-8-30, 30, 30);
    self.shareButton.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame)-16-30, CGRectGetMinY(self.moreButton.frame), 30, 30);
    self.clipButton.frame = CGRectMake(CGRectGetMinX(self.shareButton.frame)-16-30, CGRectGetMinY(self.moreButton.frame), 30, 30);
    self.menuView.frame = CGRectMake(CGRectGetWidth(self.bounds)-190, CGRectGetHeight(self.bounds)-70-90, 190, 91);
    
    self.slider.frame = CGRectMake(3, CGRectGetHeight(self.bottomView.bounds)-54, CGRectGetWidth(self.bottomView.bounds)-6, 18);
    self.playButton.frame = CGRectMake(8, CGRectGetMaxY(self.slider.frame), 30, 30);
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+4, CGRectGetMidY(self.playButton.frame)-10, 120, 20);
}

- (void)setupPlayerUIWithTarget:(id)target {
    MWPlayerSlider *slider = [[MWPlayerSlider alloc] initWithFrame:CGRectZero];
    UIImage *image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageSlider" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
    [slider setThumbImage:image forState:UIControlStateNormal];
    slider.minimumTrackTintColor = [UIColor colorWithRed:1.0*0xc8/0xff green:1.0*0x17/0xff blue:1.0*0x1e/0xff alpha:1.0];
    slider.maximumTrackTintColor = [UIColor colorWithRed:1.0*0x8c/0xff green:1.0*0x8c/0xff blue:1.0*0x8c/0xff alpha:1.0];
    [slider addTarget:target action:@selector(sliderDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:target action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:target action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:target action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.bottomView addSubview:slider];
    self.slider = slider;
    slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    UIButton *button = [MWShapeButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tap:)];
    [tap setNumberOfTouchesRequired:1];
    [self.slider addGestureRecognizer:tap];
    self.tap = tap;
    
    [self showPlayerUI:NO];
}

- (void)showPlayerUI:(BOOL)flag {
    self.slider.hidden = self.playButton.hidden = self.timeLable.hidden = !flag;
    self.tap.enabled = flag;
}

- (void)setupView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePrev" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePrevTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypePrev;
    [self addSubview:button];
    self.prevButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    button.frame = CGRectMake(16, CGRectGetMidY(self.bounds)-15, 30, 30);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageNext" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageNextTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeNext;
    [self addSubview:button];
    self.nextButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetWidth(self.bounds)-16-30, CGRectGetMinY(self.prevButton.frame), 30, 30);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageDown" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageDownTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeMenu;
    [self addSubview:button];
    self.menuButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//    button.frame = CGRectMake(CGRectGetWidth(self.bounds)-20-30, CGRectGetHeight(self.bounds)-72, 30, 30);
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectZero];
    toolView.backgroundColor = [UIColor blackColor];
    [self addSubview:toolView];
    self.bottomView = toolView;
    toolView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
//    toolView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-54, CGRectGetWidth(self.bounds), 54);
    
    button = [MWShapeButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMore" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMoreTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeMore;
    [toolView addSubview:button];
    self.moreButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetWidth(toolView.bounds)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
    
    button = [MWShapeButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShare" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShareTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeShare;
    [toolView addSubview:button];
    self.shareButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
    
    button = [MWShapeButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClip" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClipTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeClip;
    [toolView addSubview:button];
    self.clipButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetMinX(self.clipButton.frame)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
    
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 91)];
    menuView.backgroundColor = [UIColor colorWithRed:1.0*0x10/0xff green:1.0*0x10/0xff blue:1.0*0x10/0xff alpha:1.0];
    menuView.hidden = YES;
    [self addSubview:menuView];
    self.menuView = menuView;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"下载到本地" forState:UIControlStateNormal];
    [button setTitle:@"下载到本地" forState:UIControlStateHighlighted];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeDownToLocal;
    [self.menuView addSubview:button];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    button.frame = CGRectMake(12, 0, 178, 45);
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(12, 45, 178, 1/[UIScreen mainScreen].scale)];
    sepView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:sepView];
    sepView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"删除" forState:UIControlStateNormal];
    [button setTitle:@"删除" forState:UIControlStateHighlighted];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeDelete;
    [self.menuView addSubview:button];
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    button.frame = CGRectMake(12, 46, 178, 45);
}

- (void)tapAction:(UIButton *)button {
    if (button.tag == MCActionTypeMenu) {
        self.menuView.hidden = NO;
    }else if (button.tag == MCActionTypeDownToLocal || button.tag == MCActionTypeDelete){
        self.menuView.hidden = YES;
    }
    if ([self.delegate respondsToSelector:@selector(actionViewDidTapAction:)]) {
        [self.delegate actionViewDidTapAction:button.tag];
    }
}

@end
