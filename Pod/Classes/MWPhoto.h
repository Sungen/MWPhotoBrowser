//
//  MWPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to MWPhotoProtocol

@interface MWPhoto : NSObject

@property (nonatomic, strong) NSString *caption; // 标题

@property (nonatomic, strong) UIImage *image; // 文件方式
+ (instancetype)photoWithImage:(UIImage *)image;

@property (nonatomic, strong) NSURL *videoURL;
+ (instancetype)videoWithURL:(NSURL *)url; // Initialise video with no poster image

@property (nonatomic, strong) NSURL *photoURL;
+ (instancetype)photoWithURL:(NSURL *)url;

@property (nonatomic, strong) NSArray<MWPhoto *> *photoArray;
+ (instancetype)photoWithPhotoArray:(NSArray<MWPhoto *> *)photoArray; // only photo, not video;

@property (nonatomic, strong) UIImage *underlyingImage;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property (nonatomic) BOOL isMorePhoto;

@end

