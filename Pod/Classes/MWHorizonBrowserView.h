//
//  MWHoizonBrowser.h
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by xunlei on 2018/8/30.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"

@protocol MWHorizonBrowserViewDelegate <NSObject>
- (void)horizonBrowserViewDidSelectIndex:(NSInteger)index;
@end

@interface MWHorizonBrowserView : UIView
@property(nonatomic, strong) NSArray<MWPhoto *> *photoArray;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, weak) id<MWHorizonBrowserViewDelegate> delegate;
@end
