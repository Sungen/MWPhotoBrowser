//
//  MWPhotoBrowser_Private.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "MWZoomingScrollView.h"
#import "MWPlayerView.h"
#import "MWHorizonBrowserView.h"

// Declare private methods of browser
@interface MWPhotoBrowser () <MWPlayerViewDelegate, MWActionViewDelegate, MWHorizonBrowserViewDelegate> {
    
	// Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
	NSArray *_fixedPhotosArray; // Provided via init
	
	// Views
	UIScrollView *_pagingScrollView;
	
	// Paging & layout
	NSMutableSet *_visiblePages, *_recycledPages;
	NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    CGRect _previousLayoutBounds;
	NSUInteger _pageIndexBeforeRotation;
	
	// Navigation & controls
	NSTimer *_controlVisibilityTimer;
    MBProgressHUD *_progressHUD;
    
    // Appearance
    UIStatusBarStyle _previousStatusBarStyle;
    BOOL _previousNavBarHidden;
    
    // Video
    NSUInteger _currentVideoIndex;
    MWActionView *_actionView;
    MWPlayerView *_playerView;
    MWHorizonBrowserView *_browserView;
    
    // Misc
    BOOL _hasBelongedToViewController;
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
    BOOL _leaveStatusBarAlone;
	BOOL _performingLayout;
	BOOL _rotating;
    BOOL _scrolling;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _skipNextPagingScrollViewPositioning;
    BOOL _viewHasAppearedInitially;
}

// Properties
@property (nonatomic, strong) UIActivityViewController *activityViewController;

// Layout
- (void)layoutVisiblePages;
- (void)performLayout;
- (BOOL)presentingViewControllerPrefersStatusBarHidden;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayingPhoto:(MWPhoto *)photo;
- (MWZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

// Data
- (NSUInteger)numberOfPhotos;
- (MWPhoto *)photoAtIndex:(NSUInteger)index;
- (MWPhoto *)thumbPhotoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(MWPhoto *)photo;
- (void)loadAdjacentPhotosIfNecessary:(MWPhoto *)photo;
- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

@end

