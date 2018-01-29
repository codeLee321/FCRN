//
//  RLFaceRecongnizeVC.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "RLFaceRecongnizeVC.h"
#import "RLSingleton.h"
#import "RLSpeech.h"
#import "UIImage+image.h"
#import "NSDate+date.h"

@interface RLFaceRecongnizeVC ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    UIImage *largeImage;
    UIImage *smallImage;
}
//硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//协调输入输出流的数据
@property (nonatomic, strong) AVCaptureSession *session;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;    //原始视频帧，用于获取实时图像以及视频录制
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;      //用于二维码识别以及人脸识别
//闪光灯
@property (nonatomic, strong) UIButton *torchButton;
//切换前后摄像头
@property (nonatomic, strong) UIButton *cameraButton;
//拍照
@property (nonatomic, strong) UIButton *takePhotoButton;

@property (nonatomic, strong) NSMutableArray *faceViewArr;

@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, assign) int recursionCount;   // 设置一个递归数

@property (nonatomic, assign) BOOL isRecongnize;    // 设置一个bool值 是否正在检测中
@property (nonatomic, assign) BOOL isFront;         // 是否正面

@property (nonatomic, strong) RLSpeech * speech;       // 是否正在语音播报

@property (nonatomic, assign) CGRect  detectRect;

@property (nonatomic, weak) UILabel * nameLabel;

@end

@implementation RLFaceRecongnizeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavItem];
    
    [self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.torchButton];
    [self.view addSubview:self.cameraButton];
    
    for (int i=0; i<10; i++) {
        UIView * faceView = [[UIView alloc] init];
        faceView.layer.borderColor = [UIColor redColor].CGColor;
        faceView.layer.borderWidth  = 2.f;
        faceView.hidden = YES;
        [self.view addSubview:faceView];
        [self.faceViewArr addObject:faceView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startCaptureFace];
    
    [self switchCamera];
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


#pragma mark - 检索人脸
- (void)searchImage:(UIImage *)image{
    
    NSString * currentDate = [NSDate getCurrentDate];
    
    if ([currentDate isEqualToString:[RLSingleton shareSingle].callDate]) {
        [RLSingleton shareSingle].callCount += 1;
        if ([RLSingleton shareSingle].callCount > 1000) {
            ShowMessage(@"今日已达上限");
            [self.session stopRunning];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.session startRunning];
            });
            return;
        }
    }else{
        [RLSingleton shareSingle].callCount = 0;
    }
    
    self.isRecongnize = YES;
    NSMutableDictionary * infoDict = [RLSingleton shareSingle].infoDict;
    
    FCPPFace *face = [[FCPPFace alloc] initWithImage:image];
    
    [face searchFromFaceSet:[RLSingleton shareSingle].faceSet returnCount:1 completion:^(id info, NSError *error) {
        if (info) {
            NSArray *faces = info[@"faces"];
            if (faces.count) {
                NSDictionary *result = [info[@"results"] firstObject];
                NSDictionary *thresholds = info[@"thresholds"];
                NSString *faceToken = result[@"face_token"];
                CGFloat confidence = [result[@"confidence"] floatValue];
                CGFloat midThreshold = [thresholds[@"1e-4"] floatValue];
                BOOL vaild = confidence > midThreshold;
                //搜索到人脸
                if (faceToken && vaild) {
                    //根据faceToken的映射关系,取出相应信息
                    NSArray *faceTokenArr = [infoDict allKeys];
                    if ([faceTokenArr containsObject:faceToken]) {
                        NSDictionary * megDict = [infoDict objectForKey:faceToken];
                        [self.session stopRunning];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.session startRunning];
                        });
                        // 展示用户信息页
                        [self showInfoViewWithDict:megDict];
                        
                        // 开始语音播报
                        if (!_speech.isReading) {
                            [self speechContentWithString:[megDict objectForKey:@"wel"]];
                        }
                    }else{
                        self.infoView.hidden = YES;
                    }
                    
                }else{
                    self.infoView.hidden = YES;
                }
            }else{
                self.infoView.hidden = YES;
                
            }
        }else{
            self.infoView.hidden = YES;
            
        }
        
        self.isRecongnize = NO;
    }];
}

#pragma mark - 显示信息页
- (void)showInfoViewWithDict:(NSDictionary *)infoDict{
    
    self.nameLabel.text = infoDict[@"name"];
    CGFloat y = CGRectGetMaxY(self.detectRect);
    CGFloat x = self.detectRect.origin.x;
    self.infoView.frame = CGRectMake(x, y, self.detectRect.size.width, 20);
    self.infoView.hidden = NO;
}

#pragma mark - 语音播报
- (void)speechContentWithString:(NSString *)str{
    _speech = [[RLSpeech alloc] init];
    [_speech playWithString:str];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
//AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    // 隔帧检测人脸
    if (self.recursionCount >3000) {
        self.recursionCount = 0;
    }
    
    self.recursionCount ++;
    // 每隔5帧检测一次
    if (self.recursionCount % 2 == 0) {
        //设置图像方向，否则largeImage取出来是反的
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        largeImage = [self imageFromSampleBuffer:sampleBuffer];
        
        smallImage = [largeImage imageCompressTargetSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
        
        [self detectFacesWithImage:smallImage];
    }
}

//CMSampleBufferRef转NSImage
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}

