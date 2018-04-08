//
//  ViewController.m
//  QiNiuDemo
//
//  Created by gaoming on 2018/4/8.
//  Copyright © 2018年 Raising. All rights reserved.
//

#import "ViewController.h"
#import "BGHUploadFileManager.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,strong) NSMutableArray *uploadModelArr;

@end

@implementation ViewController

-(NSMutableArray *)uploadModelArr{
    if (!_uploadModelArr) {
        _uploadModelArr = [NSMutableArray array];
    }
    return _uploadModelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectPicBtn:(UIButton *)sender {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];

    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
    
}

/** 上传单张、多张图片 */
- (IBAction)uploadPicBtn:(UIButton *)sender {
    
    if (self.uploadModelArr.count == 0) {
        [RTProgressHUD showInfoWithStatus:@"请选择图片"];
        return;
    }
    if (self.uploadModelArr.count == 1) {
        
        UploadModel *model = [self.uploadModelArr firstObject];
        
        [[BGHUploadFileManager shareManager] putQiNiuWithUploadModel:model success:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            NSLog(@"key:%@ \nresp:%@",key,resp);
            
        } failure:^(NSString *error) {
            [RTProgressHUD showErrorWithStatus:error];
        }];
    }else {
        [[BGHUploadFileManager shareManager] putQiNiuWithFileArr:self.uploadModelArr success:^(NSMutableArray *respArr) {
            
            NSLog(@"respArr:%@",respArr);
            
        } failure:^(NSString *error) {
            
        }];
    }
    
}

//选择完成回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];

    [[BGHUploadFileManager shareManager] savePhotoAndGetPhotoModelWithModule:@"photo" withImage:image success:^(UploadModel *model) {
        [self.uploadModelArr addObject:model];
    }];
}
//用户取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
