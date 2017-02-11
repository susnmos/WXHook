//
//  WXHook.mm
//  WXHook
//
//  Created by 王文臻 on 2017/2/7.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import <UIKit/UIKit.h>

#pragma mark- 配置
CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnbProBody) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnbProBody = [[prefs objectForKey:enableProtectiveBodyKey] boolValue];
  return isEnbProBody;
}

CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnbScreenshotForward) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnbScreenshotForward = [[prefs objectForKey:enableScreenshotForwardKey] boolValue];
  return isEnbScreenshotForward;
}

CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnableAnyDayStep) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnableAnyDayStep = [[prefs objectForKey:enableAnyDayStepKey] boolValue];
  return isEnableAnyDayStep;
}

CHDeclareClassMethod0(UIViewController *, MicroMessengerAppDelegate, getCurrentShowViewController) {
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  return [CHClass(MicroMessengerAppDelegate) presentedVcWithVC: keyWindow.rootViewController];
}

CHDeclareClassMethod1(UIViewController *, MicroMessengerAppDelegate, presentedVcWithVC, UIViewController *, vc) {
  if ([vc isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navVC = (UINavigationController *)vc;
    UIViewController *topVC = navVC.topViewController;
    if (topVC.presentedViewController) {
      return [CHClass(MicroMessengerAppDelegate) presentedVcWithVC: topVC.presentedViewController];
    }
    return topVC;
  }
  if ([vc isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabbarVC = (UITabBarController *)vc;
    UIViewController *selectedVC = tabbarVC.selectedViewController;
    return [CHClass(MicroMessengerAppDelegate) presentedVcWithVC: selectedVC];
  }
  return vc;
}
