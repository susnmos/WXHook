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
  
  dispatch_group_t group = dispatch_group_create();
  dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
  dispatch_group_async(group, queue, ^{
    int index = 0;
    for (SimpleMsgInfo *msgInfo in selectedArr) {
      index++;
      
      NSString *progressStr = [[NSString stringWithFormat:@"%.1f", index/totalCount*100] stringByAppendingString:@" %"];
      if (msgInfo.isImgMsg) {
        NSString *imagePath = msgInfo.getImgPath;
        
        NSString *toExtension = [[[imagePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        NSString *lastPath = [imagesPath stringByAppendingPathComponent:toExtension];
        if (![fileManager fileExistsAtPath:lastPath]) {
          [fileManager copyItemAtPath:imagePath toPath:lastPath error:nil];
//          WXLog(@"wxhook=== file no exits image %u", index);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          progressLabel.text = [NSString stringWithFormat:@"outputing %@", progressStr];
        });
      }else if (msgInfo.isVideoMsg) {
        NSString *imagePath = msgInfo.getImgPath;
        
        NSString *toExtension = [[[imagePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
        NSString *fromPath = [[imagePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:toExtension];
        NSString *toPath = [videoesPath stringByAppendingPathComponent:toExtension];
        if (![fileManager fileExistsAtPath:toPath]) {
          [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
//          WXLog(@"wxhook=== file no exits video %u", index);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          progressLabel.text = [NSString stringWithFormat:@"outputing %@", progressStr];
        });
      }else if (msgInfo.isAppUrlMsg) {
        //        WXLog(@"wxhook=== isAppUrlMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppFileMsg) {
        //        WXLog(@"wxhook=== isAppFileMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppMusicMsg) {
        //        WXLog(@"wxhook=== isAppMusicMsg %u: %@", index, msgInfo);
      }else if (msgInfo.isAppVideoMsg) {
        //        WXLog(@"wxhook=== isAppVideoMsg %u: %@", index, msgInfo);
      }
    }
  });
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    progressLabel.text = [NSString stringWithFormat:@"Outputing Finished"];
  });
  
}

CHOptimizedMethod1(self, void, MsgResourceBrowseViewController, onDeleteSelectedData, id, data) {
  
  MsgFastBrowseView *browseView = CHIvar(self, m_msgFastBrowseView, MsgFastBrowseView *);
  NSArray *selectedMsg = [browseView getSelectedMessages];
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"操作" message:[NSString stringWithFormat:@"删除或者导出群内容到/var/mobile/tmp/WeChat/%@", [self m_nsChatName]] preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
  UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    CHSuper1(MsgResourceBrowseViewController, onDeleteSelectedData, data);
  }];
  __weak typeof(self) weakSelf = self;
  UIAlertAction *outputAction = [UIAlertAction actionWithTitle:@"导出选中" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    [weakSelf outputSelectedMsg: selectedMsg];
  }];
  UIAlertAction *outputAllAction = [UIAlertAction actionWithTitle:@"导出全部" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    NSMutableArray *dataAll = CHIvar(weakSelf, m_arrMsg, NSMutableArray *);
    [weakSelf outputSelectedMsg: dataAll];
  }];
  [alertVC addAction:outputAction];
  [alertVC addAction:deleteAction];
  [alertVC addAction:outputAllAction];
  [alertVC addAction:cancelAction];
  
  [self presentViewController:alertVC animated:YES completion:nil];
}

CHOptimizedMethod0(self, void, MsgResourceBrowseViewController, viewDidLoad) {
  CHSuper0(MsgResourceBrowseViewController, viewDidLoad);
  
  UIImageView *imageView = CHIvar(self, _footerView, UIImageView *);
  UIButton *deleteButton;
  for (NSInteger i=[imageView subviews].count-1; i>=0; i--) {
    UIView *view = [imageView subviews][i];
    if ([view isKindOfClass:[UIButton class]]) {
      deleteButton = (UIButton *)view;
      break;
    }
  }
  if (deleteButton) {
    [deleteButton setTitle:@"操作" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor colorWithRed:0.0745098 green:0.682353 blue:0.141176 alpha:1] forState:UIControlStateNormal];
    deleteButton.enabled = YES;
  }
}
