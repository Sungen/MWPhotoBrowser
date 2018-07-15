//
//  UIView+MWActionView.m
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by Junyang Wu on 2018/7/15.
//

#import "MWActionView.h"
#import "UIImage+MWPhotoBrowser.h"

@implementation MCActionView

// 透明背景 空白区域 不接受对自己的点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePrev" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePrevTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypePrev;
    [self addSubview:button];
    self.prevButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageNext" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageNextTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeNext;
    [self addSubview:button];
    self.nextButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageDown" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageDownTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeDown;
    [self addSubview:button];
    self.downButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypePlay;
    [self addSubview:button];
    self.playButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClip" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageClipTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeClip;
    [self addSubview:button];
    self.clipButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShare" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageShareTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeShare;
    [self addSubview:button];
    self.shareButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMore" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageMoreTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MCActionTypeMore;
    [self addSubview:button];
    self.moreButton = button;
}

- (void)tapAction:(UIButton *)button {
    if (self.actionBlock) {
        if (button.tag == MCActionTypePlay) {
            button.tag = MCActionTypePause;
            [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePause" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePauseTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        }else if (button.tag == MCActionTypePause){
            button.tag = MCActionTypePlay;
            [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlay" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImagePlayTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        }
        self.actionBlock(button.tag);
    }
}

@end
