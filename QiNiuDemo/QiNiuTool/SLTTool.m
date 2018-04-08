//
//  SLTTool.m
//  RainbowBridge
//
//  Created by Zontonec on 16/12/5.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "SLTTool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SLTTool

+ (UIImage *)imageWithColor:(UIColor *)color {
    //创建1像素区域并开始图片绘图
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    
    //创建画板并填充颜色和区域
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    //从画板上获取图片并关闭图片绘图
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)getImageWithColor:(UIColor *)color andHeight:(CGFloat)height {
    CGRect r = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+(NSString *)getQiNiuVideoPhotoWithVideoUrl:(NSString *)url width:(CGFloat)width height:(CGFloat)height
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?vframe/jpg/offset/0/w/%.f/h/%.f", url,width,height];
    return urlStr;
}

+(NSString *)getFullTimeWithNotFullTime:(NSString *)noFullTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *fullDateStr = [NSString stringWithFormat:@"%@ %@:00",dateString,noFullTime];
    return fullDateStr;
}

/**
 *  判断当前时间是否处于某个时间段内
 *
 *  @param startTime        开始时间
 *  @param expireTime       结束时间
 */

+ (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime {
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+(long)getStampFromTime:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //指定时间显示样式: HH表示24小时制 hh表示12小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *lastDate = [formatter dateFromString:time];
    //以 1970/01/01 GMT为基准，得到lastDate的时间戳
    long firstStamp = [lastDate timeIntervalSince1970];
    return firstStamp;
}

+(NSString *)getTimeFromStamp:(NSTimeInterval)stamp
{
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //以 1970/01/01 GMT为基准，然后过了secs秒的时间
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:stamp];
    return [stampFormatter stringFromDate:stampDate];
}

+(NSString *)getPriceWithPrice:(CGFloat)price
{
    CGFloat temPrice = price*100;
    NSString *tempStr = [NSString stringWithFormat:@"%f",temPrice];
    NSArray *strArray = [tempStr componentsSeparatedByString:@"."];
    NSString *singleStr = [[strArray lastObject] substringToIndex:1];
    if ([singleStr isEqualToString:@"0"]) {
        NSString *aa = [strArray firstObject];
        return [NSString stringWithFormat:@"%.2f",aa.floatValue/100];
    }else
    {
        CGFloat newPrice = ceilf(temPrice)/100;
        return [NSString stringWithFormat:@"%.2f",newPrice];
    }
}

+(UIImage *)stretchableImageStr:(NSString *)imageStr withWidthScale:(CGFloat)widthScale withHeightScale:(CGFloat)heightScale
{
    // 加载图片
    UIImage *image = [UIImage imageNamed:imageStr];
    
    // 设置左边端盖宽度
    NSInteger leftCapWidth = image.size.width * widthScale;
    // 设置上边端盖高度
    NSInteger topCapHeight = image.size.height * heightScale;
    
    UIImage *newImage = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    
    return newImage;
}

//计算自适应字符串的宽度或高度
+(CGSize)caculateSizeWithDesc:(NSString *)desc withLimitSize:(CGSize)limitSize withFont:(UIFont *)font
{
    CGSize titleSize = [desc boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return titleSize;
}

+ (NSString *)timeBeforeInfoWithString:(NSTimeInterval)timeIntrval{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
    int timeInt = nowTimeinterval - timeIntrval; //时间差
    
    int year = timeInt / (3600 * 24 * 30 *12);
    int month = timeInt / (3600 * 24 * 30);
    int day = timeInt / (3600 * 24);
    int hour = timeInt / 3600;
    int minute = timeInt / 60;
    int second = timeInt;
    if (year > 0) {
        return [NSString stringWithFormat:@"%d年以前",year];
    }else if(month > 0){
        return [NSString stringWithFormat:@"%d个月以前",month];
    }else if(day > 0){
        return [NSString stringWithFormat:@"%d天以前",day];
    }else if(hour > 0){
        return [NSString stringWithFormat:@"%d小时以前",hour];
    }else if(minute > 0){
        return [NSString stringWithFormat:@"%d分钟以前",minute];
    }else{
        return [NSString stringWithFormat:@"刚刚"];
    }
}

// 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber
{
    if (telNumber.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    /**
     25     * 大陆地区固话及小灵通
     26     * 区号：010,020,021,022,023,024,025,027,028,029
     27     * 号码：七位或八位
     28     */
    //  NSString * PHS = @"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:telNumber] == YES)
        || ([regextestcm evaluateWithObject:telNumber] == YES)
        || ([regextestct evaluateWithObject:telNumber] == YES)
        || ([regextestcu evaluateWithObject:telNumber] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 时间比较大小
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        //oneDay > anotherDay
        return 1;
    }
    else if (result == NSOrderedAscending){
        //oneDay < anotherDay
        return -1;
    }
    //oneDay = anotherDay
    return 0;
}

+ (NSString *)calculateBirthWithBirthday:(NSString *)birthday
{
    //根据生日精确计算年龄
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    
    NSDate *nowDate = [NSDate date];
    
    NSString *birth = birthday;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //生日
    NSDate *birthDay = [dateFormatter dateFromString:birth];
    //    NSDate *nowDate = [dateFormatter ];
    //用来得到详细的时差
    NSDateComponents *date = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:birthDay toDate:nowDate options:0];
    NSString *ageStr = [[NSString alloc] init];
    if([date year] > 0)
    {
        ageStr = [NSString stringWithFormat:(@"%ld岁%ld月%ld天"),(long)[date year],(long)[date month],(long)[date day]];
    }
    else if([date month] > 0)
    {
        ageStr = [NSString stringWithFormat:(@"%ld月%ld天"),(long)[date month],(long)[date day]];
    }
    else if([date day] > 0)
    {
        ageStr = [NSString stringWithFormat:(@"%ld天"),(long)[date day]];
    }
    else
    {
        ageStr = @"0天";
    }
    return ageStr;
}

#pragma mark - 判断一个字符串是否为空
+(BOOL)IsNotEmptyWithStr:(NSString *)str
{
    return (str != nil && [str isKindOfClass:[NSString class]]  && str.length);
}

//获取当前时间
+ (NSString *)getCurrentTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    return dateString;
}

