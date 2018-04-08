//
//  BGHUploadFileManager.h
//  BGH-family
//
//  Created by gaoming on 2018/1/27.
//  Copyright © 2018年 Zontonec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, UploadFileType)
{
    UploadFileTypePhoto = 1,
    UploadFileTypeVideo = 2,
};

@class UploadModel;

@interface BGHUploadFileManager : QNUploadManager

/** token */
@property(nonatomic,copy) NSString *uploadToken;
/** token到期时的时间戳  */
@property(nonatomic,copy) NSString *uploadTokenTm;
/** token 有效时间 （单位：秒） */
@property(nonatomic,copy) NSString *usefulLife;

+ (BGHUploadFileManager *)shareManager;

/** 获取文件名 fileName */
-(NSString *)getFileNameWithModule:(NSString *)module withFileType:(UploadFileType)fileType;

/** 拼接上传到七牛的文件名 Key */
-(NSString *)getUploadFileKeyWithModule:(NSString *)module withFileType:(UploadFileType)fileType;

/** 获取文件路径全名 */
-(NSString *)getFilePathWithDirector:(NSString *)director withFileName:(NSString *)fileName;

/**
 *  缓存图片文件
 *
 *  @param module           模块名
 *  @param image           image对象
 *  @param success          回调数据模型 UploadModel
 */
- (void)savePhotoAndGetPhotoModelWithModule:(NSString *)module withImage:(UIImage *)image success:(void (^)(UploadModel *model))success;

/**
 *  缓存视频文件
 *
 *  @param module           模块名
 *  @param phAsset           phAsset对象
 *  @param success          回调数据模型 UploadModel
 *  @param failure          失败回调
 */
- (void)saveVideoAndGetVideoModelWithModule:(NSString *)module withAsset:(id)phAsset success:(void (^)(UploadModel *model))success failure:(void (^)(NSString *error))failure;

/**
 *  缓存拍摄视频的文件
 *
 *  @param module           模块名
 *  @param fileUrl          拍摄视频的url
 *  @param success          回调数据模型 UploadModel
 *  @param failure          失败回调
 */
- (void)saveTakeVideoAndGetTakeVideoModelWithModule:(NSString *)module withFileUrl:(NSURL *)fileUrl success:(void (^)(UploadModel *model))success failure:(void (^)(NSString *error))failure;

/**
 *  上传单个文件到七牛
 *
 *  @param uploadModel      上传文件模型
 *  @param success          回调数据模型 UploadModel
 *  @param failure          失败回调
 */
- (void)putQiNiuWithUploadModel:(UploadModel *)uploadModel success:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))success failure:(void (^)(NSString *error))failure;

/**
 *  上传多个文件到七牛
 *
 *  @param fileArr      上传文件uploadModel模型数组
 *  @param success          回调resp数据字典数组
 *  @param failure          失败回调（返回第几张上传失败）
 */
-(void)putQiNiuWithFileArr:(NSMutableArray *)fileArr success:(void (^)(NSMutableArray *respArr))success failure:(void (^)(NSString *error))failure;

@end

@interface UploadModel : NSObject

/** 上传到后台文件的模块名称 */
@property(nonatomic,copy) NSString *module;
/** 文件缓存沙盒路径 */
@property (nonatomic, strong) NSString *filePath;
/** 文件沙盒文件名*/
@property (nonatomic, strong) NSString *fileName;
/** 上传文件的文件名*/
@property (nonatomic, strong) NSString *key;
/** 上传文件类型 image/jpg  video/mp4 */
@property (nonatomic, strong) NSString *mineType;
/** 上传文件类型 1图片 2视频 */
@property (nonatomic, strong) NSString *fileTypeValue;
/** 上传文件数据 */
@property (nonatomic, strong) NSData *data;

@end
