//
//  MWPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVKit/AVKit.h>
#import "MWCommon.h"
#import "MWPhotoBrowser.h"
#import "MWPhotoBrowserPrivate.h"
#import "SDImageCache.h"
#import "UIImage+MWPhotoBrowser.h"
#import "MBProgressHUD+dark.h"

#define PADDING                  10

@implementation MWPhotoBrowser

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
	}
	return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [self init])) {
		_fixedPhotosArray = photosArray;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
	}
	return self;
}

- (void)_initialisation {
    
    // Defaults
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
    self.hidesBottomBarWhenPushed = YES;
    _hasBelongedToViewController = NO;
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _currentVideoIndex = NSUIntegerMax;
    _zoomPhotosToFill = YES;
    _performingLayout = NO; // Reset on view did appear
    _rotating = NO;
    _scrolling = NO;
    _viewIsActive = NO;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
    _didSavePreviousStateOfNavBar = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)dealloc {
    [self clearCurrentVideo];
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos:NO];
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
}

- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    MWPhoto *current = [self photoAtIndex:self.currentIndex];
    for (MWPhoto *p in copy) {
        if ((id)p != [NSNull null]) {
            if (preserveCurrent && current == p) {
                continue; // skip current
            }
            p.underlyingImage = nil;
        }
    }
    // Release thumbs
    copy = [_thumbPhotos copy];
    for (MWPhoto *p in copy) {
        if ((id)p != [NSNull null]) {
            p.underlyingImage = nil;
        }
    }
}

- (void)didReceiveMemoryWarning {

	// Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos:YES];
	[_recycledPages removeAllObjects];
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

#pragma mark - View Loading

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	// View
    self.view.frame = [UIScreen mainScreen].bounds;
	self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	_pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                          UIViewAutoresizingFlexibleHeight |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin |
                                          UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin);
	_pagingScrollView.pagingEnabled = YES;
	_pagingScrollView.delegate = self;
	_pagingScrollView.showsHorizontalScrollIndicator = NO;
	_pagingScrollView.showsVerticalScrollIndicator = NO;
	_pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	[self.view addSubview:_pagingScrollView];
    
    if (self.displayActionView) {
        // ActionView
        _actionView = [[MWActionView alloc] initWithFrame:[self.view bounds]];
        _actionView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin);
        _actionView.delegate = self;
        
        // PlayerView
        _playerView = [[MWPlayerView alloc] initWithFrame:[self.view bounds]];
        _playerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin);
        _playerView.delegate = self;
        _playerView.actionView = _actionView;
    }
    
    // BrowserView
    if (self.displayHorizonBrowser) {
        _browserView = [[MWHorizonBrowserView alloc] initWithFrame:[self.view bounds]];
        _browserView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin |
                                         UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin);
        _browserView.delegate = self;
        _browserView.photoArray = self->_fixedPhotosArray;
        [_browserView.backButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // Update
    [self reloadData];
    
	// Super
    [super viewDidLoad];
}

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
	// Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // ActionView visibility
    if (self.displayActionView) {
        if (numberOfPhotos > 1) {
            // 左右切换的按钮
            _actionView.prevButton.hidden = _actionView.nextButton.hidden = NO;
        }else {
            _actionView.prevButton.hidden = _actionView.nextButton.hidden = YES;
        }
        if (!_actionView.superview) {
            [self.view addSubview:_actionView];
        }
    }
    
    // browserview visibility
    if (self.displayHorizonBrowser) {
        if (!_browserView.superview) {
            [self.view addSubview:_browserView];
        }
    }
    
    // Update nav
	[self updateNavigation];
    
    // Content offset
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

- (void)showInViewController:(UIViewController *)viewController {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:self animated:YES completion:NULL];
}

