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

@property (nonatomic, strong) UIImage *image; // 文件地址
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) UIImage *underlyingImage;

@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

+ (MWPhoto *)photoWithImage:(UIImage *)image;
+ (MWPhoto *)photoWithURL:(NSURL *)url;
+ (MWPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithVideoURL:(NSURL *)url;

@end

