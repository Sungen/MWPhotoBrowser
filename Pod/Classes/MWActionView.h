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
    
    MCActionTypePlay,
    MCActionTypePause,
    
    MCActionTypeClip,
    MCActionTypeShare,
    MCActionTypeMore,
};

@interface MCActionView : UIView

@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;

@property(nonatomic, strong) UIButton *downButton;

@property(nonatomic, strong) UIView *progressView;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;

@property(nonatomic, strong) UIButton *clipButton;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIButton *moreButton;

@property(nonatomic, copy) void(^actionBlock)(MCActionType type);

@end
