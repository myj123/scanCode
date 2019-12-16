//
//  MSScanVC.m
//  PayEase_iphone
//
//  Created by Relly on 15/6/1.
//  Copyright (c) 2015年 Relly. All rights reserved.
//

#import "MSScanQRCodeView.h"
#import <AVFoundation/AVFoundation.h>

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.24
/** 扫描内容的Y值 */
#define scanContent_X self.frame.size.width * 0.15

@interface MSScanQRCodeView ()
@property (nonatomic, strong) CALayer *basedLayer;
@property (nonatomic, strong) AVCaptureDevice *device;
/** 扫描动画线(冲击波) */
@property (nonatomic, strong) UIImageView *animation_line;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MSScanQRCodeView

/** 扫描动画线(冲击波) 的高度 */
static CGFloat const animation_line_H = 12;
/** 扫描内容外部View的alpha值 */
static CGFloat const scanBorderOutsideViewAlpha = 0.4;
/** 定时器和动画的时间 */
static CGFloat const timer_animation_Duration = 0.05;

- (instancetype)initWithFrame:(CGRect)frame captureDevice:(AVCaptureDevice *)device outsideViewLayer:(CALayer *)outsideViewLayer {
    if (self = [super initWithFrame:frame]) {
        _basedLayer = outsideViewLayer;
        self.device = device;
         // 创建扫描边框
         [self setupScanningQRCodeEdging];
    }
    return self;
}

