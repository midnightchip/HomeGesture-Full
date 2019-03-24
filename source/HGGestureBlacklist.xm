#import "HomeGesture.h"
%hook SBHomeGestureSettings
%new 
+ (id)sharedInstance
{
    static SBHomeGestureSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[objc_getClass("SBHomeGestureSettings") alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
%end 