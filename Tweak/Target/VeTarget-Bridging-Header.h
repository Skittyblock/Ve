#import "../../Manager/Log.h"
#import "../../Manager/LogManager.h"
#import "../../Preferences/NotificationKeys.h"
#import "../../Preferences/PreferenceKeys.h"
#import "../../PrivateHeaders.h"
#import "../../Utils/DateUtil.h"
#import <Preferences/PSSpecifier.h>

@interface PSListController ()
- (BOOL)shouldReloadSpecifiersOnResume;
@end

void openApplication(NSString *bundleIdentifier);
