//
//  ViewController.m
//  ScanMyCode
//
//  Created by Relly on 2019/12/12.
//  Copyright © 2019 Relly. All rights reserved.
//

#import "ViewController.h"
#import "MSScanQRCodeController.h"
#import "MSScanQRCodeCreate.h"

@interface ViewController ()
{
    UITextField *codeField;
    UIImageView *imgV;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn.layer setCornerRadius:6.0];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setCenter:CGPointMake(self.view.center.x, 130)];
    [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    codeField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    codeField.center = CGPointMake(self.view.center.x, btn.center.y + 80);
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.text = @"Hello World";
    codeField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    codeField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:codeField];
    
    UIButton  *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(codeField.frame.origin.x ,CGRectGetMaxY(codeField.frame) + 40, 200, 40);
    [codeBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [codeBtn.layer setCornerRadius:6.0];
    [codeBtn setBackgroundColor:[UIColor redColor]];
    [codeBtn addTarget:self action:@selector(createCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:codeBtn];
    
    imgV = [[UIImageView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(codeBtn.frame) + 50, self.view.bounds.size.width -120, self.view.bounds.size.width -120)];
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imgV];
}

- (void)createCodeClicked: (UIButton *)sebder{
    [self.view endEditing:YES];
    NSString *code = codeField.text;
    if (!code) {
        [self showAlertMsg:@"请输入code"];
        return;
    }
    imgV.image = [MSScanQRCodeCreate scanQRCodeCreate:code CodeSize:imgV.frame.size.width];
}

- (void)btnClicked {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSString *aleartMsg = @"请在\"设置 - 隐私 - 相机\"选项中，允许多客访问您的相机";
        [self showAlertMsg:aleartMsg];
        return;
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined) { //第一次请求。
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
               if (granted){
                   [self scanBegin];
                }
                else{
                    [self showAlertMsg:@"拒绝了相机访问"];
                }
            });
        }];
    }
    else{
        [self scanBegin];
    }
}

- (void)scanBegin{
    __weak typeof(self) weakSelf = self;
    MSScanQRCodeController *scanVC = [[MSScanQRCodeController alloc] init];
    scanVC.qrScanBlock = ^(NSString *scanStr){
        [weakSelf showAlertMsg: scanStr];
    };
    scanVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (void)showAlertMsg: (NSString *) msg {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:cancelA];
    [self presentViewController:alertC animated:YES completion:nil];
}



@end
