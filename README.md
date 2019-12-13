# scanCode
__weak typeof(self) weakSelf = self;
MSScanQRCodeController *scanVC = [[MSScanQRCodeController alloc] init];
scanVC.qrScanBlock = ^(NSString *scanStr){
    [weakSelf showAlertMsg: scanStr];
};
scanVC.modalPresentationStyle = UIModalPresentationFullScreen;
[self presentViewController:scanVC animated:YES completion:nil];

支持扫描二维码与相册扫码