#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
    
    // Status bar
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    // Update UI
	[self hideControlsAfterDelay];
    
    // If rotation occured while we're presenting a modal
    // and the index changed, make sure we show the right one now
    if (_currentPageIndex != _pageIndexBeforeRotation) {
        [self jumpToPageAtIndex:_pageIndexBeforeRotation animated:NO];
    }
    
    // Layout
    [self.view setNeedsLayout];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    
    // Autoplay if first is video
    if (!_viewHasAppearedInitially) {
        if (_autoPlayOnAppear) {
            MWPhoto *photo = [self photoAtIndex:_currentPageIndex];
            if ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo) {
                [self playVideoAtIndex:_currentPageIndex];
            }
        }
    }
    
    _viewHasAppearedInitially = YES;
        
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Detect if rotation occurs while we're presenting a modal
    _pageIndexBeforeRotation = _currentPageIndex;
    
    _viewIsActive = NO;
    
    // Controls
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
	// Super
	[super viewWillDisappear:animated];
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent && _hasBelongedToViewController) {
        [NSException raise:@"MWPhotoBrowser Instance Reuse" format:@"MWPhotoBrowser instances cannot be reused."];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) _hasBelongedToViewController = YES;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutVisiblePages];
    MWLog(@"==>>viewWillLayoutSubviews");
}

- (void)layoutVisiblePages {
    
    if (_scrolling) return;
    
	// Flag
	_performingLayout = YES;
    
	// Remember index
	NSUInteger indexPriorToLayout = _currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
    if (!_skipNextPagingScrollViewPositioning) {
        _pagingScrollView.frame = pagingScrollViewFrame;
    }
    _skipNextPagingScrollViewPositioning = NO;
	
	// Recalculate contentSize based on current orientation
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (MWZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
		page.frame = [self frameForPageAtIndex:index];
        if (page.selectedButton) {
            page.selectedButton.frame = [self frameForSelectedButton:page.selectedButton atIndex:index];
        }
        if (page.playButton) {
            page.playButton.frame = [self frameForPlayButton:page.playButton atIndex:index];
        }
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }

	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
	// Reset
	_currentPageIndex = indexPriorToLayout;
	_performingLayout = NO;
    
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	// Remember page index before rotation
	_pageIndexBeforeRotation = _currentPageIndex;
	_rotating = YES;
    
    // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
    if ([self areControlsHidden]) {
        // Force hidden
        
    }
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	_currentPageIndex = _pageIndexBeforeRotation;
	
	// Delay control holding
	[self hideControlsAfterDelay];
    
    // Layout
    [self layoutVisiblePages];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	_rotating = NO;
    
    // Ensure nav bar isn't re-displayed
    if ([self areControlsHidden]) {
        
    }
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
    }

    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
    
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_fixedPhotosArray) {
            _photoCount = _fixedPhotosArray.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (MWPhoto *)photoAtIndex:(NSUInteger)index {
    MWPhoto * photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if (_fixedPhotosArray && index < _fixedPhotosArray.count) {
                photo = [_fixedPhotosArray objectAtIndex:index];
            } else if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (MWPhoto *)thumbPhotoAtIndex:(NSUInteger)index {
    MWPhoto * photo = nil;
    if (index < _thumbPhotos.count) {
        if ([_thumbPhotos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)]) {
                photo = [_delegate photoBrowser:self thumbPhotoAtIndex:index];
            }
            if (photo) [_thumbPhotos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_thumbPhotos objectAtIndex:index];
        }
    }
    return photo;
}

- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self photoAtIndex:index];
    BOOL value = photo.isSelected;
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:)]) {
            value = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:index];
        }
    }
    return value;
}

- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index {
    MWPhoto *photo = [self photoAtIndex:index];
    BOOL value = photo.isSelected;
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
            [self.delegate photoBrowser:self photoAtIndex:index selectedChanged:selected];
        }
    }
    [photo setSelected:!value];
}

- (UIImage *)imageForPhoto:(MWPhoto *)photo {
	if (photo) {
		// Get image or obtain in background
        return [photo underlyingImage];
	}
	return nil;
}

