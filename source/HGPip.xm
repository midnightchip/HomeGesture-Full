#import "HomeGesture.h"
//Pip
// Override MobileGestalt to always return true for PIP key - Acknowledgements: Andrew Wiik (LittleX)
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define k(key_) CFEqual(key, CFSTR(key_))
    if (k("nVh/gwNpy7Jv1NOk00CMrw"))
        return YES;
    return %orig;
}

%ctor{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"pipBlack" containBundleIdentifier:bundleID] &&  [fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]) {
        %init();
    }
}

