//
//  SendMsgByMe.mm
//  SendMsgByMe
//
//  Created by 王文臻 on 2017/2/12.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import "Notification.h"

CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, CMessageWrap *, msgWrap) {
  
  CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, msgWrap);
  
  NSString *fromUsr = CHIvar(msgWrap, m_nsFromUsr, NSString *);
  NSString *toUsr = CHIvar(msgWrap, m_nsToUsr, NSString *);
  if ([fromUsr isEqualToString:toUsr]) {
    NSString *content = CHIvar(msgWrap, m_nsContent, NSString *);
    
    if ([content rangeOfString:@"修改步数#"].location != NSNotFound) {
      NSRange range = [content rangeOfString:@"修改步数#"];
      NSString *sideStr =  [content substringFromIndex:range.length];
      CHLog(@"wxhook=== %@",sideStr);
      NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
      CHLog(@"wxhook=== after: %@", prefs);
      prefs[anyDayStepKey] = sideStr;
      [prefs writeToFile:WXPreferencesFile atomically:YES];
      CHLog(@"wxhook=== after: %@", [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile]);
    }
  }
  
}
