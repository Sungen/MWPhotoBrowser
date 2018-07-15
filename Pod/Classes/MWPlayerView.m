//
//  MWPlayerView.m
//  MWPhotoBrowser-iOS7.0
//
//  Created by Junyang Wu on 2018/7/16.
//

#import "MWPlayerView.h"

@implementation MWPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

+ (instancetype)playerViewWithURL:(NSURL *)url frame:(CGRect)frame {
    MWPlayerView *playerView = [[MWPlayerView alloc] initWithFrame:frame];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    [[playerView playerLayer] setPlayer:player];
    return playerView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = NO;
        self.exclusiveTouch = NO;
    }
    return self;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayerItem *)playerItem {
    return [self player].currentItem;
}

- (AVPlayer *)player {
    return [self.playerLayer player];
}
@end
