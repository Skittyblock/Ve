//
//  VeTarget.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeTarget.h"
#import <substrate.h>
#import <objc/runtime.h>
#import <Preferences/PSSpecifier.h>
#import "../../Preferences/PreferenceKeys.h"
#import "../../Preferences/NotificationKeys.h"
#import "../../PrivateHeaders.h"
#import "VeTarget-Swift.h"

void openApplication(NSString *bundleIdentifier) {
    [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] openApplicationWithBundleID:bundleIdentifier];
}

#pragma mark - BulletinBoardController class hooks

/**
 * Adds the main specifier to the notification preference panel.
 */
static void (* orig_BulletinBoardController_viewDidLoad)(BulletinBoardController* self, SEL _cmd);
static void override_BulletinBoardController_viewDidLoad(BulletinBoardController* self, SEL _cmd) {
	orig_BulletinBoardController_viewDidLoad(self, _cmd);

	PSSpecifier* veGroupSpecifier = [PSSpecifier emptyGroupSpecifier];

	PSSpecifier* veButtonSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Notification Logs" target:self set:nil get:nil detail:[VeLogsListController class] cell:PSLinkCell edit:nil];
	[veButtonSpecifier setProperty:@(YES) forKey:@"enabled"];

	[self insertContiguousSpecifiers:@[veGroupSpecifier, veButtonSpecifier] atIndex:0];
}

/**
 * Prevents the notification preference controller from reloading its specifiers on resume.
 *
 * @return Whether to reload the specifiers on resume.
 */
static BOOL override_BulletinBoardController_shouldReloadSpecifiersOnResume(BulletinBoardController* self, SEL _cmd) {
	return NO;
}

/**
 * Installs the BulletinBoardController hooks.
 */
static void installBulletinBoardHooks() {
    static BOOL installed = NO;
    @synchronized ([VeLogsListController class]) {
        if (installed) return;

        Class controller = NSClassFromString(@"BulletinBoardController");
        if (!controller) return;

        installed = YES;

        MSHookMessageEx(controller, @selector(viewDidLoad), (IMP)&override_BulletinBoardController_viewDidLoad, (IMP *)&orig_BulletinBoardController_viewDidLoad);
        MSHookMessageEx(controller, @selector(shouldReloadSpecifiersOnResume), (IMP)&override_BulletinBoardController_shouldReloadSpecifiersOnResume, nil);
    }
}

#pragma mark - PSUIPrefsListController class hooks

/**
 * Sets up the remaining hooks once the notification preference panel has loaded.
 *
 * It is not possible to set the hooks up before the bundle has loaded.
 *
 * @param specifier The specifier that was selected.
 */
static void (* orig_PSUIPrefsListController_lazyLoadBundle)(PSUIPrefsListController* self, SEL _cmd, PSSpecifier* specifier);
static void override_PSUIPrefsListController_lazyLoadBundle(PSUIPrefsListController* self, SEL _cmd, PSSpecifier* specifier) {
	orig_PSUIPrefsListController_lazyLoadBundle(self, _cmd, specifier);

	if ([[specifier identifier] isEqualToString:@"NOTIFICATIONS_ID"]) {
		// enable the remaining hooks when the notifications pane is loaded
		installBulletinBoardHooks();
  	}
}

#pragma mark - Preferences

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
}

#pragma mark - Constructor

/**
 * Initializes the target.
 *
 * First it loads the preferences and continues if Vē is enabled.
 * Secondly it sets up the hooks.
 * Finally it registers the notification callbacks.
 */
__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

    if (@available(iOS 27, *)) {
        // PSUIPrefsListController no longer exists on iOS 27 so we can't use it for bundle load listening
        [[NSNotificationCenter defaultCenter] addObserverForName:NSBundleDidLoadNotification object:nil queue:nil usingBlock:^(NSNotification* notification) {
            installBulletinBoardHooks();
        }];
        installBulletinBoardHooks();
    } else {
        MSHookMessageEx(NSClassFromString(@"PSUIPrefsListController"), @selector(lazyLoadBundle:), (IMP)&override_PSUIPrefsListController_lazyLoadBundle, (IMP *)&orig_PSUIPrefsListController_lazyLoadBundle);
    }

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
