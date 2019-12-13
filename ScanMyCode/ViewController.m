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
    __weak typeof(self) weakSelf = self;
    MSScanQRCodeController *scanVC = [[MSScanQRCodeController alloc] init];
    scanVC.qrScanBlock = ^(NSString *scanStr){
        [weakSelf showAlertMsg: scanStr];
    };
    scanVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (void)showAlertMsg: (NSString *) msg {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"扫码结果" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:cancelA];
    [self presentViewController:alertC animated:YES completion:nil];
}



@end
