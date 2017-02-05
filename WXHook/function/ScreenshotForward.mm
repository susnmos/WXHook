//
//  ScreenshotForward.mm
//  ScreenshotForward
//
//  Created by 王文臻 on 2017/2/5.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <FrontBoard/FBProcessManager.h>
#import <FrontBoard/FBProcess.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBScreenshotManager.h>
#import <SpringBoard/SBScreenshotManagerDataSource.h>

#import "WCNewCommitViewController.h"

#import "Notification.h"

static void userDidTakeScreenshot(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  CHLog(@"wxhook===收到截图通知");
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  if (pasteBoard) {
    UIImage *image = [pasteBoard image];
    CHLog(@"wxhook===拿到了截图 %@", image);
    FBProcessManager *bundleIndetifier = [CHClass(FBProcessManager) sharedInstance];
    NSLog(@"apps bundleIndetifier: %@", bundleIndetifier);
    
    if (!image) {
      return;
    }
    if (CHAlloc(MMImage)) {
      MMImage *mmImage = [CHAlloc(MMImage) initWithImage: image];
      CHLog(@"wxhook===2%@", mmImage);
      WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:@[mmImage] contacts:nil];
      
      [wcvc setType: 1];  // 图片文字
      [wcvc removeOldText];
      isShared = YES;
      UIWindow *window = [UIApplication sharedApplication].keyWindow;
      UITabBarController *tabVC = window.rootViewController;
      UIViewController *vc = tabVC.selectedViewController;
      UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
      [vc presentViewController:navC animated:YES completion:nil];
    }
    
  };
}

#pragma mark- 截图时发出通知
CHOptimizedMethod1(self, void, SBScreenshotManager, saveScreenshotsWithCompletion, id, arg1) {
  CHSuper1(SBScreenshotManager, saveScreenshotsWithCompletion, arg1);
  
  SpringBoard *sprBod = [CHClass(SpringBoard) sharedApplication];
  SBScreenshotManager *manager = [sprBod screenshotManager];
  SBScreenshotManagerDataSource *dataSource = [manager dataSource];
  UIScreen *screen = [UIScreen mainScreen];
  _SBMainScreenScreenshotProvider *provider = [manager _providerForScreen: screen];
  UIImage *image = [provider captureScreenshot];
  
  // notification
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  [pasteBoard setImage:image];
  PostNotification(screenshotNotification);
}
