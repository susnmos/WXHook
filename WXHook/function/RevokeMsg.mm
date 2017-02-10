//
//  RevokeMsg.mm
//  RevokeMsg
//
//  Created by 王文臻 on 2017/2/10.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import <UIKit/UIKit.h>

// 使用该方法，不会提醒撤销
//CHOptimizedMethod1(self, void, CMessageMgr, onRevokeMsg, id, arg1) {
//  CHSuper1(CMessageMgr, onRevokeMsg, arg1);
//}

// 使用该方法，会提醒撤销
CHOptimizedMethod3(self, void, CMessageMgr, DelMsg, id, arg1, MsgList, id, arg2, DelAll, _Bool, arg3) {
  
}
