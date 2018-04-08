//
//  BGHTTPSessionManager.h
//  BGH-family
//
//  Created by gaoming on 2018/1/27.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class Kid;

typedef enum{
    StatusUnknown           = -1, //未知网络
    StatusNotReachable      = 0,    //没有网络
    StatusReachableViaWWAN  = 1,    //手机自带网络
    StatusReachableViaWiFi  = 2     //wifi
    
}NetworkStatus;

@interface BGHTTPSessionManager : AFHTTPSessionManager

/**
 *  获取网络
 */
@property (nonatomic,assign)NetworkStatus networkStats;

/**
 *  单利
 */
+ (instancetype)shareManager;

/**
 *  开始监听网络
 */
- (void)startMonitoring;

/**
 *  获取文件上传token
 */
+(void)getUploadFileTokenSuccess:(void (^)(NSString *token,NSString *usefulLife))tokenSuccess tokenFailue:(void (^)(NSString *error))tokenFailue;


/**
 *  检测手机更新版本
 */
+ (void)updateAPPVersonWithTarget:(UIViewController *)target;

@end
