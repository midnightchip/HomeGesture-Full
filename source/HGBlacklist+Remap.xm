#import "HomeGesture.h"


/*int applicationDidFinishLaunching;

%group loadMe
static BOOL homeEnable = YES;
static BOOL rotateDisable = YES;
// Disable Gestures Switch
%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
	if(![prefs boolForKey:@"disableGestures"]){
		NSString *currentApp;
		SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
		SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
		currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
		if(homeEnable && rotateDisable && ![SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"blackList" containBundleIdentifier:currentApp]){
			return YES;
		}else{
			return NO;
		}
	}else{
		return NO;
	}
}
%end

// Disable Gestures (SpringBoard applicationDidFinishLaunching also used in Screenshot Remap!)
static NSString *currentApp;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
	applicationDidFinishLaunching = 2;
	%orig;

// Disable Gestures When Keyboard is Visible
	if([prefs boolForKey:@"stopKeyboard"]){
		[[NSNotificationCenter defaultCenter] addObserver:self
                                         		selector:@selector(keyboardDidShow:)
                                             		name:UIKeyboardDidShowNotification
                                           		object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardDidHide:)
                                             name:UIKeyboardDidHideNotification
                                           object:nil];
			}

// Disable Gestures in Blacklisted Apps
		if ([prefs boolForKey:@"enableBlacklist"]){
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter]
   		addObserver:self selector:@selector(yourMethod:)
   		name:UIDeviceOrientationDidChangeNotification
   		object:[UIDevice currentDevice]];
		}
}

%new
-(void)keyboardDidShow:(NSNotification *)sender
{
    homeEnable = NO;
}

%new
-(void)keyboardDidHide:(NSNotification *)sender
{
    homeEnable = YES;
}

%new
-(void)yourMethod:(NSNotification *)sender {
    UIDevice *currentDevice = sender.object;
    if(currentDevice.orientation == UIDeviceOrientationPortrait) {
			rotateDisable = YES;
    }
		if(currentDevice.orientation == UIDeviceOrientationLandscapeLeft) {
			SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
			currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:currentApp]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
			SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
			currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:currentApp]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown) {
			rotateDisable = YES;
		}
}
%end

//Remap
// Screenshot Remap
%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
	NSArray * lockHome = @[@104, @101];
	NSArray * lockVol = @[@104, @102, @103];
	if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2 && [prefs boolForKey:@"remapScreen"]) {
		%orig(lockHome);
		applicationDidFinishLaunching--;
		return;
	}
	%orig;
}
%end
%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
	if (applicationDidFinishLaunching == 1 && [prefs boolForKey:@"remapScreen"]) {
		applicationDidFinishLaunching--;
		return;
	}
	%orig;
}
%end
%end 

%group kickStart
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
	%orig;
	%init(loadMe)
}
%end 
%end 

%ctor {
  //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
    %init(kickStart);
  }
}*/
/*static BOOL enableGesture(){
	NSLog(@"")
	if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"blackList" containBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]]){
		return NO;
	}else{
		return YES;
	}
}*/
/*@interface PTSettings : NSObject
@end 
@interface _UISettings : PTSettings
@end 
@interface SBUISettings : _UISettings
@end 
@interface SBHomeGestureSettings : SBUISettings
-(void)setHomeGestureEnabled:(BOOL)arg1 ;
@end 

%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
	//return enableGesture();
	NSLog(@"HOMEGESTURE SETTINGNOTIFS");
	[[NSNotificationCenter defaultCenter] addObserver:self
                                         		selector:@selector(keyboardDidShow:)
                                             		name:UIKeyboardDidShowNotification
                                           		object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardDidHide:)
                                             name:UIKeyboardDidHideNotification
                                           object:nil];
		return %orig;

}
%new 
-(void)keyboardDidShow:(NSNotification *)sender{
	NSLog(@"KEYBOARD UP");
	[self setHomeGestureEnabled:FALSE];
}
%new
-(void)keyboardDidHide:(NSNotification *)sender{
	NSLog(@"KEYBOARD DOWN");
	[self setHomeGestureEnabled:TRUE];
}
%end */
/*-(void)setHomeGestureEnabled:(BOOL)arg1{
	%orig(NO);
}*/

//%end 
%group remap 
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
%end 

%ctor{
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
		%init(remap)
	}
}
		//NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
		/*if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"blackList" containBundleIdentifier:bundleID]){
			%init(stopGesture);
			}*/
		//}
	
//}
