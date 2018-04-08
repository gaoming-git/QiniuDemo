//
//  SLTTool.h
//  RainbowBridge
//
//  Created by Zontonec on 16/12/5.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UMShare/UMShare.h>

@interface SLTTool : NSObject

/** 七牛视频截图 */
+(NSString *)getQiNiuVideoPhotoWithVideoUrl:(NSString *)url width:(CGFloat)width height:(CGFloat)height;

//通过时分时间转为当前时间段（23:59 ---> 2018-02-08 23:59:00）
+(NSString *)getFullTimeWithNotFullTime:(NSString *)noFullTime;
/**
 *  判断当前时间是否处于某个时间段内
 *
 *  @param startTime        开始时间
 *  @param expireTime       结束时间
 */
+ (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime;

//时间转时间戳 
+(long)getStampFromTime:(NSString *)time;

//时间戳转时间 2018-02-08 14:26:35
+(NSString *)getTimeFromStamp:(NSTimeInterval)stamp;

//小数点后两位向上进1.如：1.333333 取 1.34
+(NSString *)getPriceWithPrice:(CGFloat)price;

//按比例系数拉伸图片
+(UIImage *)stretchableImageStr:(NSString *)imageStr withWidthScale:(CGFloat)widthScale withHeightScale:(CGFloat)heightScale;

//颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color;
//颜色转图片
+ (UIImage *)getImageWithColor:(UIColor *)color andHeight:(CGFloat)height;

//计算自适应字符串的宽度或高度
+(CGSize)caculateSizeWithDesc:(NSString *)desc withLimitSize:(CGSize)limitSize withFont:(UIFont *)font;

//分别根据时间戳与标准时间计算: 几分钟之前，几小时之前...
+ (NSString *)timeBeforeInfoWithString:(NSTimeInterval)timeIntrval;

// 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber;

#pragma mark - 时间比较大小
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;

#pragma mark - 判断一个字符串是否为空
+(BOOL)IsNotEmptyWithStr:(NSString *)str;

//获取当前时间 格式：yyyyMMdd
+ (NSString *)getCurrentTime;

//date转string 格式：yyyy-MM-dd
+ (NSString *)dateToNSString:(NSDate *)date;

//date转string 格式：yyyy-MM
+ (NSString *)dateToNotAllString:(NSDate *)date;

//获取当前详细时间 格式：yyyyMMdd HHmmss
+ (NSString *)getCurrentDetailTime;

//获取当前时分秒 格式：HHmmss
+ (NSString *)getCurrentHourTime;

//获取时间搓 精确到秒
+ (NSString *)currentTimeSince1970;

//获取设备uuid
+(NSString *)getDeviceUUID;

//MD5加密
+ (NSString *)md5String:(NSString *)str;

#pragma mark - 转换返回参数中null
+ (id)changeType:(id)myObj;

#pragma mark - 表情转码 -
+(NSString *)phizEncodingWithStr:(NSString *)str;

#pragma mark - 表情解码 -
+(NSString *)phizDecodingWithStr:(NSString *)str;

#pragma mark - 计算生日 -
+ (NSString *)calculateBirthWithBirthday:(NSString *)birthday;

#pragma mark - 比较版本的方法，在这里我用的是Version来比较的
+ (BOOL)compareVersionsFormAppStore:(NSString*)AppStoreVersion WithAppVersion:(NSString*)AppVersion;

//传进来图片的URL，返回缩略图的URL
+(NSString *)setSltUrlWithImageUrl:(NSString *)url;

@end
