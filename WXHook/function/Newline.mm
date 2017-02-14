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
  if (![CHClass(MicroMessengerAppDelegate) isEnableInputSpacesNewLine]) {
    return CHSuper1(MMTextView, _textChanged, arg1);
  }
  NSString *countSpacesStr = [[NSString string] stringByPaddingToLength:inputSpaceCount withString:@" " startingAtIndex:0];
  MMTextView *textView = [arg1 object];
  NSString *text = [textView text];
  NSRange selectedRange = NSMakeRange([textView selectedRange].location-1, [textView selectedRange].length);
  
  if ([text rangeOfString:countSpacesStr options:NSBackwardsSearch].location != NSNotFound) {
    NSRange selectedRange = [text rangeOfString:countSpacesStr options:NSBackwardsSearch];
    NSMutableString *str = [text mutableCopy];
    [str replaceOccurrencesOfString:countSpacesStr withString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, text.length)];
    [textView setText:str];
    
    textView.selectedRange = NSMakeRange(selectedRange.location + 1, 0);
    MMGrowTextView *growTextView = [textView delegate];
    [growTextView adjustRect];
    [growTextView resetScrollPositionForIOS7];
    
  }
  
  return CHSuper1(MMTextView, _textChanged, arg1);
}
