#import <HomeGesture.h>

//Grid Switcher
/*
%hook SBGridSwitcherPersonality
	-(BOOL)shouldShowControlCenter {
		return NO;
	}
%end
*/

/*+ (BOOL)forceSplit {
	if([prefs boolForKey:@"statusBarX"]){
		return [prefs boolForKey:@"statusBarX"];
	}else{
		return %orig;
	}
}*/
/*+ (CGFloat)heightForOrientation:(NSInteger)orientation {
	//if (isActualIPhoneX) return %orig;
	if ([prefs boolForKey:@"statusBarX"]) {
		return [NSClassFromString(@"_UIStatusBarVisualProvider_Split58") intrinsicContentSizeForOrientation:orientation].height;
	}
	return [NSClassFromString(@"_UIStatusBarVisualProvider_iOS") intrinsicContentSizeForOrientation:orientation].height;
}*/
//%end
/*%hook _UIStatusBarVisualProvider_Split58
+(double)referenceWidth{
  return [UIScreen mainScreen].bounds.size.width;
}
%end  */

//Round Screenshot Preview
%hook UITraitCollection
+ (id)traitCollectionWithDisplayCornerRadius:(CGFloat)arg1 {
	if([prefs boolForKey:@"roundScreenshot"]){
		return %orig(19);
	}else{
		return %orig;
	}
}

//Round App Switcher (Bug: Enables Rounded Dock)
- (CGFloat)displayCornerRadius {
	if([prefs boolForKey:@"roundSwitcher"]){
		return [prefs floatForKey:@"switcherRoundness"];
	}else{
		return %orig;
	}
}
%end

// Workaround for crash when launching app and invoking control center simultaneously
%hook SBSceneHandle
- (id)scene {
	@try {
		return %orig;
	}
	@catch (NSException *e) {
		return nil;
	}
}
%end


//Fix Status Bar in Third Party Apps
/*
//Fix the flickering at top and bottom
static BOOL (*old__IS_D2x)();
BOOL _IS_D2x(){
    return YES;
}

//Move the UI up/down respectively
static BOOL (*old___UIScreenHasDevicePeripheryInsets)();
BOOL __UIScreenHasDevicePeripheryInsets() {
  return YES;
}

static void FixTheMotherFuckingStatusBar(){
  if ([prefs boolForKey:@"statusBarX"]) {
		MSHookFunction(((void*)MSFindSymbol(NULL, "_IS_D2x")),(void*)_IS_D2x, (void**)&old__IS_D2x);
		MSHookFunction(((void*)MSFindSymbol(NULL, "__UIScreenHasDevicePeripheryInsets")),(void*)__UIScreenHasDevicePeripheryInsets, (void**)&old___UIScreenHasDevicePeripheryInsets);
  }
}
*/



%ctor {
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
			%init();
			}
	}
}
