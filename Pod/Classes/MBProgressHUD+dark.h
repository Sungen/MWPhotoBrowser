//
//  MBProgressHUD+dark.h
//  ContactLive
//
//  Created by server on 16/8/22.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (dark)

//CGPointMake(0., 0-SCREEN_H/6.)
// 此函数在上半屏1/3处显示弹窗
+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                             delay:(double)delay;

+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                          position:(CGPoint)point
                             delay:(double)delay;
// 此函数在中心位置显示弹窗
+ (instancetype)showDarkHUDAddedToWindowMessage:(NSString *)msg
                                          delay:(double)delay;

+ (instancetype)showDarkHUDAddedToWindowMessage:(NSString *)msg
                                       position:(CGPoint)point
                                          delay:(double)delay;

+ (instancetype)showDarkIndeterminateHudAddedTo:(UIView *)view
                                        message:(NSString *)message
                                          delay:(double)delay;
+ (instancetype)showDarkIndeterminateToWindowMessage:(NSString *)message
                                               delay:(double)delay;

+ (instancetype)showSuccessInfoInView:(UIView *)view
                              message:(NSString *)msg
                                delay:(double)delay;

+ (instancetype)showFailInfoInView:(UIView *)view
                           message:(NSString *)msg
                             delay:(double)delay;

@end
