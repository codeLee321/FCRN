//
//  RLInputVC.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RLInputVC.h"
#import "RLHttpHint.h"
#import "RLSingleton.h"
#import "NSDate+date.h"
#import "UIColor+hexColor.h"

@interface RLInputVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *welLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UIView *alertSourceView;

@property (weak, nonatomic) IBOutlet UIView *bgContainer;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) UIImage *selectImage;


@end

@implementation RLInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavItem];
    
    [self configDefaultUI];

}

- (void)configNavItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction:)];
    
    self.navigationItem.titleView = ({
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 28)];
        imageView.image = [UIImage imageNamed:@"titl_icon"];
        imageView;
    });
}

- (void)leftItemAction:(UIButton *)btn{
    [[RLSingleton shareSingle].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)configDefaultUI{
    [self.nameTextField setValue:[UIColor colorWithHex:@"#888888"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.genderTextField setValue:[UIColor colorWithHex:@"#888888"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.ageTextField setValue:[UIColor colorWithHex:@"#888888"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.welLabel setValue:[UIColor colorWithHex:@"#888888"] forKeyPath:@"_placeholderLabel.textColor"];

    self.submitBtn.layer.masksToBounds = YES;
    self.submitBtn.layer.cornerRadius = 20.f;
    
    self.submitBtn.layer.borderWidth = 1;
    self.submitBtn.layer.borderColor = [UIColor colorWithHex:@"#888888"].CGColor;
    
    self.bgContainer.layer.shadowColor = [UIColor colorWithHex:@"#888888"].CGColor;
    self.bgContainer.layer.shadowOffset = CGSizeMake(1,1);
    self.bgContainer.layer.shadowOpacity = 0.3;
    self.bgContainer.layer.shadowRadius = 3;
    
    self.alertSourceView.layer.shadowColor = [UIColor colorWithHex:@"#888888"].CGColor;
    self.alertSourceView.layer.shadowOffset = CGSizeMake(1,1);
    self.alertSourceView.layer.shadowOpacity = 0.3;
    self.alertSourceView.layer.shadowRadius = 3;
    self.alertSourceView.layer.cornerRadius = 75.f;
    self.alertSourceView.clipsToBounds = NO;

}

- (IBAction)selectHeaderImageAction:(UITapGestureRecognizer *)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //处理点击拍照
        [self selectImageFormImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"从相册选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //处理点击从相册选取
        [self selectImageFormImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    if ([RLSingleton shareSingle].isPad) {
        alertController.popoverPresentationController.sourceView = self.alertSourceView;
        alertController.popoverPresentationController.sourceRect = self.headerImageView .frame;
    }
    [self presentViewController: alertController animated: YES completion: nil];
}

- (void)selectImageFormImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType ==  UIImagePickerControllerSourceTypeCamera && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ShowMessage(@"该设备不支持相机");
        return;
    }
    
    if (sourceType ==  UIImagePickerControllerSourceTypeCamera) {
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            // 初始化
            UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"无法启动相机" message:@"请为人脸识别开放相机权限：手机设置->隐私->相机->人脸识别(打开)" preferredStyle:UIAlertControllerStyleAlert];
            
            // 创建操作
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 操作具体内容
                // Nothing to do.
            }];
            
            // 添加操作
            [alertDialog addAction:okAction];
            
            // 呈现警告视图
            [self presentViewController:alertDialog animated:YES completion:nil];
            
            return;
        }
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    self.imagePickerController = imagePickerController;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.headerImageView.image = image;
    self.selectImage = image;
}

- (IBAction)submitBtnAction:(UIButton *)sender {
    
    if (self.selectImage && self.nameTextField.text.length > 0 && self.genderTextField.text.length > 0 && self.ageTextField.text.length > 0 && self.welLabel.text.length > 0) {
        [self addImage:self.selectImage];
    }else{
        ShowErrorStatus(@"请先完善信息");
    }
}

- (void)addImage:(UIImage *)image{
    
    ShowMaskStatus(@"正在检测人脸");
    FCPPFaceDetect * faceDetector = [[FCPPFaceDetect alloc] initWithImage:image];
    [faceDetector detectFaceWithReturnLandmark:NO attributes:nil completion:^(id info, NSError *error) {
        if (error) {
            ShowErrorStatus(@"检测失败，请重新添加");
        }else{
            NSArray *faceTokens = [info[@"faces"] valueForKeyPath:@"face_token"];
            if (faceTokens.count && [RLSingleton shareSingle].faceSet) {
                ShowMaskStatus(@"正在上传人脸");
                [[RLSingleton shareSingle].faceSet addFaceTokens:faceTokens completion:^(id info, NSError *error) {
                    if (error == nil) {
                        ShowSuccessStatus(@"上传成功");
                        for (NSString *faceToken in faceTokens) {
                            [[RLSingleton shareSingle] writeToUserDefaultWithObject:UIImagePNGRepresentation(image) andKey:faceToken];
                            NSDictionary * megDict = @{
                                                       @"name":self.nameTextField.text,
                                                       @"gender":self.genderTextField.text,
                                                       @"age":self.ageTextField.text,
                                                       @"wel":self.welLabel.text,
                                                       @"date":[NSDate getCurrentDate],
                                                       @"header":faceToken
                                                       };
                            
                            [[RLSingleton shareSingle].infoDict setValue:megDict forKey:faceToken];
                        }
                        [RLSingleton shareSingle].infoDict = [RLSingleton shareSingle].infoDict;
                    }else{
                        ShowErrorStatus(@"检测失败");
                    }
                }];
            }else{
                ShowErrorStatus(@"上传失败");
            }
        }
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
