//
//  MWPlayerView.h
//  Pods
//
//  Created by Junyang Wu on 2018/7/16.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "MWActionView.h"

@protocol MWPlayerViewDelegate <NSObject>

- (void)playerViewDidFinishWithError:(NSError *)error;

@end

@interface MWPlayerView : MWActionView

- (void)setVideoURL:(NSURL *)url;
- (void)play;
- (void)pause;

@end
