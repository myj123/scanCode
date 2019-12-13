//
//  MSScanVC.h
//  PayEase_iphone
//
//  Created by Relly on 15/6/1.
//  Copyright (c) 2015年 Relly. All rights reserved.
//  扫码

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^MSScanQRCodeBlock)(NSString *);

@interface MSScanQRCodeController:
UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) MSScanQRCodeBlock qrScanBlock;

@end
