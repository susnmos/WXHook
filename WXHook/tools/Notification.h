#import <substrate.h>
#import "Constants.h"

#pragma mark #region [ Notifications Helper ]
#define AddObserver(notification, callback) \
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&callback, notification, NULL, \
		CFNotificationSuspensionBehaviorHold);

#define PostNotification(notification) \
CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(), \
notification, NULL, NULL, kCFNotificationDeliverImmediately)

#define NSTrue         			((id) kCFBooleanTrue)
#define NSFalse        			((id) kCFBooleanFalse)
#define NSBool(x)       		((x) ? NSTrue : NSFalse)
