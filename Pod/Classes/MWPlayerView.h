//
//  MWPlayerView.h
//  Pods
//
//  Created by Junyang Wu on 2018/7/16.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "MWActionView.h"


@interface MWPlayerView : UIView

- (void)showPlayerControllers:(BOOL)flag withDelegate:(id<MWActionViewPlayerDelegate> )delegate;

- (void)setVideoURL:(NSURL *)url;
- (void)play;
- (void)pause;

@end