#pragma mark - Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
	
	// Recycle no longer needed pages
    NSInteger pageIndex;
	for (MWZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
			[_recycledPages addObject:page];
            [page.selectedButton removeFromSuperview];
            [page.playButton removeFromSuperview];
            [page prepareForReuse];
			[page removeFromSuperview];
			MWLog(@"Removed page at index %lu", (unsigned long)pageIndex);
		}
	}
	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            // Add new page
			MWZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[MWZoomingScrollView alloc] initWithPhotoBrowser:self];
			}
			[_visiblePages addObject:page];
			[self configurePage:page forIndex:index];

			[_pagingScrollView addSubview:page];
			MWLog(@"Added page at index %lu", (unsigned long)index);
            
            // Add play button if needed
            [self configureVideoForPage:page];
            
            // Add selected button
            [self configureSelectedForPage:page forIndex:index];
		}
	}
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (MWZoomingScrollView *page in _visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	MWZoomingScrollView *thePage = nil;
	for (MWZoomingScrollView *page in _visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (MWZoomingScrollView *)pageDisplayingPhoto:(MWPhoto *)photo {
	MWZoomingScrollView *thePage = nil;
	for (MWZoomingScrollView *page in _visiblePages) {
		if (page.photo == photo) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    page.photo = [self photoAtIndex:index];
}

- (void)configureVideoForPage:(MWZoomingScrollView *)page {
    if (page.displayingVideo) {
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/PlayButtonOverlayLarge" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/PlayButtonOverlayLargeTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [playButton sizeToFit];
        playButton.frame = [self frameForPlayButton:playButton atIndex:index];
        [_pagingScrollView addSubview:playButton];
        page.playButton = playButton;
    }
}

- (void)configureSelectedForPage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index {
    if (self.displaySelectionButtons) {
        UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectedButton setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageSelectedOff" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        UIImage *selectedOnImage = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageSelectedOn" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
        [selectedButton setImage:selectedOnImage forState:UIControlStateSelected];
        [selectedButton sizeToFit];
        selectedButton.adjustsImageWhenHighlighted = NO;
        [selectedButton addTarget:self action:@selector(selectedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        selectedButton.frame = [self frameForSelectedButton:selectedButton atIndex:index];
        [_pagingScrollView addSubview:selectedButton];
        page.selectedButton = selectedButton;
        selectedButton.selected = [self photoIsSelectedAtIndex:index];
    }
}

- (MWZoomingScrollView *)dequeueRecycledPage {
	MWZoomingScrollView *page = [_recycledPages anyObject];
	if (page) {
		[_recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    // Handle 0 photos
    if (![self numberOfPhotos]) {
        // Show controls
        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Handle video on page change
    if (!_rotating && index != _currentVideoIndex) {
        [self clearCurrentVideo];
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) { 
            MWPhoto *photo = [_photos objectAtIndex:i];
            if ((id)photo != [NSNull null]) {
                photo.underlyingImage = nil;
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            MWPhoto *photo = [_photos objectAtIndex:i];
            if ((id)photo != [NSNull null]) {
                photo.underlyingImage = nil;
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    MWPhoto * currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        [self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
    [self updateNavigation];
    
}

- (void)didDisplayPhotoAtIndex:(NSInteger)index {
    MWPhoto *photo = [self photoAtIndex:index];
    if ([photo isMorePhoto]) {
        // We're first on stack so show done button
        _actionView.allButton.hidden = NO;
    }else {
        _actionView.allButton.hidden = YES;
    }
    if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)]) {
        [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
    }
}

- (void)horizonBrowserViewDidSelectIndex:(NSInteger)index {
    [self jumpToPageAtIndex:index animated:YES];
}

- (void)allPhotoButtonTap:(UIButton *)button {
    MWPhoto *photo = [self photoAtIndex:self.currentIndex];
    if (![photo isMorePhoto]) {
        return;
    }
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photo.photoArray];
//    browser.delegate = self;
    browser.displayActionView = NO;
    browser.displayHorizonBrowser = YES;
    browser.displaySelectionButtons = YES;
    browser.zoomPhotosToFill = self.zoomPhotosToFill;
    browser.autoPlayOnAppear = self.autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    [browser showInViewController:self];
}

- (void)loadAdjacentPhotosIfNecessary:(MWPhoto *)photo {
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    page.photo = photo;
                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    page.photo = photo;
                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForPlayButton:(UIButton *)playButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    return CGRectMake(floorf(CGRectGetMidX(pageFrame) - playButton.frame.size.width / 2),
                      floorf(CGRectGetMidY(pageFrame) - playButton.frame.size.height / 2),
                      playButton.frame.size.width,
                      playButton.frame.size.height);
}

- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGFloat padding = 22;
    CGFloat yOffset = 0;
    CGRect selectedButtonFrame = CGRectMake(pageFrame.origin.x + pageFrame.size.width - selectedButton.frame.size.width - padding,
                                            padding + yOffset,
                                            selectedButton.frame.size.width,
                                            selectedButton.frame.size.height);
    return CGRectIntegral(selectedButtonFrame);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
    // Checks
	if (!_viewIsActive || _performingLayout || _rotating) return;
    _scrolling = YES;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
    MWLog(@"==>>scrollViewDidScroll: %@", NSStringFromCGRect(visibleBounds));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
//    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
    _scrolling = NO;
	[self updateNavigation];
}

#pragma mark - Navigation

- (void)updateNavigation {
    
	// Title
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    if (numberOfPhotos > 1) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
            self.title = [_delegate photoBrowser:self titleForPhotoAtIndex:_currentPageIndex];
        }
	} else {
		self.title = nil;
	}
	
    if (self.displayActionView) {
        // Buttons
        _actionView.prevButton.enabled = (_currentPageIndex > 0);
        _actionView.nextButton.enabled = (_currentPageIndex < numberOfPhotos - 1);
        
        // Disable action button if there is no image or it's a video
        MWPhoto *photo = [self photoAtIndex:_currentPageIndex];
        if ([photo underlyingImage] == nil || ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo)) {
            _actionView.shareButton.enabled = NO;
            _actionView.shareButton.tintColor = [UIColor clearColor]; // Tint to hide button
        } else {
            _actionView.shareButton.enabled = YES;
            _actionView.shareButton.tintColor = nil;
        }
    }
	
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
	
	// Change page
	if (index < [self numberOfPhotos]) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage {
    [self showPreviousPhotoAnimated:NO];
}
- (void)gotoNextPage {
    [self showNextPhotoAnimated:NO];
}

- (void)showPreviousPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex-1 animated:animated];
}

- (void)showNextPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex+1 animated:animated];
}

#pragma mark - Interactions

- (void)selectedButtonTapped:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    selectedButton.selected = !selectedButton.selected;
    NSUInteger index = NSUIntegerMax;
    for (MWZoomingScrollView *page in _visiblePages) {
        if (page.selectedButton == selectedButton) {
            index = page.index;
            break;
        }
    }
    if (index != NSUIntegerMax) {
        [self setPhotoSelected:selectedButton.selected atIndex:index];
    }
}

- (void)playButtonTapped:(id)sender {
    // Ignore if we're already playing a video
    if (_currentVideoIndex != NSUIntegerMax) {
        return;
    }
    NSUInteger index = [self indexForPlayButton:sender];
    if (index != NSUIntegerMax) {
        [self playVideoAtIndex:index];
    }
}

- (NSUInteger)indexForPlayButton:(UIView *)playButton {
    NSUInteger index = NSUIntegerMax;
    for (MWZoomingScrollView *page in _visiblePages) {
        if (page.playButton == playButton) {
            index = page.index;
            break;
        }
    }
    return index;
}

#pragma mark - Video

- (void)playVideoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self photoAtIndex:index];
    if (photo.isVideo) {
        
        // Valid for playing
        [self clearCurrentVideo];
        _currentVideoIndex = index;
        [self setVideoPlayButtonVisible:NO atPageIndex:index];

        if (self->_currentVideoIndex != index || !self->_viewIsActive) {
            return;
        }
        
        if (photo.videoURL) {
            [self _playVideo:photo.videoURL atPhotoIndex:index];
        } else {
            [self setVideoPlayButtonVisible:YES atPageIndex:index];
        }
        
    }
}

