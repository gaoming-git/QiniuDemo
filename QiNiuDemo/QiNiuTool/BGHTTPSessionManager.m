//
//  BGHTTPSessionManager.m
//  BGH-family
//
//  Created by gaoming on 2018/1/27.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import "BGHTTPSessionManager.h"
#import <CommonCrypto/CommonDigest.h>

static BGHTTPSessionManager *manager;

@implementation BGHTTPSessionManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
        //设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30;
        //设置与服务器和前端所有可相互识别的方式
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
    });
    
    return manager;
}

- (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                self.networkStats=StatusUnknown;
                
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"没有网络");
                self.networkStats=StatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                self.networkStats=StatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                self.networkStats=StatusReachableViaWiFi;
                NSLog(@"WIFI--%d",[BGHTTPSessionManager shareManager].networkStats);
                break;
        }
    }];
    [mgr startMonitoring];
}

+(void)getUploadFileTokenSuccess:(void (^)(NSString *token,NSString *usefulLife))tokenSuccess tokenFailue:(void (^)(NSString *error))tokenFailue
{
    NSString *timeSpan = [SLTTool getCurrentTime];
    
    NSMutableDictionary *accountDic = [NSMutableDictionary dictionary];
    [accountDic setObject:@1 forKey:@"appType"];
    [accountDic setObject:timeSpan forKey:@"timeSpan"];
    [accountDic setObject:@2 forKey:@"mobileType"];

    NSString *postUrl = [BASE_URL stringByAppendingString:BASE_URL_UPLOAD];
    
    [[BGHTTPSessionManager shareManager] POST:postUrl parameters:accountDic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"status"] isEqualToString:@"0"]) {
            NSString *token = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"token"]];
            NSString *usefulLife = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"usefulLife"]];
            
            if (tokenSuccess) {
                tokenSuccess(token,usefulLife);
            }
        }else
        {
            if (tokenFailue) {
                tokenFailue(@"获取上传token失败");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (tokenFailue) {
            tokenFailue(@"请检查网络");
        }
    }];
}

#pragma mark --- 更新app版本
+ (void)updateAPPVersonWithTarget:(UIViewController *)target
{
    //检测更新
    [[BGHTTPSessionManager shareManager] POST:APP_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        /*responseObject是个字典{}，有两个key
         
         KEYresultCount = 1//表示搜到一个符合你要求的APP
         results =（）//这是个只有一个元素的数组，里面都是app信息，那一个元素就是一个字典。里面有各种key。其中有 trackName （名称）trackViewUrl = （下载地址）version （可显示的版本号）等等
         */
        
        //具体实现为
        NSArray *arr = [responseObject objectForKey:@"results"];
        NSDictionary *dic = [arr firstObject];
        NSString *versionStr = [dic objectForKey:@"version"];
        NSString *trackViewUrl = [dic objectForKey:@"trackViewUrl"];
        //        GMLog(@"%@",trackViewUrl);
        //        NSString *releaseNotes = [dic objectForKey:@"releaseNotes"];//更新日志
        NSString *trackName = [dic objectForKey:@"trackName"];
        
        //NSString* buile = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleVersionKey];build号
        NSString* thisVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([SLTTool compareVersionsFormAppStore:versionStr WithAppVersion:thisVersion]) {
            NSString *titleStr = [NSString stringWithFormat:@"检查更新：%@", trackName];
            NSString *messageStr = [NSString stringWithFormat:@"发现新版本（%@）,是否更新", versionStr];
            
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:titleStr message:messageStr preferredStyle:UIAlertControllerStyleAlert];
            // 添加按钮
            [alertVc addAction:[UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
            }]];
            
            [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            
            [target presentViewController:alertVc animated:YES completion:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"");
        
    }];
}

@end
