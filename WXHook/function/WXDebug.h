#define WXDEBUG

#if defined(WXDEBUG)
#define WXLog(args...) \
if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/tmp/WeChat/WXlog"]) { \
[[[NSString stringWithFormat: args] stringByAppendingString: @"\n"] writeToFile:@"/var/mobile/tmp/WeChat/WXlog" atomically:YES encoding:NSUTF8StringEncoding error:nil]; \
}else { \
NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:@"/var/mobile/tmp/WeChat/WXlog"]; \
[handle seekToEndOfFile]; \
NSData *dataStr = [[[NSString stringWithFormat: args] stringByAppendingString: @"\n"] dataUsingEncoding:NSUTF8StringEncoding]; \
[handle writeData:dataStr]; \
[handle closeFile]; \
}

#else if
#define WXLog(args...) CHLog(args)
#endif
