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
#import "WCRedEnvelopesRedEnvelopesHistoryListViewController.h"
#import "WCRedEnvelopesHistoryListControlLogic.h"
#import "WCPayPickerView.h"

CHOptimizedMethod2(self, void, WCPayPickerView, initWithRows, NSArray *, rows, title, NSString *, title) {
  hadRequestTimes = 0;
  NSMutableArray *array = [rows mutableCopy];
  if (array.count - 1 >= 0) {
//    array[array.count-1] = @"今天";
    [array insertObject:@"今天" atIndex:array.count-1];
  }
  return CHSuper2(WCPayPickerView, initWithRows, array, title, title);
}

CHOptimizedMethod2(self, void, WCPayPickerView, setSelectedRow, long long, row, atSession, long long, session) {
  if (showTodayRedHistory) {
    return CHSuper2(WCPayPickerView, setSelectedRow, 4, atSession, 0);
  }
  return CHSuper2(WCPayPickerView, setSelectedRow, row, atSession, session);
}

CHOptimizedMethod1(self, UIView *, WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, WCRedEnvelopesControlData *, data) {
  CHLog(@"wxhook=== data: %@", data);
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
  
  WCRedEnvelopesHistoryListControlLogic *logic = CHIvar(self, m_delegate, WCRedEnvelopesHistoryListControlLogic *);
  CHLog(@"wxhook=== typetypetype: %u", CHIvar(logic, m_enWCRedEnvelopesHistoryType, int)); // 1 发出 0 收到
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if (hadRequestTimes > 15) {
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
  int type = 0;
  for (WCRedEnvelopesReceivedRedEnvelopesInfo *receivedInfo in info.m_arrRecList) {
    if ([receivedInfo.m_nsReceiveTime isEqualToString:@"02-07"]) {
      recTotalNum += 1;
      recTotalAmount += receivedInfo.m_lReceiveAmount;
      type += receivedInfo.m_enWCRedEnvelopesType;
    }
  }
  info.m_lRecTotalNum = recTotalNum;
  info.m_lRecTotalAmount = recTotalAmount;
  info.m_lTotalGameCount = type;
//  info.m_nsCurrentYear = @"今年"; // 用于请求，会请求失败

  UIView *headerView = CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  for (UIView *subView in [headerView subviews]) {
    if ([subView isKindOfClass:CHClass(MMUILabel)]) {
      [(MMUILabel *)subView setText: @"今天"];
      break;
    }
  }
  return headerView;
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
  WCRedEnvelopesReceivedRedEnvelopesInfo *lastInfo = info.m_arrRecList.lastObject;
  if ([lastInfo.m_nsReceiveTime isEqualToString:@"02-07"]) {
    return YES;
  }else {
    return NO;
  }
}

CHOptimizedMethod2(self, void, WCRedEnvelopesRedEnvelopesHistoryListViewController, WCPayPickerViewDidChooseRow, long long, row, atSession, long long, session) {
  CHLog(@"wxhook=== WCPayPickerViewDidChooseRow row: %llu session: %llu", row, session);
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
