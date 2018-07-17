//
//  UIView+MWActionView.h
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by Junyang Wu on 2018/7/15.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MCActionType) {
    MCActionTypePrev = 1,
    MCActionTypeNext,
    
    MCActionTypeDown,
    
    MCActionTypeClip,
    MCActionTypeShare,
    MCActionTypeMore,
};

@protocol MWActionViewDelegate <NSObject>
- (void)actionViewDidTapAction:(MCActionType)type;
@end

#pragma mark -

@interface MWActionView : UIView

@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;

@property(nonatomic, strong) UIButton *downButton;

@property(nonatomic, strong) UIView   *bottomView;

@property(nonatomic, strong) UIButton *clipButton;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIButton *moreButton;

@property(nonatomic, weak) id delegate;

- (void)setViewAlpha:(CGFloat)alpha;
- (CGFloat)viewAlpha;

@end


