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
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  if (pasteBoard) {
    UIImage *image = [pasteBoard image];
    
    if (!image || !CHAlloc(MMImage) || ![CHClass(MicroMessengerAppDelegate) isEnbScreenshotForward]) {
      return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITabBarController *tabVC = window.rootViewController;
    UIViewController *vc = tabVC.selectedViewController;
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"截图分享" message:@"是否需要将截图分享到朋友圈?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler: nil];
    UIAlertAction *timeline = [UIAlertAction actionWithTitle:@"朋友圈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
      MMImage *mmImage = [CHAlloc(MMImage) initWithImage: image];
      WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:@[mmImage] contacts:nil];
      
      [wcvc setType: 1];  // 图片文字
      [wcvc removeOldText];
      isShared = YES;
      UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
      [vc presentViewController:navC animated:YES completion:nil];
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:timeline];
    
    [vc presentViewController:alertVC animated:YES completion:nil];
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
