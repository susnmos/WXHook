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

CHOptimizedMethod2(self, void, WCPayPickerView, initWithRows, NSArray *, rows, title, NSString *, title) {
  NSMutableArray *array = [rows mutableCopy];
  if (array.count - 1 >= 0) {
    array[array.count-1] = @"Today";
  }
  return CHSuper2(WCPayPickerView, initWithRows, array, title, title);
}

CHOptimizedMethod1(self, UIView *, WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, WCRedEnvelopesControlData *, data) {
  CHLog(@"wxhook=== data: %@", data);
  if (isFinishedRefreshRedHistory) {
    return CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  }
  WCRedEnvelopesHistoryInfo *info = [data m_oWCRedEnvelopesHistoryInfo];
  if ((!info || !data) && ![self shouldContinueLoadHistory: data]) {
    return CHSuper1(WCRedEnvelopesRedEnvelopesHistoryListViewController, GetHeaderView, data);
  }
  NSString *nowStr = [[CHClass(WCRedEnvelopesRedEnvelopesHistoryListViewController) dateFormatter] stringFromDate:[[NSDate date] autorelease]];
  
  WCRedEnvelopesHistoryListControlLogic *logic = CHIvar(self, m_delegate, WCRedEnvelopesHistoryListControlLogic *);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [logic OnLoadMoreRedEnvelopesList];
    if ([self shouldContinueLoadHistory: data]) {
      [self refreshViewWithData:data];
    }
    
    if (![self shouldContinueLoadHistory: data]) {
      [self refreshViewWithData:data];
      isFinishedRefreshRedHistory = YES;
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
  if (row == 4 || session == 0) {
    showTodayRedHistory = YES;
  }else {
    showTodayRedHistory = NO;
  }
  return CHSuper2(WCRedEnvelopesRedEnvelopesHistoryListViewController, WCPayPickerViewDidChooseRow, row, atSession, session);
}

CHDeclareClassMethod0(NSDateFormatter *, WCRedEnvelopesRedEnvelopesHistoryListViewController, dateFormatter) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"MM-dd";
  return formatter;
}