+ (NSString *)dateToNSString:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString *)dateToNotAllString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString *)getCurrentDetailTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    return dateString;
}

+ (NSString *)getCurrentHourTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    return dateString;
}

//获取当前时间戳
+ (NSString *)currentTimeSince1970{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+(NSString *)getDeviceUUID
{
//    NSString *uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString *uuid =[[NSUUID UUID] UUIDString];
    NSString *temUUID = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *newUUID = [temUUID lowercaseString];
    return newUUID;
}

//MD5加密
+ (NSString *)md5String:(NSString *)str
{
    const char *cStr = [str UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr , (uint32_t)str.length , digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        
        [result appendFormat:@"%02x",digest[i]];
    }
    return result;
}

#pragma mark - 转换返回参数中null
+ (id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]])
    {
        return [self nullDic:myObj];
    }
    else if([myObj isKindOfClass:[NSArray class]])
    {
        return [self nullArr:myObj];
    }
    else if([myObj isKindOfClass:[NSString class]])
    {
        return [self stringToString:myObj];
    }
    else if([myObj isKindOfClass:[NSNull class]])
    {
        return [self nullToString];
    }
    else
    {
        return myObj;
    }
}

+ (NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        obj = [self changeType:obj];
        
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

+ (NSArray *)nullArr:(NSArray *)myArr
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        
        obj = [self changeType:obj];
        
        [resArr addObject:obj];
    }
    return resArr;
}

+ (NSString *)stringToString:(NSString *)string
{
    return string;
}

+ (NSString *)nullToString
{
    return @"";
}

#pragma mark - 表情转码 -
+(NSString *)phizEncodingWithStr:(NSString *)str{
    return str;
}

#pragma mark - 表情解码 -
+(NSString *)phizDecodingWithStr:(NSString *)str{
    NSString *newStr = [str stringByRemovingPercentEncoding];
    return newStr;
}

#pragma mark - 比较版本的方法，在这里我用的是Version来比较的
+ (BOOL)compareVersionsFormAppStore:(NSString*)AppStoreVersion WithAppVersion:(NSString*)AppVersion{
    
    BOOL littleSunResult = false;
    
    NSMutableArray* a = (NSMutableArray*) [AppStoreVersion componentsSeparatedByString: @"."];
    NSMutableArray* b = (NSMutableArray*) [AppVersion componentsSeparatedByString: @"."];
    
    while (a.count < b.count) { [a addObject: @"0"]; }
    while (b.count < a.count) { [b addObject: @"0"]; }
    
    for (int j = 0; j<a.count; j++) {
        if ([[a objectAtIndex:j] integerValue] > [[b objectAtIndex:j] integerValue]) {
            littleSunResult = true;
            break;
        }else if([[a objectAtIndex:j] integerValue] < [[b objectAtIndex:j] integerValue]){
            littleSunResult = false;
            break;
        }else{
            littleSunResult = false;
        }
    }
    return littleSunResult;//true就是有新版本，false就是没有新版本
}

+(NSString *)setSltUrlWithImageUrl:(NSString *)url{
    
    //根据.来截取字符串，然后进行拼接得到缩略图的url
    //传进来的URL可能有多个.    需要全部截取到，并重新拼接
    NSMutableArray * urlArr = [NSMutableArray array];
    
    [urlArr addObjectsFromArray:[url componentsSeparatedByString:@"."]];
    
    //i=0 把数组第0个元素给SltUrl
    NSString * SltUrl = urlArr[0];
    
    //第一个元素已经取出来了，还剩下urlArr.count - 1个元素，在拼接urlArr.count - 1个元素之前拼接上 -slt再拼接最后一个元素
    for (NSInteger i = 1 ; i < urlArr.count ; i ++ ) {

        if (i == urlArr.count - 1) {
            
            SltUrl = [NSString stringWithFormat:@"%@-slt.%@",SltUrl,urlArr[i]];
            
        }else{
            
            SltUrl = [NSString stringWithFormat:@"%@.%@",SltUrl,urlArr[i]];
        }
    }
    return SltUrl ;
}
@end
