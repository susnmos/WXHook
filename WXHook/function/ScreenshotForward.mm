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
#import "MMServiceCenter.h"
#import "ForwardMessageMgr.h"
#import "MessageService.h"
#import "CMessageWrap.h"
#import "SettingUtil.h"
#import "MMNewSessionMgr.h"

#import "Notification.h"

#import <KarenLocalizer/KarenLocalizer.h>

static KarenLocalizer *karenLocalizer = [[KarenLocalizer alloc] initWithKarenLocalizerBundle:@"WXHook"];

#pragma mark- 快速截图分享
static void userDidTakeScreenshot(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

  WXLog(@"wxhook===14 get user did screenshot notification==userDidTakeScreenshot");
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  WXLog(@"wxhook===15 UIPasteboard: %@", pasteBoard);
  
  if (!CHClass(SpringBoard) && [pasteBoard image] && [CHClass(MicroMessengerAppDelegate) isEnbScreenshotForward]) {
    UIImage *image = [pasteBoard image];
    WXLog(@"wxhook===16 get image : %@", image);
    WXLog(@"wxhook===18 begin forward screenshot");
    UIViewController *showVC = [CHClass(MicroMessengerAppDelegate) getCurrentShowViewController];
    WXLog(@"wxhook===19 getCurrentShowViewController: %@", showVC);
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: [karenLocalizer karenLocalizeString:@"screenshot_forward"] message:[karenLocalizer karenLocalizeString:@"need_forward_screenshot"] preferredStyle:UIAlertControllerStyleAlert];
    WXLog(@"wxhook===20 alertVC: %@ \n", alertVC);
    // cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:[karenLocalizer karenLocalizeString:@"cancel_save_this_screenshot_to_pasteboard"] style:UIAlertActionStyleDestructive handler: nil];
    // forward timeline action
    UIAlertAction *timeline = [UIAlertAction actionWithTitle:[karenLocalizer karenLocalizeString:@"forward_to_timeline"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
      MMImage *mmImage = [CHAlloc(MMImage) initWithImage: image];
      WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:@[mmImage] contacts:nil];
      
      [wcvc setType: 1];  // 图片文字
      [wcvc removeOldText];
      isShared = YES;
      UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
      [showVC presentViewController:navC animated:YES completion:nil];
    }];
    // forwward firend action
    UIAlertAction *friendAc = [UIAlertAction actionWithTitle:[karenLocalizer karenLocalizeString:@"forward_to_friends"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
      CMessageWrap *msgWrap = [CHAlloc(CMessageWrap) initWithMsgType:3]; // 3: image ; 1: text;
      NSString *userName = [CHClass(SettingUtil) getLocalUsrName:1];
      
      [msgWrap setM_nsFromUsr:userName];
      
      NSData *imageData = UIImageJPEGRepresentation(image, 1);
      [msgWrap setM_dtImg:imageData];
      
      [msgWrap setM_nsToUsr:userName];
      
      MMNewSessionMgr *sessionMgr = [[CHClass(MMServiceCenter) defaultCenter] getService:CHClass(MMNewSessionMgr)];
      unsigned int time = [sessionMgr GenSendMsgTime];
      
      [msgWrap setM_uiCreateTime:time];
      [msgWrap setM_uiStatus:1];
      
      ForwardMessageMgr *forwardMsg = [[CHClass(MMServiceCenter) defaultCenter] getService:CHClass(ForwardMessageMgr)];
      [forwardMsg forwardMessage:msgWrap fromViewController:showVC];
    }];
    
    [alertVC addAction:friendAc];
    [alertVC addAction:timeline];
    [alertVC addAction:cancel];
    
    [showVC presentViewController:alertVC animated:YES completion:nil];
  }
  
}

#pragma mark- 截图时发出通知
CHOptimizedMethod1(self, void, SBScreenshotManager, saveScreenshotsWithCompletion, id, arg1) {
  CHSuper1(SBScreenshotManager, saveScreenshotsWithCompletion, arg1);
  WXLog(@"wxhook===06 begin screenshot");
  SpringBoard *sprBod = [CHClass(SpringBoard) sharedApplication];
  WXLog(@"wxhook===07 springboard: %@", sprBod);
  SBScreenshotManager *manager = [sprBod screenshotManager];
  WXLog(@"wxhook===08 manager: %@", manager);
  SBScreenshotManagerDataSource *dataSource = [manager dataSource];
  WXLog(@"wxhook===09 dataSource: %@", dataSource);
  UIScreen *screen = [UIScreen mainScreen];
  _SBMainScreenScreenshotProvider *provider = [manager _providerForScreen: screen];
  WXLog(@"wxhook===10 privider: %@", provider);
  UIImage *image = [provider captureScreenshot];
  WXLog(@"wxhook===11 get image: %@", image);
  // notification
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  WXLog(@"wxhook===12 get pasteboard for set image: %@", pasteBoard);
  [pasteBoard setImage:image];
  WXLog(@"wxhook===13 will post screenshotNotification");
  PostNotification(screenshotNotification);
}
