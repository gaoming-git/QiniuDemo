//
//  RTProgressHUD.m
//  BGH-family
//
//  Created by gaoming on 2018/2/3.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import "RTProgressHUD.h"
#import "SVProgressHUD.h"

@implementation RTProgressHUD

+(void)showSuccessWithStatus:(NSString *)status
{
    [SVProgressHUD showSuccessWithStatus:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD dismissWithDelay:DISMISSTIME];
}

+(void)showErrorWithStatus:(NSString *)status
{
    [SVProgressHUD showErrorWithStatus:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD dismissWithDelay:DISMISSTIME];
}

+(void)showInfoWithStatus:(NSString *)status
{
    [SVProgressHUD showInfoWithStatus:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD dismissWithDelay:DISMISSTIME];
}

+(void)showProgress:(float)progress status:(NSString *)status
{
    [SVProgressHUD showProgress:progress status:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}

+(void)showWithStatus:(NSString *)status
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    if (!status) {
        [SVProgressHUD show];
    }else
    {
        [SVProgressHUD showWithStatus:status];
    }
}

+(void)showWithStatus:(NSString *)status withTipType:(RTProgressHUDTipType)type complecation:(void(^)())complecation
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    if (!status) {
        [SVProgressHUD show];
    }else
    {
        switch (type) {
            case RTProgressHUDTipTypeSuccess:
                [SVProgressHUD showSuccessWithStatus:status];
                break;
            case RTProgressHUDTipTypeError:
                [SVProgressHUD showErrorWithStatus:status];
                break;
            case RTProgressHUDTipTypeInfo:
                [SVProgressHUD showInfoWithStatus:status];
                break;
            case RTProgressHUDTipTypeNone:
                [SVProgressHUD showWithStatus:status];
                break;
            default:
                break;
        }
    }
    [SVProgressHUD dismissWithDelay:DISMISSTIME completion:complecation];
}

+(void)dismiss
{
    [SVProgressHUD dismiss];
}

+(void)showImage:(NSString *)imageStr status:(NSString *)status
{
    [SVProgressHUD showImage:[UIImage imageNamed:imageStr] status:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}

+(void)showScoresImage:(NSString *)imageStr status:(NSString *)status complecation:(void(^)())complecation
{
    [SVProgressHUD showImage:[UIImage imageNamed:imageStr] status:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD dismissWithDelay:2.0 completion:complecation];
}

+(void)dismissAfter:(NSTimeInterval)timeInterval
{
    [SVProgressHUD dismissWithDelay:timeInterval];
}

@end
