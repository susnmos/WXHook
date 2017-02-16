//
//  ForwardMoments.mm
//  ForwardMoments
//
//  Created by 王文臻 on 2017/2/15.
//  Copyright (c) 2017年 susnm. All rights reserved.
//

#import "WCImageCache.h"
#import "WCTimeLineCellView.h"
#import "CContactMgr.h"
#import "WCNewCommitViewController.h"

CHDeclareMethod0(void, WCTimeLineCellView, forwardMessage) {
  WCDataItem *dataItem = CHIvar(self, m_dataItem, WCDataItem *);
  NSString *contentDesc = CHIvar(dataItem, contentDesc, NSString *); // text
  forwardTimeLine = contentDesc;
  
  WCContentItem *contentItem = CHIvar(dataItem, contentObj, WCContentItem *); // image video
  NSMutableArray *mediaList = CHIvar(contentItem, mediaList, NSMutableArray *);
  
  NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:mediaList.count];
  for (WCMediaItem *mediaItem in mediaList) {
    WCImageCache *imageCache = [[CHClass(MMServiceCenter) defaultCenter] getService:CHClass(WCImageCache)];
    UIImage *image = [imageCache getImage:mediaItem ofType:2]; // 2 清晰图 1 模糊图
    MMImage *mmImage = [CHAlloc(MMImage) initWithImage: image];
    [imageArr addObject:mmImage];
  }
  
  WCNewCommitViewController *wcvc = [CHAlloc(WCNewCommitViewController) initWithImages:imageArr contacts:nil];
  
  [wcvc setType: 1];  // 图片文字
  [wcvc removeOldText];
  isShared = YES;
  isFirstEnterWCNewVC = YES;
  
  if ([CHClass(MicroMessengerAppDelegate) isEnableExcludeWhenInTimeline]) {
    NSString *username = CHIvar(dataItem, username, NSString *);
    CContactMgr *contactMgr = [[CHClass(MMServiceCenter) defaultCenter] getService:CHClass(CContactMgr)];
    CBaseContact *contact = [contactMgr getContactByName:username];
    [wcvc setTempSelectContacts: @[contact]];
  }
  
  UINavigationController *currentVC = self.navigationController;
  UINavigationController *navC = [CHAlloc(UINavigationController) initWithRootViewController:wcvc];
  [currentVC presentViewController:navC animated:YES completion:nil];
}

CHOptimizedMethod1(self, void, WCTimeLineCellView, onCommentPhoto, id, arg1) {
  
  CHSuper1(WCTimeLineCellView, onCommentPhoto, arg1);
}
