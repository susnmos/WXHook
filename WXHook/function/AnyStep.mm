//
//  AnyStep.mm
//  AnyStep
//
//  Created by 王文臻 on 2017/1/26.
//  Copyright (c) 2017年 susnm. All rights reserved.
//

CHOptimizedMethod0(self, unsigned long, WCDeviceStepObject, m7StepCount) {
  if (![CHClass(MicroMessengerAppDelegate) isEnableAnyDayStep]) {
    return CHSuper0(WCDeviceStepObject, m7StepCount);
  }
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  int anyDayStep = [[prefs objectForKey:anyDayStepKey] intValue];
  return anyDayStep;
}

CHOptimizedMethod0(self, unsigned long, WCDeviceStepObject, hkStepCount) {
  if (![CHClass(MicroMessengerAppDelegate) isEnableAnyDayStep]) {
    return CHSuper0(WCDeviceStepObject, hkStepCount);
  }
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: WXPreferencesFile];
  int anyDayStep = [[prefs objectForKey:anyDayStepKey] intValue];
  return anyDayStep;
}
