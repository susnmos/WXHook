//
//  GroupContentOutput.mm
//  GroupContentOutput
//
//  Created by 王文臻 on 2017/2/15.
//  Copyright (c) 2017年 susnm. All rights reserved.
//

#import "SimpleMsgInfo.h"
#import "MsgResourceBrowseViewController.h"
#import "MsgFastBrowseView.h"

#import <UIKit/UIKit.h>

CHDeclareMethod1(void, MsgResourceBrowseViewController, outputSelectedMsg, NSArray *, selectedArr) {
  NSString *chatName = [self m_nsChatName];
  float totalCount = selectedArr.count;
  CHLog(@"wxhook=== thread: %@", [NSThread currentThread]);
  UIImageView *imageView = CHIvar(self, _footerView, UIImageView *);
  UILabel *progressLabel;
  for (UIView *subView in [imageView subviews]) {
    if ([subView isKindOfClass:[UILabel class]]) {
      progressLabel = (UILabel *)subView;
    }
  }
  progressLabel.hidden = NO;
  progressLabel.text = @"output begin";
  
  NSString *imagesPath = [NSString stringWithFormat:@"/var/mobile/tmp/WeChat/%@/Image", chatName];
  NSString *videoesPath = [NSString stringWithFormat:@"/var/mobile/tmp/WeChat/%@/Video", chatName];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:imagesPath]) {
    [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  if (![fileManager fileExistsAtPath:videoesPath]) {
    [fileManager createDirectoryAtPath:videoesPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
    int index = 0;
    for (SimpleMsgInfo *msgInfo in selectedArr) {
      index++;
      
      NSString *progressStr = [[NSString stringWithFormat:@"%.1f", index/totalCount*100] stringByAppendingString:@" %"];
      if (index == totalCount) {
        progressStr = @" Finished";
      }
      if (msgInfo.isImgMsg) {
        NSString *imagePath = msgInfo.getImgPath;
        
        NSString *toExtension = [[[imagePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        NSString *lastPath = [imagesPath stringByAppendingPathComponent:toExtension];
        [fileManager copyItemAtPath:imagePath toPath:lastPath error:nil];
//        CHLog(@"wxhook=== image %u", index);
        dispatch_async(dispatch_get_main_queue(), ^{
          progressLabel.text = [NSString stringWithFormat:@"outputing %@", progressStr];
        });
      }else if (msgInfo.isVideoMsg) {
        NSString *imagePath = msgInfo.getImgPath;
        
        NSString *toExtension = [[[imagePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
        NSString *fromPath = [[imagePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:toExtension];
        NSString *toPath = [videoesPath stringByAppendingPathComponent:toExtension];
        [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
//        CHLog(@"wxhook=== video %u", index);
        dispatch_async(dispatch_get_main_queue(), ^{
          progressLabel.text = [NSString stringWithFormat:@"outputing %@", progressStr];
        });
      }else if (msgInfo.isAppUrlMsg) {
//        CHLog(@"wxhook=== isAppUrlMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppFileMsg) {
//        CHLog(@"wxhook=== isAppFileMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppMusicMsg) {
//        CHLog(@"wxhook=== isAppMusicMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppVideoMsg) {
//        CHLog(@"wxhook=== isAppVideoMsg %u: %@", index, msgInfo);
      }
    }
  });
  
  
}
CHOptimizedMethod0(self, void, MsgResourceBrowseViewController, onSelecteAll) {
  CHLog(@"wxhook=== MsgResourceBrowseViewController onSelecteAll");
  NSMutableArray *dataArr = CHIvar(self, m_arrMsg, NSMutableArray *);
  
  [self outputSelectedMsg: dataArr];
  
}

CHOptimizedMethod1(self, void, MsgResourceBrowseViewController, onDeleteSelectedData, id, data) {
  CHLog(@"wxhook=== data:%@", data);
  MsgFastBrowseView *browseView = CHIvar(self, m_msgFastBrowseView, MsgFastBrowseView *);
  NSArray *selectedMsg = [browseView getSelectedMessages];
  [self outputSelectedMsg: selectedMsg];
}
