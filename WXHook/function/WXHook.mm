//
//  WXHook.mm
//  WXHook
//
//  Created by 王文臻 on 2017/1/26.
//  Copyright (c) 2017年 susnm. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#import "Notification.h"

#pragma mark- 转发朋友圈
#import "TimelineForward.mm"

#pragma mark- 防越狱检测
#import "JailBreakHelper.mm"

#pragma mark- 截图转发
#import "ScreenshotForward.mm"

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

CHConstructor // code block that runs immediately upon load
{
  @autoreleasepool
  {
    
    AddObserver(screenshotNotification, userDidTakeScreenshot);
    
    CHLoadLateClass(WCNewCommitViewController);
    CHHook1(WCNewCommitViewController, viewWillAppear);
    CHHook1(WCNewCommitViewController, writeOldText);
    CHHook0(WCNewCommitViewController, OnReturn);
    
    CHLoadLateClass(UINavigationController);
    CHLoadLateClass(BaseMsgContentViewController);
    
    CHLoadLateClass(UIMenuController);
    CHLoadLateClass(UIMenuItem);
    CHHook1(UIMenuController, setMenuItems);
    
    CHLoadLateClass(BaseMessageCellView);
    CHHook2(BaseMessageCellView, canPerformAction, withSender);
    
    CHLoadLateClass(TextMessageCellView);
    
    CHLoadLateClass(MMServiceCenter);
    CHLoadLateClass(WCFacade);
    
    CHLoadLateClass(TextMessageCellView);
    CHLoadLateClass(ImageMessageCellView);
    CHLoadLateClass(VoiceMessageCellView);
    CHLoadLateClass(VideoMessageCellView);
    CHLoadLateClass(EmoticonMessageCellView);
    
    CHLoadLateClass(ImageMessageViewModel);
    CHLoadLateClass(MMImage);
    CHLoadLateClass(UIImage);
    
    CHLoadLateClass(SightDraft);
    CHLoadLateClass(JailBreakHelper);
    CHHook0(JailBreakHelper, IsJailBreak);
    
    CHLoadLateClass(MicroMessengerAppDelegate);
    
    CHLoadLateClass(SpringBoard);
  
    CHLoadLateClass(SBScreenshotManager);
    CHHook1(SBScreenshotManager, saveScreenshotsWithCompletion);
    CHLoadLateClass(SBScreenshotManagerDataSource);
    CHLoadLateClass(UIScreen);
    CHLoadLateClass(_SBMainScreenScreenshotProvider);
    
    CHLoadLateClass(FBProcessManager);
    CHLoadLateClass(FBProcess);
  }
}
