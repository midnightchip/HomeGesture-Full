#import "HomeGesture.h"

int applicationDidFinishLaunching;
long _homeButtonTypeRemap = 1;
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
	applicationDidFinishLaunching = 2;
	%orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
	NSArray * lockHome = @[@104, @101];
	NSArray * lockVol = @[@104, @102, @103];
	if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
		%orig(lockHome);
		applicationDidFinishLaunching--;
		return;
	}
	%orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
	if (applicationDidFinishLaunching == 1) {
		applicationDidFinishLaunching--;
	return;
	}
%orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
return %orig(arg1, _homeButtonTypeRemap, arg3, arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
return %orig(arg1, _homeButtonTypeRemap);
}
%end
%ctor{
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
      NSFileManager *fileManager = [NSFileManager defaultManager];
      if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]) {
		  if([prefs boolForKey:@"remapScreen"]){
			  %init();
			}
        }
    }
}