- (void)detectFacesWithImage:(UIImage *)image{
    CGImageRef detectCGImageRef = [image CGImage];
    CIImage * detectImage = [CIImage imageWithCGImage:detectCGImageRef];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    NSArray * features = [faceDetector featuresInImage:detectImage];
    
    if (features.count >0) {
        // 每30帧检测一次
        if (self.recursionCount %4 == 0) {
            if (!self.isRecongnize) {
                
                [self searchImage:[image imageCompressTargetSize:CGSizeMake(self.view.frame.size.width*0.3, self.view.frame.size.height*0.3)]];
            }
        }
        
        // 每次检测到人脸重置人脸框
        for (UIView * view in self.faceViewArr) {
            view.hidden = YES;
        }
        
        for (int i = 0; i< MIN(features.count,self.faceViewArr.count); i++) {
            
            CIFaceFeature * faceFeature = features[i];
            CGRect faceRect = [self adjustCoordinateSpaceForMaker:faceFeature.bounds andHeight:detectImage.extent.size.height];
            UIView * faceView = self.faceViewArr[i];
            if (self.isFront) {
                faceView.frame = CGRectMake(detectImage.extent.size.width-faceRect.origin.x-faceRect.size.width, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
                self.detectRect = faceView.frame;
            }else{
                faceView.frame = faceRect;
                self.detectRect = faceView.frame;
            }
            
            faceView.hidden = NO;
            
        }
    }else{
        // 没有人脸 隐藏用户信息页
        self.infoView.hidden = YES;
        for (UIView * view in self.faceViewArr) {
            view.hidden = YES;
        }
    }
}

- (CGRect)adjustCoordinateSpaceForMaker:(CGRect)rect andHeight:(CGFloat)height{
    CGAffineTransform scale = CGAffineTransformMakeScale(1, -1);
    CGAffineTransform flip = CGAffineTransformTranslate(scale, 0, -height);
    CGRect flipRect = CGRectApplyAffineTransform(rect, flip);
    return flipRect;
}

#pragma mark - 手电筒
-(void)openTorch:(UIButton*)button{
    button.selected = !button.selected;
    [self turnTorchOn:button.selected];
}

- (void)turnTorchOn:(BOOL)on{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        if ([self.device hasTorch] && [self.device hasFlash]){
            [self.device lockForConfiguration:nil];
            if (on) {
                [self.device setTorchMode:AVCaptureTorchModeOn];
                
            } else {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            [self.device unlockForConfiguration];
        }
    }
}

#pragma mark - 切换前后摄像头
- (void)switchCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    self.isFront = !self.isFront;
    if (cameraCount > 1) {
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            }else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
#pragma mark - 开始捕捉人脸
- (void)startCaptureFace{
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

#pragma mark - getter
-(AVCaptureDevice *)device{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];
        }
    }
    return _device;
}

-(AVCaptureDeviceInput *)input{
    if (_input == nil) {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

-(AVCaptureVideoDataOutput *)videoDataOutput{
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        //设置像素格式，否则CMSampleBufferRef转换NSImage的时候CGContextRef初始化会出问题
        [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    return _videoDataOutput;
}

-(AVCaptureMetadataOutput *)metadataOutput{
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置扫描区域
        //        _metadataOutput.rectOfInterest = self.view.bounds;
    }
    return _metadataOutput;
}

-(AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.videoDataOutput]) {
            [_session addOutput:self.videoDataOutput];
        }
    }
    return _session;
}

-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.layer.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

-(UIButton *)torchButton{
    if (_torchButton == nil) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _torchButton.frame = CGRectMake(0.0f, self.view.frame.size.height-64-70.f, 100.0f, 64.0f);
        [_torchButton setImage:[UIImage imageNamed:@"flash_icon"] forState:UIControlStateNormal];
        [_torchButton setImage:[UIImage imageNamed:@"flash_icon1"] forState:UIControlStateSelected];
        [_torchButton addTarget:self action:@selector(openTorch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _torchButton;
}

-(UIButton *)cameraButton{
    if (_cameraButton == nil) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.frame = CGRectMake(self.view.frame.size.width - 100.0f, self.view.frame.size.height-64-70.f, 100.0f, 66.0f);
        [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (NSMutableArray *)faceViewArr{
    if (!_faceViewArr) {
        _faceViewArr = [NSMutableArray array];
    }
    return _faceViewArr;
}

- (UIView *)infoView{
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        _infoView.frame = CGRectMake(0, 0, 30, 20);
        _infoView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_infoView];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        [_infoView addSubview:label];
        self.nameLabel = label;
    }
    return _infoView;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    AVCaptureConnection *captureConnection=[self.previewLayer connection];
    captureConnection.videoOrientation=(AVCaptureVideoOrientation)toInterfaceOrientation;
}

//旋转后重新设置大小
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    _previewLayer.frame=self.view.bounds;
}
@end
