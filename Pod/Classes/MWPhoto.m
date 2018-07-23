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

@end

@implementation MWPhoto

#pragma mark - Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithURL:url];
}

+ (MWPhoto *)videoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithVideoURL:url];
}

#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
        self.underlyingImage = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = url;
    }
    return self;
}

- (id)initWithVideoURL:(NSURL *)url {
    if ((self = [super init])) {
        self.videoURL = url;
        self.isVideo = YES;
    }
    return self;
}

#pragma mark - Video

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.isVideo = YES;
}

- (BOOL)emptyImage {
    if (_photoURL || _image) {
        _emptyImage = YES;
    }else {
        _emptyImage = NO;
    }
    return _emptyImage;
}

- (void)setPhotoURL:(NSURL *)photoURL {
    _photoURL = photoURL;
    self.emptyImage = NO;
}

- (UIImage *)underlyingImage {
    if (_image) {
        return _image;
    }else if (_underlyingImage) {
        return _underlyingImage;
    }
    return nil;
}

@end