// 创建扫描边框
- (void)setupScanningQRCodeEdging {
    // 扫描内容的创建
    CALayer *scanContent_layer = [[CALayer alloc] init];
    CGFloat scanContent_layerX = scanContent_X;
    CGFloat scanContent_layerY = scanContent_Y;
    CGFloat scanContent_layerW = self.frame.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    scanContent_layer.frame = CGRectMake(scanContent_layerX, scanContent_layerY, scanContent_layerW, scanContent_layerH);
    scanContent_layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    scanContent_layer.borderWidth = 0.7;
    scanContent_layer.backgroundColor = [UIColor clearColor].CGColor;
    [self.basedLayer addSublayer:scanContent_layer];
    
    // 扫描动画添加
    self.animation_line = [[UIImageView alloc] init];
    _animation_line.image = [UIImage imageNamed:@"QRCodeLine"];
    _animation_line.frame = CGRectMake(scanContent_X * 0.5, scanContent_layerY, self.frame.size.width - scanContent_X , animation_line_H);
    [self.basedLayer addSublayer:_animation_line.layer];
    
    // 添加定时器
    self.timer =[NSTimer scheduledTimerWithTimeInterval:timer_animation_Duration target:self selector:@selector(animation_line_action) userInfo:nil repeats:YES];
    
#pragma mark - - - 扫描外部View的创建
    // 顶部layer的创建
    CALayer *top_layer = [[CALayer alloc] init];
    CGFloat top_layerX = 0;
    CGFloat top_layerY = 0;
    CGFloat top_layerW = self.frame.size.width;
    CGFloat top_layerH = scanContent_layerY;
    top_layer.frame = CGRectMake(top_layerX, top_layerY, top_layerW, top_layerH);
    top_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:top_layer];

    // 左侧layer的创建
    CALayer *left_layer = [[CALayer alloc] init];
    CGFloat left_layerX = 0;
    CGFloat left_layerY = scanContent_layerY;
    CGFloat left_layerW = scanContent_X;
    CGFloat left_layerH = scanContent_layerH;
    left_layer.frame = CGRectMake(left_layerX, left_layerY, left_layerW, left_layerH);
    left_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:left_layer];
    
    // 右侧layer的创建
    CALayer *right_layer = [[CALayer alloc] init];
    CGFloat right_layerX = CGRectGetMaxX(scanContent_layer.frame);
    CGFloat right_layerY = scanContent_layerY;
    CGFloat right_layerW = scanContent_X;
    CGFloat right_layerH = scanContent_layerH;
    right_layer.frame = CGRectMake(right_layerX, right_layerY, right_layerW, right_layerH);
    right_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:right_layer];

    // 下面layer的创建
    CALayer *bottom_layer = [[CALayer alloc] init];
    CGFloat bottom_layerX = 0;
    CGFloat bottom_layerY = CGRectGetMaxY(scanContent_layer.frame);
    CGFloat bottom_layerW = self.frame.size.width;
    CGFloat bottom_layerH = self.frame.size.height - bottom_layerY;
    bottom_layer.frame = CGRectMake(bottom_layerX, bottom_layerY, bottom_layerW, bottom_layerH);
    bottom_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:bottom_layer];

    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = CGRectGetMaxY(scanContent_layer.frame) + 30;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 25;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    [self addSubview:promptLabel];
    
    UIView *light_album_view = [[UIView alloc] init];
    if (@available(iOS 11.0, *)) {
        light_album_view.frame = CGRectMake(0, self.frame.size.height -100 -[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom, self.frame.size.width, 100 +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
    } else {
        light_album_view.frame = CGRectMake(0, self.frame.size.height -100, self.frame.size.width, 100);
    }

    light_album_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:light_album_view];
    
    // 添加闪光灯按钮
    [light_album_view addSubview:[self createLightAndAlpmaButton:CGPointMake(self.center.x /2 -50, 10) NorTitle:@"打开闪光灯" SelTitle:@"关闭闪光灯" NorImg:[UIImage imageNamed:@"QRCodeLightOpen"] SelImg:[UIImage imageNamed:@"QRCodeLightClose"] Sel:@selector(light_buttonAction:)]];
    
    // 添加相册按钮
    [light_album_view addSubview:[self createLightAndAlpmaButton:CGPointMake(self.center.x /2 *3 -50, 10) NorTitle:@"相册" SelTitle:nil NorImg:[UIImage imageNamed:@"QRCodeAlbum"] SelImg:nil Sel:@selector(album_buttonAction:)]];

#pragma mark - - - 扫描边角imageView的创建
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"QRCodeTopLeft"];
    UIImageView *left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX, left_imageViewY, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    [self.basedLayer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"QRCodeTopRight"];
    UIImageView *right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(scanContent_layer.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    [self.basedLayer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"QRCodebottomLeft"];
    UIImageView *left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(scanContent_layer.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    [self.basedLayer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"QRCodebottomRight"];
    UIImageView *right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    [self.basedLayer addSublayer:right_imageView_down.layer];

}

- (UIButton *)createLightAndAlpmaButton:(CGPoint)point NorTitle:(NSString *)norTitle SelTitle:(NSString *)selTitle NorImg:(UIImage *)norImg SelImg:(UIImage *)selImg Sel:(SEL)sel {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(point.x, point.y, 100, 80);
    if (norTitle) {
        [button setTitle:norTitle forState:UIControlStateNormal];
    }
    if (selTitle) {
        [button setTitle:selTitle forState:UIControlStateSelected];
    }
    if (norImg) {
        [button setImage:norImg forState:UIControlStateNormal];
    }
    if (selImg) {
        [button setImage:selImg forState:UIControlStateSelected];
    }
    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.titleEdgeInsets = UIEdgeInsetsMake(button.imageView.frame.size.height + 10.0, - button.imageView.bounds.size.width, .0, .0);
    button.imageEdgeInsets = UIEdgeInsetsMake(.0, button.titleLabel.bounds.size.width / 2, button.titleLabel.frame.size.height + 10.0, - button.titleLabel.bounds.size.width / 2);
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - - - 相册选取照片
- (void)album_buttonAction: (UIButton *)button {
    if (self.block) {
        self.block();
    }
}

#pragma mark - - - 照明灯的点击事件
- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) { // 点击打开照明灯
        [self turnOnLight:YES];
        button.selected = YES;
    } else { // 点击关闭照明灯
        [self turnOnLight:NO];
        button.selected = NO;
    }
}

- (void)turnOnLight:(BOOL)on {
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - - - 执行定时器方法
- (void)animation_line_action {
    __block CGRect frame = _animation_line.frame;
    
    static BOOL flag = YES;
    
    if (flag) {
        frame.origin.y = scanContent_Y;
        flag = NO;
        [UIView animateWithDuration:timer_animation_Duration animations:^{
            frame.origin.y += 5;
            self->_animation_line.frame = frame;
        } completion:nil];
    } else {
        if (_animation_line.frame.origin.y >= scanContent_Y) {
            CGFloat scanContent_MaxY = scanContent_Y + self.frame.size.width - 2 * scanContent_X;
            if (_animation_line.frame.origin.y >= scanContent_MaxY - 5) {
                frame.origin.y = scanContent_Y;
                _animation_line.frame = frame;
                flag = YES;
            } else {
                [UIView animateWithDuration:timer_animation_Duration animations:^{
                    frame.origin.y += 5;
                    self->_animation_line.frame = frame;
                } completion:nil];
            }
        } else {
            flag = !flag;
        }
    }
}

#pragma mark - - - 移除定时器
- (void)removeTimer {
    [self.timer invalidate];
    [self.animation_line removeFromSuperview];
    self.animation_line = nil;
}

@end

