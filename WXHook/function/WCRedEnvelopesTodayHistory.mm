//
//  WCRedEnvelopesTodayHistory.mm
//  WCRedEnvelopesTodayHistory
//
//  Created by 王文臻 on 2017/2/7.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import "WCRedEnvelopesControlData.h"
#import "WCRedEnvelopesHistoryInfo.h"
#import "WCRedEnvelopesReceivedRedEnvelopesInfo.h"
#import "WCRedEnvelopesSendedRedEnvelopesInfo.h"
#import "WCRedEnvelopesRedEnvelopesHistoryListViewController.h"
#import "WCRedEnvelopesHistoryListControlLogic.h"
#import "WCPayPickerView.h"

CHOptimizedMethod2(self, void, WCPayPickerView, initWithRows, NSArray *, rows, title, NSString *, title) {
  hadRequestTimes = 0;
  NSMutableArray *array = [rows mutableCopy];
  if (array.count - 1 >= 0) {
    array[array.count-1] = @"今天";
  }
  return CHSuper2(WCPayPickerView, initWithRows, array, title, title);
}

CHOptimizedMethod2(self, void, WCPayPickerView, setSelectedRow, long long, row, atSession, long long, session) {
  if (showTodayRedHistory && !hadChangeRedHistory) {
    return CHSuper2(WCPayPickerView, setSelectedRow, 4, atSession, 0);
  }
  hadChangeRedHistory = NO;
  return CHSuper2(WCPayPickerView, setSelectedRow, row, atSession, session);
}

CHOptimizedMethod1(self, UIView *, WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, WCRedEnvelopesControlData *, data) {
  WXLog(@"wxhook=== data: %@", data);
  WCRedEnvelopesHistoryListControlLogic *logic = CHIvar(self, m_delegate, WCRedEnvelopesHistoryListControlLogic *);
  if (isFinishedRefreshRedHistory) {
    UIView *view =  CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
    if (lastRequest) {
      lastRequest = NO;
      for (UIView *subView in [view subviews]) {
        if ([subView isKindOfClass:CHClass(MMUILabel)]) {
          [(MMUILabel *)subView setText: @"今天"];
          break;
        }
      }
      if (CHIvar(logic, m_enWCRedEnvelopesHistoryType, int) == 0) {
        [(MMUILabel *)[view subviews].lastObject setText: @"加载结束"];
      }else {
        [(MMUILabel *)[view subviews].lastObject setText: @"个"];
      }
      if ([[view subviews][[view subviews].count-2] isKindOfClass:CHClass(MMUILabel)] && CHIvar(logic, m_enWCRedEnvelopesHistoryType, int) == 0) {
        [(MMUILabel *)[view subviews][[view subviews].count-2] setText: @" "];
      }
    }
    return view;
  }
  if (!showTodayRedHistory) {
    return CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  }
  WCRedEnvelopesHistoryInfo *info = [data m_oWCRedEnvelopesHistoryInfo];
  if ((!info || !data) && ![self shouldContinueLoadHistory: data]) {
    return CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  }
  NSString *nowStr = [[CHClass(WCRedEnvelopesRedEnvelopesHistoryListViewController) dateFormatter] stringFromDate:[[NSDate date] autorelease]];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
    int totalRequestTimes = [[prefs objectForKey:totalRedHistoryRequestTimesKey] intValue];
    WXLog(@"wxhook === hadRequest: %u times: %u", hadRequestTimes, totalRequestTimes);
    if (hadRequestTimes > totalRequestTimes) {
      return;
    }
    [logic OnLoadMoreRedEnvelopesList];
    if ([self shouldContinueLoadHistory: data]) {
      hadRequestTimes += 1;
      [self refreshViewWithData:data];
    }
    
    if (![self shouldContinueLoadHistory: data]) {
      [self refreshViewWithData:data];
      isFinishedRefreshRedHistory = YES;
      lastRequest = YES;
      UIView *lastView = CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
      for (UIView *subView in [lastView subviews]) {
        if ([subView isKindOfClass:CHClass(MMUILabel)]) {
          [(MMUILabel *)subView setText: @"今天"];
          break;
        }
      }
      
    }
  });
  
  long long recTotalNum = 0; // 收到红包
  long long recTotalAmount = 0; // 收到总的钱数 单位为分
  
  long long sendTotalNum = 0; // 发送的总红包树
  long long sendTotalAmount = 0; // 发送的总钱数 单位为分
  if (info.m_arrRecList) {
    for (WCRedEnvelopesReceivedRedEnvelopesInfo *receivedInfo in info.m_arrRecList) {
      if ([receivedInfo.m_nsReceiveTime isEqualToString:nowStr]) {
        recTotalNum += 1;
        recTotalAmount += receivedInfo.m_lReceiveAmount;
      }else { break; }
    }
    
    //  info.m_nsCurrentYear = @"今年"; // 用于请求，会请求失败
  }else if (info.m_arrSendList) {
    for (WCRedEnvelopesSendedRedEnvelopesInfo *sendedInfo in info.m_arrSendList) {
      if ([sendedInfo.m_nsSendTime isEqualToString:nowStr]) {
        sendTotalAmount += sendedInfo.m_lTotalAmount;
        sendTotalNum += 1;
      }else { break; }
    }
  }
  info.m_lRecTotalNum = recTotalNum;
  info.m_lRecTotalAmount = recTotalAmount;
  
  info.m_lSendTotalNum = sendTotalNum;
  info.m_lSendTotalAmount = sendTotalAmount;

  UIView *headerView = CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  for (UIView *subView in [headerView subviews]) {
    if ([subView isKindOfClass:CHClass(MMUILabel)]) {
      [(MMUILabel *)subView setText: @"今天"];
      break;
    }
  }
  if (CHIvar(logic, m_enWCRedEnvelopesHistoryType, int) == 0) {
    [(MMUILabel *)[headerView subviews].lastObject setText: @"加载中"];
  }else {
    [(MMUILabel *)[headerView subviews].lastObject setText: @"个"];
  }
  if ([[headerView subviews][[headerView subviews].count-2] isKindOfClass:CHClass(MMUILabel)] && CHIvar(logic, m_enWCRedEnvelopesHistoryType, int) == 0) {
    [(MMUILabel *)[headerView subviews][[headerView subviews].count-2] setText: @" "];
  }
  return headerView;
}

