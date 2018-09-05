//
//  UIView+MWActionView.h
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by Junyang Wu on 2018/7/15.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, MCActionType) {
    MCActionTypeBack = 1,
    MCActionTypeAll,
    
    MCActionTypePrev,
    MCActionTypeNext,
    
    MCActionTypeMenu,
    MCActionTypeDownToLocal,
    MCActionTypeDelete,
    
    MCActionTypeClip,
    MCActionTypeShare,
    MCActionTypeMore,
};

@protocol MWActionViewDelegate <NSObject>
- (void)actionViewDidTapAction:(MCActionType)type;
@end

#pragma mark -

@interface MWActionView : UIView

@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *allButton;

@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;

//@property(nonatomic, strong) UIButton *menuButton;
@property(nonatomic, strong) UIView   *menuView;

@property(nonatomic, strong) UIView   *bottomView;

@property(nonatomic, strong) UIButton *clipButton;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIButton *moreButton;

@property(nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;
@property(nonatomic, strong) UITapGestureRecognizer *tap;

@property(nonatomic, weak) id<MWActionViewDelegate> delegate;

- (void)setupPlayerUIWithTarget:(id)target;
- (void)showPlayerUI:(BOOL)flag;
- (void)showMenu:(BOOL)flag;

@end


@interface MWShapeButton : UIButton

@end


@interface MWPlayerSlider : UISlider

@end