- (void)_playVideo:(NSURL *)videoURL atPhotoIndex:(NSUInteger)index {
    [_playerView setVideoURL:videoURL];
    
    _playerView.frame = [self frameForPageAtIndex:index];
    [_actionView showPlayerUI:YES];
    [_pagingScrollView addSubview:_playerView];
    
    [_playerView play];
}

- (void)clearCurrentVideo {
    [_actionView showPlayerUI:NO];
    [_playerView pause];
    [_playerView removeFromSuperview];
    [[self pageDisplayedAtIndex:_currentVideoIndex] playButton].hidden = NO;
    _currentVideoIndex = NSUIntegerMax;
}

- (void)setVideoPlayButtonVisible:(BOOL)visible atPageIndex:(NSUInteger)pageIndex {
    if (visible) {
        [[self pageDisplayedAtIndex:pageIndex] playButton].hidden = NO;
    }else {
        [[self pageDisplayedAtIndex:pageIndex] playButton].hidden = YES;
    }
}

#pragma mark - Delegates

- (void)actionViewDidTapAction:(MCActionType)type {
    if (type == MCActionTypePrev) {
        [self gotoPreviousPage];
    }else if (type == MCActionTypeNext) {
        [self gotoNextPage];
    }else if (type == MCActionTypeShare) {
        [self actionButtonPressed:nil];
    }else if (type == MCActionTypeBack) {
        [self doneButtonPressed:_actionView.backButton];
    }else if (type == MCActionTypeAll) {
        [self allPhotoButtonTap:_actionView.allButton];
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didTapAction:atIndex:)]) {
        [self.delegate photoBrowser:self didTapAction:type atIndex:self.currentIndex];
    }
}

