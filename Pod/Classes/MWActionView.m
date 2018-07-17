//
//  UIView+MWActionView.m
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by Junyang Wu on 2018/7/15.
//

#import "MWActionView.h"
#import "UIImage+MWPhotoBrowser.h"

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
    self.downButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-20-30, CGRectGetHeight(self.bounds)-72, 30, 30);
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-54, CGRectGetWidth(self.bounds), 54);
    self.moreButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds)-16-30, CGRectGetHeight(self.bottomView.bounds)-8-30, 30, 30);
    self.shareButton.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame)-16-30, CGRectGetMinY(self.moreButton.frame), 30, 30);
    self.clipButton.frame = CGRectMake(CGRectGetMinX(self.shareButton.frame)-16-30, CGRectGetMinY(self.moreButton.frame), 30, 30);
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
    button.tag = MCActionTypeDown;
    [self addSubview:button];
    self.downButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//    button.frame = CGRectMake(CGRectGetWidth(self.bounds)-20-30, CGRectGetHeight(self.bounds)-72, 30, 30);
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectZero];
    toolView.backgroundColor = [UIColor blackColor];
    [self addSubview:toolView];
    self.bottomView = toolView;
    toolView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
//    toolView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-54, CGRectGetWidth(self.bounds), 54);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMore" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMoreTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeMore;
    [toolView addSubview:button];
    self.moreButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetWidth(toolView.bounds)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShare" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShareTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeShare;
    [toolView addSubview:button];
    self.shareButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClip" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClipTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeClip;
    [toolView addSubview:button];
    self.clipButton = button;
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//    button.frame = CGRectMake(CGRectGetMinX(self.clipButton.frame)-16-30, CGRectGetMinY(self.playButton.frame), 30, 30);
}

- (void)tapAction:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(actionViewDidTapAction:)]) {
        [self.delegate actionViewDidTapAction:button.tag];
    }
}

#pragma mark -

- (void)setViewAlpha:(CGFloat)alpha {
    self.alpha = alpha;
}

- (CGFloat)viewAlpha {
    return self.alpha;
}

@end
