//
//  MWPlayerView.h
//  Pods
//
//  Created by Junyang Wu on 2018/7/16.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@protocol MWPlayerViewDelegate <NSObject>

- (void)playerViewDidFinishWithError:(NSError *)error;

@end

@interface MWPlayerView : UIView

@property(nonatomic, weak) id<MWPlayerViewDelegate> delegate;

+ (instancetype)playerViewWithURL:(NSURL *)url frame:(CGRect)frame;

- (void)play;
- (void)pause;

@end
