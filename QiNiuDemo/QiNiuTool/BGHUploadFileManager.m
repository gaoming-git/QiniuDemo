//
//  BGHUploadFileManager.m
//  BGH-family
//
//  Created by gaoming on 2018/1/27.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import "BGHUploadFileManager.h"
#import "BGHTTPSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation BGHUploadFileManager

+ (BGHUploadFileManager *)shareManager {
    static BGHUploadFileManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.zone = [QNFixedZone zone1];
        }];
        manager = [[[self class] alloc] initWithConfiguration:config];
    });
    return manager;
}

/** 获取文件名 fileName */
-(NSString *)getFileNameWithModule:(NSString *)module withFileType:(UploadFileType)fileType
{
    NSString *fileTypeStr = @"";
    switch (fileType) {
        case UploadFileTypePhoto:
            fileTypeStr = @"jpg";
            break;
        case UploadFileTypeVideo:
            fileTypeStr = @"mp4";
            break;
            
        default:
            break;
    }
    
    NSString *dateStr = [SLTTool getCurrentTime];
    NSString *hourStr = [SLTTool getCurrentHourTime];

    NSString *fileName = [NSString stringWithFormat:@"%@ %@ %@.%@",module,dateStr,hourStr,fileTypeStr];
    return fileName;
}

/** 拼接上传到七牛的文件名 Key */
-(NSString *)getUploadFileKeyWithModule:(NSString *)module withFileType:(UploadFileType)fileType
{
    NSString *fileTypeStr = @"";
    switch (fileType) {
        case UploadFileTypePhoto:
            fileTypeStr = @"jpg";
            break;
        case UploadFileTypeVideo:
            fileTypeStr = @"mp4";
            break;
            
        default:
            break;
    }
    
    NSString *dateStr = [SLTTool getCurrentTime];
    NSString *hourStr = [SLTTool getCurrentHourTime];
    NSString *uuidStr = [SLTTool getDeviceUUID];
    

    NSString *key = [NSString stringWithFormat:@"ProjectName/%@/%@/%@%@.%@",module,dateStr,hourStr,uuidStr,fileTypeStr];
    return key;
}

/** 获取文件路径全名 */
-(NSString *)getFilePathWithDirector:(NSString *)director withFileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:director]) {
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:director
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        NSLog(@"路径存在");
    }
    return [director stringByAppendingPathComponent:fileName];
}


- (void)savePhotoAndGetPhotoModelWithModule:(NSString *)module withImage:(UIImage *)image success:(void (^)(UploadModel *model))success
{
    NSString *key = [self getUploadFileKeyWithModule:module withFileType:UploadFileTypePhoto];
    NSLog(@"////////////////////////////\n%@",key);
    NSString *fileName = [self getFileNameWithModule:module withFileType:UploadFileTypePhoto];
    NSString *filePath = [self getFilePathWithDirector:PHOTOCACHEPATH withFileName:fileName];
    NSString *fileTypeValue = @"1";
    NSString *mineType = @"image/jpg";
    
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:filePath atomically:YES];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    UploadModel *model = [[UploadModel alloc] init];
    model.module = module;
    model.filePath = filePath;
    model.fileName = fileName;
    model.fileTypeValue = fileTypeValue;
    model.mineType = mineType;
    model.key = key;
    model.data = data;
    
    if (success) {
        success(model);
    }
}