- (void)playerViewDidFinishWithError:(NSError *)error {
    [self clearCurrentVideo];
}

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Force visible
    if (![self numberOfPhotos])
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if (!_leaveStatusBarAlone) {
        // Hide status bar
        if (!_isVCBasedStatusBarAppearance) {
            // Non-view controller based
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
            
        } else {
            // View controller based so animate away
            _statusBarShouldBeHidden = hidden;
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {}];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        typeof(self) strongSelf = weakSelf;
        CGFloat alpha = hidden ? 0 : 1;
        
        // Tool
        [strongSelf->_actionView setAlpha:alpha];
        [strongSelf->_actionView showMenu:NO];
        
        // Browser view
        [strongSelf->_browserView setAlpha:alpha];
        
        // Selected buttons
        for (MWZoomingScrollView *page in strongSelf->_visiblePages) {
            if (page.selectedButton) {
                UIButton *v = page.selectedButton;
                CGRect newFrame = [strongSelf frameForSelectedButton:v atIndex:0];
                newFrame.origin.x = v.frame.origin.x;
                v.frame = newFrame;
            }
        }

    } completion:^(BOOL finished) {}];
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	if (!permanent) [self hideControlsAfterDelay];
	
}

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return [self presentingViewControllerPrefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (_controlVisibilityTimer) {
		[_controlVisibilityTimer invalidate];
		_controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	if (![self areControlsHidden]) {
        [self cancelControlHiding];
		_controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (BOOL)areControlsHidden { return ([_actionView alpha] == 0 && _browserView.alpha == 0);}
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)showControls { [self setControlsHidden:NO animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

#pragma mark - Properties

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    // Validate
    NSUInteger photoCount = [self numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [self numberOfPhotos]-1;
    }
    _currentPageIndex = index;
	if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index animated:NO];
        if (!_viewIsActive) {
            [self tilePages]; // Force tiling if view is not visible
        }
    }
}

#pragma mark - Misc

- (void)doneButtonPressed:(id)sender {
    // Dismiss view controller
    if (self.presentingViewController) {
        if ([_delegate respondsToSelector:@selector(photoBrowserDidFinishModalPresentation:)]) {
            // Call delegate method and let them dismiss us
            [_delegate photoBrowserDidFinishModalPresentation:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)actionButtonPressed:(id)sender {

    // Only react when image has loaded
    MWPhoto * photo = [self photoAtIndex:_currentPageIndex];
    if ([self numberOfPhotos] > 0 && [photo underlyingImage]) {
        
        // If they have defined a delegate method then just message them
            
            // Show activity view controller
            NSMutableArray *items = [NSMutableArray arrayWithObject:[photo underlyingImage]];
            self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
            
            // Show loading spinner after a couple of seconds
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.activityViewController) {
                    [self showProgressHUDWithMessage:nil];
                }
            });

            // Show
            typeof(self) __weak weakSelf = self;
            [self.activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                weakSelf.activityViewController = nil;
                [weakSelf hideControlsAfterDelay];
                [weakSelf hideProgressHUD:YES];
            }];
        
            [self presentViewController:self.activityViewController animated:YES completion:nil];
        
        // Keep controls hidden
        [self setControlsHidden:NO animated:YES permanent:YES];

    }
    
}

#pragma mark - Action Progress

- (void)showProgressHUDWithMessage:(NSString *)message {
    _progressHUD = [MBProgressHUD showDarkIndeterminateHudAddedTo:self.view message:message delay:INFINITY];
}

- (void)hideProgressHUD:(BOOL)animated {
    [_progressHUD hideAnimated:animated];
}

@end
