//
//  MSScanVC.h
//  PayEase_iphone
//
//  Created by Relly on 15/6/1.
//  Copyright (c) 2015年 Relly. All rights reserved.
//  扫码

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^MSScanQRViewBlock)(void);

@interface MSScanQRCodeView : UIView

@property (nonatomic, copy) MSScanQRViewBlock block;

- (instancetype)initWithFrame:(CGRect)frame captureDevice:(AVCaptureDevice *)device outsideViewLayer:(CALayer *)outsideViewLayer;

/** 移除定时器(切记：一定要在Controller视图消失的时候，停止定时器) */
- (void)removeTimer;

@end
