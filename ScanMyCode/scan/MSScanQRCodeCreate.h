//
//  MSScanQRCodeCreate.h
//  ScanMyCode
//
//  Created by Relly on 2019/12/13.
//  Copyright © 2019 Relly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSScanQRCodeCreate : NSObject

/// 生成二维码
/// @param code 二维码内容
/// @param size 二维码大小
+ (UIImage *)scanQRCodeCreate: (NSString *)code CodeSize: (CGFloat)size;

@end

NS_ASSUME_NONNULL_END
