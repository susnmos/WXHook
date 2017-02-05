NSString* const WXPreferencesFile = @"/var/mobile/Library/Preferences/com.susnm.WXHook.plist";
static NSString *sharedtext = @"";
static BOOL isShared = NO;
static CFStringRef screenshotNotification = CFSTR("com.susnm.userDidTakeScreenshotNotification");
static NSString *enableProtectiveBodyKey = @"com.susnm.enableProtectiveBody";
static NSString *enableScreenshotForwardKey = @"com.susnm.enableScreenshotForward";
static BOOL isFirstEnterWCNewVC = NO;
