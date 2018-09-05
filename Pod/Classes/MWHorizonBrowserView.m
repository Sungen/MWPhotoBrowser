//
//  MWHoizonBrowser.m
//  MWPhotoBrowser-MWPhotoBrowser
//
//  Created by xunlei on 2018/8/30.
//

#import "MWHorizonBrowserView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MWHorizonBrowserView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation MWHorizonBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleBottomMargin);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// 透明背景 空白区域 不接受对自己的点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backButton.frame = CGRectMake(16, 22, 44, 44);
    self.collectionView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-80, CGRectGetWidth(self.bounds), 80);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10.f;
        layout.minimumInteritemSpacing = 10.f;
        layout.headerReferenceSize = CGSizeZero;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.allowsSelection = YES;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor blackColor];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"xxx__yyy"];
        
        [self addSubview:collectionView];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageBack" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        //    [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageBackTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        _backButton = button;
    }
    return _backButton;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"xxx__yyy" forIndexPath:indexPath];
    UIImageView *imageView = [[cell contentView] viewWithTag:1111];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.tag = 1111;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:imageView];
    }
    MWPhoto *photo = _photoArray[indexPath.row];
    if (photo.underlyingImage) {
        imageView.image = photo.underlyingImage;
    } else {
        [imageView sd_setImageWithURL:photo.photoURL placeholderImage:nil];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(horizonBrowserViewDidSelectIndex:)]) {
        [self.delegate horizonBrowserViewDidSelectIndex:indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(44, 44);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat totalCellWidth = _photoArray.count * 44.;
    CGFloat totalSpaceWith = (_photoArray.count - 1) * 10.;
    CGFloat leftInset = (CGRectGetWidth(collectionView.bounds) - (totalCellWidth + totalSpaceWith)) / 2;
    CGFloat rightInset = leftInset;
    return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
}

@end
