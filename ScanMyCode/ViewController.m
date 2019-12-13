//
//  ViewController.m
//  ScanMyCode
//
//  Created by Relly on 2019/12/12.
//  Copyright © 2019 Relly. All rights reserved.
//

#import "ViewController.h"
#import "MSScanQRCodeController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 100, 40)];
    [btn setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
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
