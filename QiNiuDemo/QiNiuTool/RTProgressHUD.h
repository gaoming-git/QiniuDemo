//
//  RTProgressHUD.h
//  BGH-family
//
//  Created by gaoming on 2018/2/3.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RTProgressHUDTipType)
{
    RTProgressHUDTipTypeSuccess = 1,
    RTProgressHUDTipTypeError = 2,
    RTProgressHUDTipTypeInfo = 3,
    RTProgressHUDTipTypeNone = 4,
};

#define DISMISSTIME 1.5

@interface RTProgressHUD : NSObject

/**  成功hud展示 1.5s后消失  */
+(void)showSuccessWithStatus:(NSString *)status;

/**  失败hud展示 1.5s后消失  */
+(void)showErrorWithStatus:(NSString *)status;

/**  提示信息hud展示 1.5s后消失  */
+(void)showInfoWithStatus:(NSString *)status;

/**  进度hud展示 需要调用dismiss手动消失 */
+(void)showProgress:(float)progress status:(NSString *)status;

/**  提示信息hud展示 1.5s后消失 type提示类型（成功、错误、信息）complecation信息提示完成后的回调 */
+(void)showWithStatus:(NSString *)status withTipType:(RTProgressHUDTipType)type complecation:(void(^)())complecation;

/**  带菊花的信息hud展示 需要调用dismiss手动消失 status为nil时只有菊花  */
+(void)showWithStatus:(NSString *)status;

/**  消失  */
+(void)dismiss;

/**  带自定义图片和信息的hud展示 需要调用dismiss手动消失  */
+(void)showImage:(NSString *)imageStr status:(NSString *)status;

/**  几秒后消失  */
+(void)dismissAfter:(NSTimeInterval)timeInterval;

/**  积分信息的hud展示 2s消失 scores_pop_icon_price */
+(void)showScoresImage:(NSString *)imageStr status:(NSString *)status complecation:(void(^)())complecation;

@end
