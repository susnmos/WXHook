//
//  SendMsgByMe.mm
//  SendMsgByMe
//
//  Created by 王文臻 on 2017/2/12.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import "Notification.h"
#import "CMessageWrap.h"

CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, CMessageWrap *, msgWrap) {
  
//  CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, msgWrap);
  
  NSString *fromUsr = CHIvar(msgWrap, m_nsFromUsr, NSString *);
  NSString *toUsr = CHIvar(msgWrap, m_nsToUsr, NSString *);
  
  if (![fromUsr isEqualToString:toUsr]) return;
  
  NSString *content = msgWrap.m_nsContent;
  
  if ([content rangeOfString:@"修改步数#"].location == NSNotFound) return;
  
  NSRange range = [content rangeOfString:@"修改步数#"];
  NSString *sideStr =  [content substringFromIndex:range.length];
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  CHLog(@"wxhook=== sideStr : %@", sideStr);
  
  if ([sideStr intValue] == 0) {
    msgWrap.m_nsContent = @"修改步数失败";
    return CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, msgWrap);
  }
  
  prefs[anyDayStepKey] = sideStr;
  
  if ([prefs writeToFile:WXPreferencesFile atomically:YES]) {    
    msgWrap.m_nsContent = [NSString stringWithFormat:@"已修改步数为%@", sideStr];
    return CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, msgWrap);
  }
  
}