- (void)saveVideoAndGetVideoModelWithModule:(NSString *)module withAsset:(id)phAsset success:(void (^)(UploadModel *model))success failure:(void (^)(NSString *error))failure
{
    NSString *key = [self getUploadFileKeyWithModule:module withFileType:UploadFileTypeVideo];
    NSString *fileName = [self getFileNameWithModule:module withFileType:UploadFileTypeVideo];
    NSString *filePath = [self getFilePathWithDirector:VIDEOCACHEPATH withFileName:fileName];
    NSString *fileTypeValue = @"2";
    NSString *mineType = @"video/mp4";
    
    [RTProgressHUD showWithStatus:@"正在压缩..."];
    
    //从PHAsset获取相册中视频的url
    //iOS8以后返回PHAsset
    PHAsset *now_phAsset = phAsset;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:now_phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        NSURL *assetUrl = urlAsset.URL;
        NSLog(@"%@",assetUrl);
        
        if (!assetUrl) {
            [RTProgressHUD dismiss];
            if (failure) {
                failure(@"请从Cloud下载重试");
            }
            return ;
        }
        
        //转码配置
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
        AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset960x540];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            [RTProgressHUD dismiss];
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                }  break;
                case AVAssetExportSessionStatusWaiting: {
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                }  break;
                case AVAssetExportSessionStatusExporting: {
                    NSLog(@"AVAssetExportSessionStatusExporting");
                }  break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    if (success) {
                        NSLog(@"视频转码成功");
                        
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
                        UploadModel *model = [[UploadModel alloc] init];
                        model.module = module;
                        model.filePath = filePath;
                        model.fileName = fileName;
                        model.fileTypeValue = fileTypeValue;
                        model.mineType = mineType;
                        model.key = key;
                        model.data = data;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                success(model);
                            }
                        });
                    }
                }  break;
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failure) {
                            failure(@"视频导出失败");
                        }
                    });
                }  break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failure) {
                            failure(@"导出任务已被取消");
                        }
                    });
                }  break;
                default: break;
            }
        }];
        
    }];
}

- (void)saveTakeVideoAndGetTakeVideoModelWithModule:(NSString *)module withFileUrl:(NSURL *)fileUrl success:(void (^)(UploadModel *model))success failure:(void (^)(NSString *error))failure
{
    NSString *key = [self getUploadFileKeyWithModule:module withFileType:UploadFileTypeVideo];
    NSString *fileName = [self getFileNameWithModule:module withFileType:UploadFileTypeVideo];
    NSString *filePath = [self getFilePathWithDirector:VIDEOCACHEPATH withFileName:fileName];
    NSString *fileTypeValue = @"2";
    NSString *mineType = @"video/mp4";
    
    [RTProgressHUD showWithStatus:@"正在压缩..."];
        
    //转码配置
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset960x540];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        [RTProgressHUD dismiss];
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"AVAssetExportSessionStatusUnknown");
            }  break;
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"AVAssetExportSessionStatusWaiting");
            }  break;
            case AVAssetExportSessionStatusExporting: {
                NSLog(@"AVAssetExportSessionStatusExporting");
            }  break;
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"AVAssetExportSessionStatusCompleted");
                if (success) {
                    NSLog(@"视频转码成功");
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    UploadModel *model = [[UploadModel alloc] init];
                    model.module = module;
                    model.filePath = filePath;
                    model.fileName = fileName;
                    model.fileTypeValue = fileTypeValue;
                    model.mineType = mineType;
                    model.key = key;
                    model.data = data;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success(model);
                        }
                    });
                }
            }  break;
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"AVAssetExportSessionStatusFailed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(@"视频导出失败");
                    }
                });
            }  break;
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"AVAssetExportSessionStatusCancelled");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(@"导出任务已被取消");
                    }
                });
            }  break;
            default: break;
        }
    }];
}

