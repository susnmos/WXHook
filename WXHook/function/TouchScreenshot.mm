//
//  TouchScreenshot.mm
//  TouchScreenshot
//
//  Created by 王文臻 on 2017/2/7.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BaseMsgContentViewController.h"
#import "Notification.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBSceneManager.h>
#import "MMTitleView.h"

CHOptimizedMethod1(self, void, BaseMsgContentViewController, viewDidAppear, BOOL, animated) {
  WXLog(@"wxhook=== BaseMsgContentViewController viewDidAppear");
  MMUINavigationBar *navBar = (MMUINavigationBar *)[[self navigationController] navigationBar];
  WXLog(@"wxhook=== BaseMsgContentViewController navBar:%@", navBar);
  MMTitleView *titleView;
  for (UIView *subView in [navBar subviews]) {
    if ([subView isKindOfClass:CHClass(MMTitleView)]) {
      titleView = (MMTitleView *)subView;
    }
  }
  if (!titleView) {
    WXLog(@"wxhook=== BaseMsgContentViewController viewdidappear no titleview");
    return CHSuper1(BaseMsgContentViewController, viewDidAppear, animated);;
  }
  WXLog(@"wxhook=== BaseMsgContentViewController titleView:%@", titleView);
  titleView.tag = 20170210;
  __weak typeof(self) weakSelf = self;
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(shouldScreenshot:)];
  longPress.minimumPressDuration = 1;
  [titleView addGestureRecognizer:longPress];
  [longPress autorelease];
  
  return CHSuper1(BaseMsgContentViewController, viewDidAppear, animated);
}

CHOptimizedMethod1(self, void, BaseMsgContentViewController, viewWillDisappear, BOOL, animated) {
  MMUINavigationBar *navBar = (MMUINavigationBar *)[[self navigationController] navigationBar];
  MMTitleView *titleView;
  for (UIView *subView in [navBar subviews]) {
    if ([subView isKindOfClass:CHClass(MMTitleView)]) {
      titleView = (MMTitleView *)subView;
    }
  }
  for (UIGestureRecognizer *recognizer in [titleView gestureRecognizers]) {
    [titleView removeGestureRecognizer: recognizer];
  }
  return CHSuper1(BaseMsgContentViewController, viewWillDisappear, animated);
}
CHOptimizedMethod2(self, BOOL, MMTitleView, pointInside, CGPoint, point, withEvent, UIEvent *, event) {
  if (CHClass(MMTextView) && self.tag == 20170210) {
    CGRect canRect = CGRectMake(-20, -4, 40, 44);
    if (CGRectContainsPoint(canRect, point)) {
      return YES;
    }
  }
  return CHSuper2(MMTitleView, pointInside, point, withEvent, event);
}

static void userScreenshotNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  
  WXLog(@"wxhook=== get need screenshot notification");
  if (CHClass(SpringBoard)) {
    WXLog(@"wxhook=== is springboard");
    SpringBoard *sprBod = [CHClass(SpringBoard) sharedApplication];
    WXLog(@"wxhook=== get springboard: %@", sprBod);
    SBScreenshotManager *manager = [sprBod screenshotManager];
    WXLog(@"wxhook=== SBScreenshotManager: %@", manager);
    [manager saveScreenshots];
  }
}

CHDeclareMethod1(void, BaseMsgContentViewController, shouldScreenshot, UILongPressGestureRecognizer *, recognizer) {
  
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:
      PostNotification(shouldScreenshotNotification);
      WXLog(@"wxhook=== get long press gesture post notification ");
      break;
    default:
      break;
  }
}
