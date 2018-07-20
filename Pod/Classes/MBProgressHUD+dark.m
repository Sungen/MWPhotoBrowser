//
//  MBProgressHUD+dark.m
//  ContactLive
//
//  Created by server on 16/8/22.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "MBProgressHUD+dark.h"


@implementation MBProgressHUD (dark)

+ (instancetype)showDarkHUDAddedToWindowMessage:(NSString *)msg
                                          delay:(double)delay
{
    return [[self class] showDarkHUDAddedToWindowMessage:msg
                           position:CGPointZero
                              delay:delay];
}

+ (instancetype)showDarkHUDAddedToWindowMessage:(NSString *)msg
                                       position:(CGPoint)point
                                          delay:(double)delay
{
    return [[self class] showDarkHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                            message:msg
                           animated:YES
                           position:point
                              delay:delay];
}

+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                             delay:(double)delay
{
    
    return [[self class] showDarkHUDAddedTo:view
                            message:msg
                           position:CGPointMake(0., 0-view.bounds.size.height/6.)
                              delay:delay];
}

+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                          position:(CGPoint)point
                             delay:(double)delay
{
    return [[self class] showDarkHUDAddedTo:view
                            message:msg
                           animated:YES
                           position:point
                              delay:delay];
}

+ (instancetype)showDarkIndeterminateHudAddedTo:(UIView *)view
                                        message:(NSString *)message
                                          delay:(double)delay
{
    if (!view) return nil;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud.mode != MBProgressHUDModeIndeterminate) hud = nil;
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.contentColor = [UIColor whiteColor];
        hud.label.numberOfLines = 0;
    }
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:delay];
    
    return hud;
}

+ (instancetype)showDarkIndeterminateToWindowMessage:(NSString *)message
                                               delay:(double)delay
{
    return [[self class] showDarkIndeterminateHudAddedTo:[[UIApplication sharedApplication] keyWindow]
                                         message:message
                                           delay:delay];
}

+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                          animated:(BOOL)animated
                          position:(CGPoint)point
                             delay:(double)time
{
    if (!view) return nil;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud.mode != MBProgressHUDModeText) hud = nil;
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeText;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.contentColor = [UIColor whiteColor];
        hud.label.numberOfLines = 0;
    }
    hud.label.text = msg;
    hud.offset = point;
    [hud hideAnimated:animated afterDelay:time];
    
    return hud;
}


+ (instancetype)showDarkHUDAddedTo:(UIView *)view
                           message:(NSString *)msg
                             delay:(double)delay
                        customView:(UIView *)customView
{
    if (!view) return nil;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud.mode != MBProgressHUDModeCustomView) hud = nil;
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeCustomView;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.contentColor = [UIColor whiteColor];
        hud.label.numberOfLines = 0;
    }
    hud.label.text = msg;
    hud.customView = customView;
    [hud hideAnimated:YES afterDelay:delay];
    
    return hud;
}


+ (instancetype)showSuccessInfoInView:(UIView *)view
                              message:(NSString *)msg
                                delay:(double)delay
{
    return [self showDarkHUDAddedTo:view
                     message:msg
                       delay:delay
                  customView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_result"]]];
    
}


+ (instancetype)showFailInfoInView:(UIView *)view
                           message:(NSString *)msg
                             delay:(double)delay
{
    return [self showDarkHUDAddedTo:view
                     message:msg
                       delay:delay
                  customView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error_result"]]];
}

@end
