#include "HGPProvider.h"

@implementation HGPProvider

#pragma mark Initialization

+ (CSPreferencesProvider *)sharedProvider {
    static dispatch_once_t once;
    static CSPreferencesProvider *sharedProvider;
    dispatch_once(&once, ^{

        NSString *tweakId = @"com.vitataf.homegesture";
        NSString *prefsNotification = [tweakId stringByAppendingString:@".prefschanged"];
        NSString *defaultsPath = @"/Library/PreferenceBundles/HomeGesture.bundle/defaults.plist";

        sharedProvider = [[CSPreferencesProvider alloc] initWithTweakID:tweakId defaultsPath:defaultsPath postNotification:prefsNotification notificationCallback:^void (CSPreferencesProvider *provider) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HGPSettingsChanged" object:nil userInfo:nil];
        }];

    });
    return sharedProvider;
}

@end
