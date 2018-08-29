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

@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;

//@property(nonatomic, strong) UIButton *menuButton;
@property(nonatomic, strong) UIView   *menuView;

@property(nonatomic, strong) UIView   *bottomView;

@property(nonatomic, strong) UIButton *clipButton;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIButton *moreButton;

@property(nonatomic, weak) id<MWActionViewDelegate> delegate;

- (void)layoutSubviewsExtension;

@end


@interface MWShapeButton : UIButton

@end
