//
//  TimelineForward.mm
//  TimelineForward
//
//  Created by 王文臻 on 2017/2/5.
//  Copyright (c) 2017年susnm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WCNewCommitViewController.h"
#import "SightDraft.h"
#import "MMServiceCenter.h"
#import "WCFacade.h"

#pragma mark- 赋值发送消息
CHOptimizedMethod1(self, void, WCNewCommitViewController, viewWillAppear, BOOL, animated) {
  if ([sharedtext length] != 0) {
    MMGrowTextView *grow =  CHIvar(self, _textView, MMGrowTextView*);
    MMTextView *textView = CHIvar(grow, _textView, MMTextView*);
    [textView setText: sharedtext];
    [grow postTextChangeNotification];
    sharedtext = @"";
  }
  if ([forwardTimeLine length] != 0) {
    MMGrowTextView *grow =  CHIvar(self, _textView, MMGrowTextView*);
    MMTextView *textView = CHIvar(grow, _textView, MMTextView*);
    [textView setText: forwardTimeLine];
    [grow postTextChangeNotification];
    forwardTimeLine = @"";
  }
  if ([CHClass(MicroMessengerAppDelegate) isEnbProBody] && isShared && isFirstEnterWCNewVC) {
    WCFacade *facade = [[CHClass(MMServiceCenter) defaultCenter] getService:CHClass(WCFacade)];
    [facade setPostPrivacy:5];
    isFirstEnterWCNewVC = NO;
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

CHOptimizedMethod2(self, BOOL, BaseMessageCellView, canPerformAction, SEL, arg1, withSender, id, arg2) {
  BOOL canPerform = CHSuper2(BaseMessageCellView, canPerformAction, arg1, withSender, arg2);
  
  if (!canPerform) {
    if (arg1 == NSSelectorFromString(@"timeline:")) {
      if ([self isKindOfClass:CHClass(TextMessageCellView)] || [self isKindOfClass: CHClass(ImageMessageCellView)] || [self isKindOfClass: CHClass(VideoMessageCellView)]) {
        return YES;
      }
    }
  }
  return canPerform;
}

#pragma mark- 转发实际执行方法
#pragma mark- text
CHDeclareMethod1(void, BaseMessageCellView, textTimeline, UIMenuItem *, menu) {
  id vc = CHIvar(self, m_delegate, id);// BaseMsgContentViewController
  TextMessageViewModel *msgViewModel = [self viewModel];
  NSString *msgtext = CHIvar(msgViewModel, m_contentText, NSString *);
  
  sharedtext = msgtext;
  
  WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:nil contacts:nil];
  
  [wcvc setType: 2]; // 纯文字
  [wcvc removeOldText];
  isShared = YES;
  isFirstEnterWCNewVC = YES;
  
  if ([CHClass(MicroMessengerAppDelegate) isEnbProBody]) {
    CBaseContact *contact = CHIvar(msgViewModel, m_contact, CBaseContact *);
    [wcvc setTempSelectContacts: @[contact]];
     
  }
  
  UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
  [vc presentViewController:navC animated:YES completion:nil];
}

#pragma mark- image
CHDeclareMethod1(void, ImageMessageCellView, imageTimeline, UIMenuItem *, menu) {
  
  id vc = CHIvar(self, m_delegate, id);
  ImageMessageViewModel *imageViewMdel = [self viewModel];
  NSData *imageData = [imageViewMdel imageData];
  UIImage *image = [UIImage imageWithData:imageData];
  MMImage *mmImage = [CHAlloc(MMImage) initWithImage: image];
  
  
  WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:@[mmImage] contacts:nil];
  
  [wcvc setType: 1];  // 图片文字
  [wcvc removeOldText];
  isShared = YES;
  isFirstEnterWCNewVC = YES;
  
  if ([CHClass(MicroMessengerAppDelegate) isEnbProBody]) {
    CBaseContact *contact = CHIvar(imageViewMdel, m_contact, CBaseContact *);
    [wcvc setTempSelectContacts: @[contact]];
  }
  
  UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
  [vc presentViewController:navC animated:YES completion:nil];
}

#pragma mark- video
CHDeclareMethod1(void, VideoMessageCellView, videoTimeline, UIMenuItem *, menu) {
  id vc = CHIvar(self, m_delegate, id);
  VideoMessageCellView *videoViewMdel = [self viewModel];
  // video path
  NSURL *videoURL = [NSURL fileURLWithPath: [videoViewMdel videoPath]];
  
  // SightDraft
  SightDraft *sight = [CHClass(SightDraft) draftWithVideoURL: videoURL];
  // WCNewCommitViewController
  WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithSightDraft: sight];
  
  [wcvc setBNeedAnimation:NO];
  [wcvc setBShowLocation:YES];
  [wcvc setType: 3]; // 3 小视频
  
  [wcvc setDelegate: vc];
  
  [wcvc removeOldText];
  isShared = YES;
  isFirstEnterWCNewVC = YES;
  
  if ([CHClass(MicroMessengerAppDelegate) isEnbProBody]) {
    CBaseContact *contact = CHIvar(videoViewMdel, m_contact, CBaseContact *);
    [wcvc setTempSelectContacts: @[contact]];
    
  }
  
  UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
  [vc presentViewController:navC animated:YES completion:nil];
}
CHDeclareMethod1(void, BaseMessageCellView, timeline, UIMenuItem *, menu) {
  if ([self isKindOfClass: CHClass(TextMessageCellView)]) {
    [self performSelector: @selector(textTimeline:) withObject: menu];
  }
  else if ([self isKindOfClass: CHClass(ImageMessageCellView)]) {
    [self performSelector: @selector(imageTimeline:) withObject: menu];
  }
  else if ([self isKindOfClass: CHClass(VideoMessageCellView)]) {
    [self performSelector: @selector(videoTimeline:) withObject: menu];
  }
  else {
    [self performSelector: @selector(onForward:) withObject: menu];
  }
}

#pragma mark- 转发视频结束时，退出动画
CHDeclareMethod2(void, BaseMsgContentViewController, animationDidEndRemainView, UIView *, view, hintDataItem, id, item) {
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    CGRect newFrame = view.frame;
    CGSize size = [UIScreen mainScreen].bounds.size;
    newFrame = CGRectMake(0, size.height, size.width, size.height);
    view.frame = newFrame;
  } completion:^(BOOL finished) {
    if (finished) {
      [view removeFromSuperview];
    }
  }];
  
}