#pragma mark - POST 请求
/** 上传文件到七牛 需要先从后台服务器请求token，并判断token是否有效 */
- (void)putQiNiuWithUploadModel:(UploadModel *)uploadModel success:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))success failure:(void (^)(NSString *error))failure
{
    if (!uploadModel.data) {
        failure(@"上传失败");
        return;
    }
    [RTProgressHUD showWithStatus:@"正在上传..."];
    //有token并且未过期
    if (self.uploadToken&&self.uploadTokenTm.integerValue>[SLTTool currentTimeSince1970].integerValue) {
        
        QNUploadOption *uploadOption = [self setQNUploadOptionWithUploadModel:uploadModel];
        [self putData:uploadModel.data key:uploadModel.key token:self.uploadToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [RTProgressHUD dismiss];
            if (info.statusCode == 200) {
                success(info,key,resp);
            }else
            {
                failure(@"上传失败");
            }
        } option:uploadOption];
    }else
    {
        [BGHTTPSessionManager getUploadFileTokenSuccess:^(NSString *token,NSString *usefulLife) {
            
            self.uploadToken = token;
            self.usefulLife = usefulLife;
            NSInteger limitTm = [SLTTool currentTimeSince1970].integerValue+usefulLife.integerValue;
            self.uploadTokenTm = [NSString stringWithFormat:@"%zd",limitTm];
            
            QNUploadOption *uploadOption = [self setQNUploadOptionWithUploadModel:uploadModel];
            
            [self putData:uploadModel.data key:uploadModel.key token:self.uploadToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                [RTProgressHUD dismiss];
                if (info.statusCode == 200) {
                    success(info,key,resp);
                }else
                {
                    failure(@"上传失败");
                    NSLog(@"上传失败:%@",info.error);
                }
            } option:uploadOption];
            
        } tokenFailue:^(NSString *error) {
            [RTProgressHUD dismiss];
            failure(error);
        }];
    }
}

-(void)putQiNiuWithFileArr:(NSMutableArray *)fileArr success:(void (^)(NSMutableArray *respArr))success failure:(void (^)(NSString *error))failure
{
    NSMutableArray *fileInfoArr = [NSMutableArray array];
    NSMutableArray *fileErrorArr = [NSMutableArray array];
    //获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue =  dispatch_queue_create("singal", DISPATCH_QUEUE_SERIAL);
    //创建组
    dispatch_group_t group = dispatch_group_create();
    //遍历所有图片列表
    dispatch_apply(fileArr.count, queue, ^(size_t index) {
        //关联任务到group
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self putQiNiuWithUploadModel:fileArr[index] success:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                NSLog(@"-----第%zd个成功----",index);
                NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                [dictM setObject:@(index) forKey:@"index"];
                [dictM setObject:resp forKey:@"resp"];
                [fileInfoArr addObject:dictM];
                dispatch_group_leave(group);
            } failure:^(NSString *error) {
                NSLog(@"----第%zd个失败-----",index);
                [fileErrorArr addObject:@(index)];
                dispatch_group_leave(group);
            }];
        });
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //上传排序
        [fileInfoArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *objStr1 = obj1[@"index"];
            NSString *objStr2 = obj2[@"index"];
            if ([objStr1 integerValue] < [objStr2 integerValue])
            {
                return NSOrderedAscending;
            }else
            {
                return NSOrderedDescending;
            }
        }];
        NSMutableArray *respArr = [NSMutableArray array];
        for (NSDictionary *dict in fileInfoArr) {
            [respArr addObject:dict[@"resp"]];
        }
        success(respArr);
        
        if (fileErrorArr.count>0) {
            NSString *numStr = [fileErrorArr componentsJoinedByString:@","];
            NSString *error = [NSString stringWithFormat:@"第%@个上传失败",numStr];
            failure(error);
        }
    });
}

/** 配置上传参数(根据自己的需求自定义：参数可以通过七牛传递到自己的后台服务器) */
-(QNUploadOption *)setQNUploadOptionWithUploadModel:(UploadModel *)uploadModel
{
    NSMutableDictionary *accountDic = [NSMutableDictionary dictionary];
    
    [accountDic setObject:uploadModel.module forKey:@"x:module"];
    [accountDic setObject:uploadModel.fileTypeValue forKey:@"x:fileType"];
    [accountDic setObject:@"1" forKey:@"x:userType"];
    
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:uploadModel.mineType progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);
        [RTProgressHUD dismiss];
        [RTProgressHUD showProgress:percent status:@"正在上传"];
    } params:accountDic checkCrc:NO cancellationSignal:nil];
    
    return uploadOption;
}


//获取视频的第一帧截图, 返回UIImage
//需要导入AVFoundation.h
- (UIImage*) getVideoPreViewImageWithPath:(NSURL *)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time      = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error   = nil;
    
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    
    return img;
}

@end

@implementation UploadModel



@end
