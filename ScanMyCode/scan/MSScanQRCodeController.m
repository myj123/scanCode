//
//  MSScanVC.m
//  PayEase_iphone
//
//  Created by Relly on 15/6/1.
//  Copyright (c) 2015年 Relly. All rights reserved.
//

#import "MSScanQRCodeController.h"
#import "MSScanQRCodeView.h"

@interface MSScanQRCodeController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 会话对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图层类 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) MSScanQRCodeView *scanView;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) UIButton *right_Button;
@property (nonatomic, assign) BOOL first_push;

@end

@implementation MSScanQRCodeController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 创建扫描边框
    self.scanView = [[MSScanQRCodeView alloc] initWithFrame:self.view.frame captureDevice:self.device outsideViewLayer:self.view.layer];
    __weak typeof(self) weakSelf = self;
    self.scanView.block = ^(void) {
        [weakSelf presentPhotoLibrary];
    };
    [self.view addSubview:self.scanView];
    [self addCancelBtn];
}

#pragma mark -- 打开相册
- (void)presentPhotoLibrary {
    UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated: YES completion: nil];
}

#pragma mark -- 相册代理
- ( void)imagePickerController:( UIImagePickerController*)picker didFinishPickingMediaWithInfo:( NSDictionary< UIImagePickerControllerInfoKey, id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage] ?: info[ UIImagePickerControllerOriginalImage];
    CIImage *detectImage = [CIImage imageWithData: UIImagePNGRepresentation(pickedImage)];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy: CIDetectorAccuracyLow}];;
    CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:detectImage options: nil].firstObject;
    if (feature) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (self.qrScanBlock) {
                self.qrScanBlock(feature.messageString);
            }
        }];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self showAlert];
        }];
    }
}

- (void)showAlert {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"图片解析失败，换个图片试试" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:cancelA];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 二维码扫描
    [self setupScanningQRCode];
}

-(void)addCancelBtn{
    UIButton *cancelB = [[UIButton alloc] init];
    if (@available(iOS 11.0, *)) {
        cancelB.frame = CGRectMake(20, [UIApplication sharedApplication].delegate.window.safeAreaInsets.top + 20, 35, 35);
    } else {
        cancelB.frame = CGRectMake(20, 20, 35, 35);
    }
    [cancelB addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelB setImage:[UIImage imageNamed:@"QRCodeScanBack"] forState:(UIControlState)UIControlStateNormal];
    [self.view addSubview:cancelB];
    
    [self.view bringSubviewToFront:cancelB];
}

-(void)cancelButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - - 二维码扫描
- (void)setupScanningQRCode {
    // 初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    
    // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、初始化链接对象（会话对象）
    // 高质量采集率
    //session.sessionPreset = AVCaptureSessionPreset1920x1080; // 如果二维码图片过小、或者模糊请使用这句代码，注释下面那句代码
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 5.1 添加会话输入
    [self.session addInput:input];
    
    // 5.2 添加会话输出
    [self.session addOutput:output];
    
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 9、启动会话
    [self.session startRunning];
}

#pragma mark - - - 二维码扫描代理方法
// 调用代理方法，会频繁的扫描
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // 1、如果扫描完成，停止会话
    [self.session stopRunning];
    
    // 2、删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    // 3、设置界面显示扫描结果
    if (metadataObjects.count > 0) {
    
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        NSString *scanValue = obj.stringValue;
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.qrScanBlock) {
                self.qrScanBlock(scanValue);
            }
        }];
    }
}

#pragma mark - - - 移除定时器
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
