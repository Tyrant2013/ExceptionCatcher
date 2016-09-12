//
//  UncaughtExceptinHandler.h
//  ExceptionCatcher
//
//  Created by 庄晓伟 on 16/8/30.
//  Copyright © 2016年 Zhuang Xiaowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject

@property (nonatomic, assign, readonly) BOOL                dismissed;

+ (void)InstallUncaughtExceptionHandler;
+ (NSArray *)backtrace;

- (void)handlerException:(NSException *)exception;

@end
