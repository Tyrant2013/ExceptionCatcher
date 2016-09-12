//
//  UncaughtExceptinHandler.m
//  ExceptionCatcher
//
//  Created by 庄晓伟 on 16/8/30.
//  Copyright © 2016年 Zhuang Xiaowei. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import <UIKit/UIKit.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

NSString* getAppInfo() {
    NSBundle *bundle = [NSBundle mainBundle];
    UIDevice *device = [UIDevice currentDevice];
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@ (%@) \n Device : %@ \n OS Version : %@ %@]n",
                         bundle.infoDictionary[@"CFBundleDisplayName"],
                         bundle.infoDictionary[@"CFBundleShortVersionString"],
                         bundle.infoDictionary[@"CFBundleVersion"],
                         device.model,
                         device.systemName,
                         device.systemVersion];
    return appInfo;
}

void signalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionCount) {
        return;
    }
    if (signal == 11) {
        NSLog(@"可能原因，内存不足");
    }
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [@{
                                       UncaughtExceptionHandlerSignalKey : @(signal),
                                       UncaughtExceptionHandlerAddressesKey : callStack
                                      } mutableCopy];
    NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Signal %ld was raised. \n%@", nil), signal, getAppInfo()];
    NSException *exception = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                     reason:reason
                                                   userInfo:userInfo];
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handlerException:)
                                                              withObject:exception
                                                           waitUntilDone:YES];
}

@implementation UncaughtExceptionHandler

+ (void)InstallUncaughtExceptionHandler {
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
}

+ (NSArray *)backtrace {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; ++i) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

- (void)handlerException:(NSException *)exception {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}



@end









































