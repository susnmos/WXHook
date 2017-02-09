//
//  Newline.mm
//  Newline
//
//  Created by 王文臻 on 2017/2/7.
//  Copyright (c) 2017年 susnm. All rights reserved.
//
#import "MMTextView.h"
#import "MMGrowTextView.h"

CHOptimizedMethod1(self, void, MMTextView, _textChanged, NSConcreteNotification *, arg1) {
  MMTextView *textView = [arg1 object];
  NSString *text = [textView text];
  if ([text hasSuffix:@"    "]) {
    NSMutableString *str = [text mutableCopy];
    [str replaceOccurrencesOfString:@"    " withString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, text.length)];
    [textView setText:str];
    
    MMGrowTextView *growTextView = [textView delegate];
    [growTextView adjustRect];
    [growTextView resetScrollPositionForIOS7];
  }
  return CHSuper1(MMTextView, _textChanged, arg1);
}
