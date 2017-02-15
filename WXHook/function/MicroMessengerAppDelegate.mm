//
//  WXHook.mm
//  WXHook
//
//  Created by 王文臻 on 2017/2/7.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import <UIKit/UIKit.h>

#pragma mark- 配置
CHOptimizedMethod1(self, BOOL, MicroMessengerAppDelegate, applicationDidBecomeActive, id, arg1) {
  CHSuper1(MicroMessengerAppDelegate, applicationDidBecomeActive, arg1);
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  int inputSpaceCountL = [[prefs objectForKey:numberOfSpacesWithNewLine] intValue];
  inputSpaceCount = inputSpaceCountL == 0 ? inputSpaceCount : inputSpaceCountL;
}

CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnableExcludeWhenInTimeline) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnableExcludeWhenInTimeline = [[prefs objectForKey:enableExcludeWhenInTimeline] boolValue];
  return isEnableExcludeWhenInTimeline;
}

CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnableInputSpacesNewLine) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnableInputSpacesNewLine = [[prefs objectForKey:enableInputSpacesNewLine] boolValue];
  return isEnableInputSpacesNewLine;
}

CHDeclareClassMethod0(BOOL, MicroMessengerAppDelegate, isEnableInSafari) {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  BOOL isEnableInSafari = [[prefs objectForKey:enableInSafari] boolValue];
  return isEnableInSafari;
}

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
