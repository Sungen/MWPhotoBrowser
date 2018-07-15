//
//  MWPlayerView.h
//  Pods
//
//  Created by Junyang Wu on 2018/7/16.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface MWPlayerView : UIView

+ (instancetype)playerViewWithURL:(NSURL *)url frame:(CGRect)frame;
- (AVPlayerItem *)playerItem;
- (AVPlayerLayer *)playerLayer;
- (AVPlayer *)player;

@end
