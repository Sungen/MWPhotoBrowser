//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>

#import "FLAnimatedImageView+WebCache.h"
#import "UIImage+MultiFormat.h"
#import "NSData+ImageContentType.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

@interface MWPhoto() {
    UIImage *_underlyingImage;
}
@property (nonatomic, assign) BOOL emptyImage;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, assign) BOOL isMorePhoto;

@end

@implementation MWPhoto

#pragma mark - Class Methods

+ (instancetype)photoWithImage:(UIImage *)image {
    return [[MWPhoto alloc] initWithImage:image];
}

+ (instancetype)photoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithURL:url];
}

+ (instancetype)photoWithPhotoArray:(NSArray<MWPhoto *> *)photoArray {
    return [[MWPhoto alloc] initWithPhotoArray:photoArray];
}

+ (instancetype)videoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithVideoURL:url];
}

#pragma mark - Init

- (instancetype)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
        self.underlyingImage = image;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = url;
    }
    return self;
}

- (instancetype)initWithPhotoArray:(NSArray<MWPhoto *> *)photoArray {
    if ((self = [super init])) {
        self.photoArray = photoArray;
        MWPhoto *photo = (MWPhoto *)[photoArray firstObject];
        self.photoURL = [photo photoURL];
        self.image = [photo image];
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)url {
    if ((self = [super init])) {
        self.videoURL = url;
        self.isVideo = YES;
    }
    return self;
}

#pragma mark - Video

- (BOOL)isVideo {
    if (_videoURL) {
        _isVideo = YES;
    }
    return _isVideo;
}

- (BOOL)isMorePhoto {
    if (_photoArray) {
        _isMorePhoto = YES;
    }
    return _isMorePhoto;
}

- (BOOL)emptyImage {
    if (_photoURL || _image) {
        _emptyImage = NO;
    }else {
        _emptyImage = YES;
    }
    return _emptyImage;
}

- (BOOL)isLocal {
    if ([_photoURL isFileURL] ||
        [_videoURL isFileURL] ||
        _image) {
        _isLocal = YES;
    }
    return _isLocal;
}

- (UIImage *)underlyingImage {
    if (_image) {
        return _image;
    }
    return _underlyingImage;
}

@end
