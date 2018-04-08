# QiniuDemo

1、设置服务器地址和接口路径。
2、首先需要你从自己的后台获取上传文件到七牛token。
3、设置文件的缓存路径。
4、根据自己的需求配置参数。


方法：

1、缓存图片文件转为上传model。
[[BGHUploadFileManager shareManager] savePhotoAndGetPhotoModelWithModule:@"photo" withImage:image success:^(UploadModel *model) {

}];

2、缓存视频文件转为上传model。
[[BGHUploadFileManager shareManager] saveVideoAndGetVideoModelWithModule:@"video" withAsset:asset success:^(UploadModel *model) {

} failure:^(NSString *error) {

}];

3、上传单个文件（图片视频均可）
[[BGHUploadFileManager shareManager] putQiNiuWithUploadModel:model success:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {


} failure:^(NSString *error) {

}];

4、上传多个文件（只支持多个图片的上传）
[[BGHUploadFileManager shareManager] putQiNiuWithFileArr:self.uploadModelArr success:^(NSMutableArray *respArr) {

} failure:^(NSString *error) {

}];