CHOptimizedMethod0(self, void, WCRedEnvelopesRedEnvelopesHistoryListViewController, changeHistoryType) {
  hadChangeRedHistory = YES;
  return CHSuper0(WCRedEnvelopesRedEnvelopesHistoryListViewController, changeHistoryType);
}

CHOptimizedMethod0(self, void, WCRedEnvelopesRedEnvelopesHistoryListViewController, dealloc) {
  isFinishedRefreshRedHistory = NO;
  hadRequestTimes = 0;
  showTodayRedHistory = NO; // 默认是否显示今天的红包收支
  return CHSuper0(WCRedEnvelopesRedEnvelopesHistoryListViewController, dealloc);
}

#pragma mark- declare (class) method
CHDeclareMethod1(BOOL, WCRedEnvelopesRedEnvelopesHistoryListViewController,shouldContinueLoadHistory, WCRedEnvelopesControlData *, data) {

  WCRedEnvelopesHistoryInfo *info = [data m_oWCRedEnvelopesHistoryInfo];
  NSString *nowStr = [[CHClass(WCRedEnvelopesRedEnvelopesHistoryListViewController) dateFormatter] stringFromDate:[[NSDate date] autorelease]];
  WCRedEnvelopesReceivedRedEnvelopesInfo *receivedInfo = info.m_arrRecList.lastObject;
  WCRedEnvelopesSendedRedEnvelopesInfo *sendInfo = info.m_arrSendList.lastObject;
  if ([receivedInfo.m_nsReceiveTime isEqualToString:nowStr] || [sendInfo.m_nsSendTime isEqualToString:nowStr]) {
    return YES;
  }else {
    return NO;
  }
}

CHOptimizedMethod2(self, void, WCRedEnvelopesRedEnvelopesHistoryListViewController, WCPayPickerViewDidChooseRow, long long, row, atSession, long long, session) {
  if (row == 4 && session == 0) {
    showTodayRedHistory = YES;
    isFinishedRefreshRedHistory = NO;
  }else {
    showTodayRedHistory = NO;
    isFinishedRefreshRedHistory = YES;
    if (row == 3 && session == 0) {
      return CHSuper2(WCRedEnvelopesRedEnvelopesHistoryListViewController, WCPayPickerViewDidChooseRow, 4, atSession, 0);
    }
  }
  return CHSuper2(WCRedEnvelopesRedEnvelopesHistoryListViewController, WCPayPickerViewDidChooseRow, row, atSession, session);
}

CHDeclareClassMethod0(NSDateFormatter *, WCRedEnvelopesRedEnvelopesHistoryListViewController, dateFormatter) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"MM-dd";
  return formatter;
}
