//
//  InSafari.mm
//  InSafari
//
//  Created by 王文臻 on 2017/1/26.
//  Copyright (c) 2017年 susnm. All rights reserved.
//

#import "TextMessageCellView.h"

#import "TextMessageViewModel.h"
#import <SafariServices/SafariServices.h>

CHOptimizedMethod2(self, void, TextMessageCellView, onLinkClicked, id, arg1, withRect, struct CGRect, arg2) {
  if (![CHClass(MicroMessengerAppDelegate) isEnableInSafari]) {
    return CHSuper2(TextMessageCellView, onLinkClicked, arg1, withRect, arg2);
  }
  
  UIViewController *vc = [CHClass(MicroMessengerAppDelegate) getCurrentShowViewController];
  NSURL *url = [NSURL URLWithString:arg1];
  WXLog(@"wxhook=== vc: %@", vc);
  if (url && vc) {
    SFSafariViewController *safariVC = [[[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable:YES] autorelease];    
    WXLog(@"wxhook=== safariVC: %@", safariVC);

    [vc presentViewController:safariVC animated:YES completion:nil];
  }
  
}
