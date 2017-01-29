//
//  WXHook.mm
//  WXHook
//
//  Created by 王文臻 on 2017/1/26.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only

int sharetext = 0;
NSString *sharemsg = @"";
BOOL isShared = NO;

CHDeclareClass(TextMessageCellView);
CHDeclareClass(WCNewCommitViewController);
CHDeclareClass(TextMessageViewModel);
CHDeclareClass(MMUIViewController);
CHDeclareClass(CBaseContact);
CHDeclareClass(UINavigationController);
CHDeclareClass(WCFacade);
CHDeclareClass(MMGrowTextView);
CHDeclareClass(MMTextView);

CHOptimizedMethod1(self, void, TextMessageCellView, onForward, id, arg1) {
  [self performSelector: @selector(timeline:) withObject: nil];
}

CHOptimizedMethod1(self, void, WCNewCommitViewController, viewWillAppear, BOOL, animated) {
  if (sharetext) {
    MMGrowTextView *grow =  CHIvar(self, _textView, MMGrowTextView*);
    MMTextView *textView = CHIvar(grow, _textView, MMTextView*);
    [textView setText: sharemsg];
    [grow postTextChangeNotification];
    sharemsg = @"";
    sharetext = 0;
  }
  return CHSuper1(WCNewCommitViewController, viewWillAppear, animated);
}

#pragma mark- 消息转发是退出不保存
CHOptimizedMethod1(self, void, WCNewCommitViewController, writeOldText, id, arg1) {
  if (!isShared) {
    CHSuper1(WCNewCommitViewController, writeOldText, arg1);
  }
}
CHOptimizedMethod0(self, void, WCNewCommitViewController, OnReturn) {
  
  CHSuper0(WCNewCommitViewController, OnReturn);
  
  if (isShared) {
    isShared = NO;
  }
}

CHDeclareClass(UIMenuController)
CHDeclareClass(UIMenuItem)
CHOptimizedMethod1(self, void, UIMenuController, setMenuItems, NSArray *, array) {
  
  UIMenuItem *item = [CHAlloc(UIMenuItem) initWithTitle: @"朋友圈" action: @selector(timeline:)];
  
  NSMutableArray *newArray = [array mutableCopy];
  [newArray insertObject:item atIndex:0];
  CHSuper1(UIMenuController, setMenuItems, newArray);
}

CHDeclareClass(BaseMessageCellView)
CHOptimizedMethod2(self, BOOL, BaseMessageCellView, canPerformAction, SEL, arg1, withSender, id, arg2) {
  BOOL canPerform = CHSuper2(BaseMessageCellView, canPerformAction, arg1, withSender, arg2);
  if (!canPerform) {
    if (arg1 == NSSelectorFromString(@"timeline:")) {
      return YES;
    }
  }
  return canPerform;
}

CHDeclareMethod1(void, BaseMessageCellView, timeline, UIMenuItem *, menu) {

  id vc = CHIvar(self, m_delegate, id);// BaseMsgContentViewController
  
  TextMessageViewModel *msgViewModel = [self viewModel];
  NSString *msgtext = CHIvar(msgViewModel, m_contentText, NSString *);
  CBaseContact *contact = CHIvar(msgViewModel, m_contact, CBaseContact *);
  
  sharemsg = msgtext;
  sharetext = 1;
  
  WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:nil contacts:nil];
  UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
  [wcvc setType: 2];
  [wcvc removeOldText];
  isShared = YES;
  [vc presentViewController:navC animated:YES completion:nil];
  
  NSArray *contacts = [wcvc tempSelectContacts];
  [wcvc GroupTagViewSelectTempContacts: contacts];
  [wcvc setTempSelectContacts: @[contact]];
  WCFacade *facade = [CHAlloc(WCFacade) init];
  [facade onServiceInit];
    [facade setPostPrivacy: 5 withLabelNames: @""];
  [facade setPostPrivacy: 3];
  [wcvc onWCPostPrivacyChanged];
  [wcvc reloadData];
}

CHConstructor // code block that runs immediately upon load
{
  @autoreleasepool
  {
    
    CHLoadLateClass(TextMessageCellView);
    CHHook1(TextMessageCellView, onForward);
    
    CHLoadLateClass(WCNewCommitViewController);
    CHHook1(WCNewCommitViewController, viewWillAppear);
    CHHook1(WCNewCommitViewController, writeOldText);
    CHHook0(WCNewCommitViewController, OnReturn);
    
    CHLoadLateClass(UINavigationController);
    
    CHLoadLateClass(UIMenuController);
    CHLoadLateClass(UIMenuItem);
    CHHook1(UIMenuController, setMenuItems);
    
    CHLoadLateClass(BaseMessageCellView);
    CHHook2(BaseMessageCellView, canPerformAction, withSender);
  }
}
