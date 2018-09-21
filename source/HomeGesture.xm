#include <HomeGesture.h>
#include <CSColorPicker/CSColorPicker.h>
/*
// getting values
UIColor *myColor = [prefs colorForKey:@"kMyColorKey"];
NSString *mystring = [prefs stringForKey:@"kMyColorKey"];
BOOL myBOOL = [prefs boolForKey:@"kMyColorKey"];
int myInt = [prefs intForKey:@"kMyColorKey"];
float myFloat = [prefs floatForKey:@"kMyColorKey"];
double myDouble = [prefs doubleForKey:@"kMyColorKey"];

// setting values
id myValue = @"My Custom Value";
[prefs setObject:myValue forKey:@"kMyCustomValue"];

// removing values
[prefs removeObjectForKey: @"kMyCustomValue"];

// saving prefs
[prefs save];

// save and send notification that prefs have been changed
[prefs saveAndPostNotification];
*/

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import <objc/runtime.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// Definition for detecting iOS version (Required to hide CC Pocket)
#define isGreaterThanOrEqualTo(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/*static NSString *nsDomainString = @"/var/mobile/Library/Preferences/com.midnight.homegesture.plist";
static NSString *nsNotificationString = @"com.midnight.homegesture.plist/post";*/


/*static NSDictionary *prefs;
static NSString *selectedApp1; //Applist stuff
static NSMutableArray *test;
static void loadPrefs() {
NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.midnight.homegestureapplist.plist"];
selectedApp1 = [prefs objectForKey:@"selected"]; //Setting up variables
test = [prefs objectForKey:@"selected"];

}*/

long _dismissalSlidingMode = 0;
bool originalButton;
long _homeButtonType = 1;
int applicationDidFinishLaunching;

// Enable home gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	_homeButtonType = %orig;
	if (originalButton) {
		originalButton = NO;
		return %orig;
	} else {
		return 2;
	}
}
%end

// Hide Carrier Text in Status Bar
%hook UIStatusBarServiceItemView
- (id)_serviceContentsImage {
	if ([prefs boolForKey: @"hidecarrier"]){
		return nil;
		}else{
			return %orig;
		}
	}
- (CGFloat)extraRightPadding {
	if ([prefs boolForKey: @"hidecarrier"]){
		return 0.0f;
		}else{
			return %orig;
		}
	}
- (CGFloat)standardPadding {
	if ([prefs boolForKey: @"hidecarrier"]){
		return 2.0f;
		}else{
			return %orig;
	}
}
%end

// Hide HomeBar
@interface MTLumaDodgePillView : UIView
@end

static BOOL homeEnable = YES;
static BOOL rotateDisable = YES;
%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	if ([prefs boolForKey:@"hideBar"]){
		return %orig;
		}else{
			return NULL;
		}
}
/*-(void)setBackgroundColor:(UIColor*)arg1
{
     %orig([UIColor redColor]);
}*/
%end

// Workaround for TouchID respring bug
%hook SBCoverSheetSlidingViewController
- (void)_finishTransitionToPresented:(_Bool)arg1 animated:(_Bool)arg2 withCompletion:(id)arg3 {
	if ((_dismissalSlidingMode != 1) && (arg1 == 0)) {
		return;
	} else {
		%orig;
	}
}
- (long long)dismissalSlidingMode {
	_dismissalSlidingMode = %orig;
	return %orig;
}
%end

// Hide home bar in cover sheet
@interface SBDashboardHomeAffordanceView : UIView
@end
%hook SBDashboardHomeAffordanceView
- (void)_createStaticHomeAffordance {
	if ([prefs boolForKey:@"hideBarCover"]){
		return %orig;
		}else{
			return;
		}
}
%end

// Restore footer indicators
%hook SBDashBoardViewController
- (void)viewDidLoad {
	originalButton = YES;
	%orig;
}
%end

// Restore button to invoke Siri
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
	if([prefs boolForKey:@"siriHome"]){
		return %orig(_homeButtonType, arg2);
	}else{
		return %orig;
	}
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
	if([prefs boolForKey:@"siriHome"]){
		return %orig(_homeButtonType);
	}else{
		return %orig;
	}
}
%end

// Hide notification hints
%hook NCNotificationListSectionRevealHintView
- (void)_updateHintTitle {
	if(![prefs boolForKey:@"notificationHint"]){
		%orig;
	}else{
		return;
	}
}
%end

// Hide unlock hints
%hook SBDashBoardTeachableMomentsContainerViewController
- (void)_updateTextLabel {
	if(![prefs boolForKey:@"unlockHint"]){
		%orig;
	}else{
		return;
	}
}
%end

// Disable breadcrumb
%hook SBWorkspaceDefaults
- (bool)isBreadcrumbDisabled {
	if (![prefs boolForKey:@"enableBread"]){
		return NO;
	}else{
		return YES;
	}
}
%end

//AppSwitcher Swipe to Kill
%hook SBAppSwitcherSettings
- (long long)effectiveKillAffordanceStyle {
	if([prefs boolForKey:@"enableKill"]){
		return 2;
	}else{
		return %orig;
	}

}
- (NSInteger)killAffordanceStyle {
	if([prefs boolForKey:@"enableKill"]){
		return 2;
	}else{
		return %orig;
	}
}
- (void)setKillAffordanceStyle:(NSInteger)style {
	if([prefs boolForKey:@"enableKill"]){
		%orig(2);
	}else{
		%orig;
	}
}
%end

// Hide Control Center indicator
%hook SBDashBoardTeachableMomentsContainerView
-(void)_addControlCenterGrabber {}
%end

// Hide Torch Button on Coversheet
%hook SBDashBoardQuickActionsViewController
-(BOOL)hasFlashlight{
	if([prefs boolForKey:@"hideTorch"]){
		return NO;
		}else{
			return %orig;
		}
}
// Hide Camera Button on Coversheet
-(BOOL)hasCamera{
	if([prefs boolForKey:@"hideCamera"]){
		return NO;
	}else{
		return %orig;
	}
}
%end

// Disable Gestures Switch
%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
	if(![prefs boolForKey:@"disableGestures"]){
		NSString *test;
		SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
		SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
		test = [frontApp valueForKey:@"_bundleIdentifier"];
		//[SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:test]
		if(homeEnable && rotateDisable && ![SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"blackList" containBundleIdentifier:test]){
			return YES;
		}else{
			return NO;
		}
	}else{
		return NO;
	}
}
%end

static NSString *test;


%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
	//Remap
	applicationDidFinishLaunching = 2;
	%orig;

// Disable Gestures When Keyboard is enabled
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

// Disable Gestures if blacklist is enabled
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
			test = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:test]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
			SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
			test = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:test]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown) {
			rotateDisable = YES;
		}
}
%end


//Remapp

static BOOL remapScreen = YES;
%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
	NSArray * lockHome = @[@104, @101];
	NSArray * lockVol = @[@104, @102, @103];
	if(remapScreen){
		if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
			%orig(lockHome);
			applicationDidFinishLaunching--;
			return;
		}
		%orig;
	}else{
		%orig;
	}
}
%end
%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
	if(remapScreen){
		if (applicationDidFinishLaunching == 1) {
			applicationDidFinishLaunching--;
			return;
		}
	}else{
		%orig;
	}
}
%end
%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
	if(remapScreen){
		return %orig(arg1, _homeButtonType, arg3, arg4);
	}else{
		return %orig(arg1, _homeButtonType + 1, arg3, arg4);
	}
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
	if(remapScreen){
		return %orig(arg1, _homeButtonType);
	}else{
		return %orig(arg1, _homeButtonType+1);
	}
}
%end
//End Remap

// Hide Lockscreen page dots
@interface SBDashBoardPageControl : UIView
@end

%hook SBDashBoardPageControl
-(id)_pageIndicatorColor{
	if ([prefs boolForKey:@"dots"]){
		return [UIColor clearColor];
	}else{
		return %orig;
	}
}
-(id)_currentPageIndicatorColor{
	if ([prefs boolForKey:@"dots"]){
		return [UIColor clearColor];
	}else{
		return %orig;
	}
}
%end

// Lock Screen HomeBar Color
@interface MTStaticColorPillView : UIView
@end



%hook MTStaticColorPillView
-(UIColor *)pillColor {
	if([prefs boolForKey:@"enablePillColor"]){
		return [prefs colorForKey:@"customColor"];
	}else {
		return %orig;
	}
}

-(void)setPillColor:(UIColor *)pillColor {
	if([prefs boolForKey:@"enablePillColor"]){
		pillColor = [prefs colorForKey:@"customColor"];
		%orig(pillColor);
	}else {
		%orig;
	}

}
%end

// Hide Control Center Top Nav Bar (Pocket)
@interface CCUIHeaderPocketView : UIView
@end

%hook CCUIHeaderPocketView
-(void)layoutSubviews{
  %orig;
  if ([self valueForKey:@"_headerBackgroundView"]) {
    UIView *backgroundView = (UIView *)[self valueForKey:@"_headerBackgroundView"];
    backgroundView.hidden = YES;
  }
  if ([self valueForKey:@"_headerLineView"]) {
    UIView *lineView = (UIView *)[self valueForKey:@"_headerLineView"];
    lineView.hidden = YES;
  }
}

//Start FUGap


-(CGRect)contentBounds{

      if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){

        return CGRectMake (0,0,SCREEN_WIDTH,30);

      }

      else{

        return CGRectMake (0,0,SCREEN_WIDTH,65);

      }

  }

  //Make frame match our inset
  -(CGRect)frame {

      return CGRectMake (0,0,SCREEN_WIDTH,[prefs floatForKey:@"vertical"]);

  }

  //Hide header blur
  -(void)setBackgroundAlpha:(double)arg1{

      arg1 = 0.0;
      %orig;

  }

  //Nedded to make buttons work
  -(BOOL)isUserInteractionEnabled {

      return NO;

  }

%end


// Change HomeBar Color on Homescreen
/*%hook MTLumaDodgePillSettings
-(void)setColorAddWhiteness:(double)arg1{
	arg1 = 15;
	%orig(arg1);
}
%end */


// iPhone X Status bar
%hook UIStatusBar_Base
+ (BOOL)forceModern {
	/*NSString *status;
	SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
	status = [frontApp valueForKey:@"_bundleIdentifier"];*/
	if([prefs boolForKey:@"statusBarX"]){
		return [prefs boolForKey:@"statusBarX"];
	}else{
		return %orig;
	}
}
+ (Class)_statusBarImplementationClass {
	if([prefs boolForKey:@"statusBarX"]){
		return [prefs boolForKey:@"statusBarX"] ? NSClassFromString(@"UIStatusBar_Modern") : NSClassFromString(@"UIStatusBar");
	}else{
		return %orig;
	}
}
%end

%hook _UIStatusBar
+ (BOOL)forceSplit {
	if([prefs boolForKey:@"statusBarX"]){
		return [prefs boolForKey:@"statusBarX"];
	}else{
		return %orig;
	}
}
%end

// Hide Status Bar in Control Center (When statusBarX is disabled)
%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
	if ([prefs boolForKey:@"statusBarX"]){
		return %orig;
	}
	else {
		return;
	}
}
%end

%hook UITraitCollection
+ (id)traitCollectionWithDisplayCornerRadius:(CGFloat)arg1 {
	if([prefs boolForKey:@"roundSwitcher"]){
		return %orig(19);
	}else{
		return %orig;
	}
}
- (CGFloat)displayCornerRadius {
	if([prefs boolForKey:@"roundSwitcher"]){
		return 19;
	}else{
		return %orig;
	}
}
- (CGFloat)_displayCornerRadius {
	if([prefs boolForKey:@"roundSwitcher"]){
		return 19;
	}else{
		return %orig;
	}
}
%end


//FUGap
@interface CCUIStatusLabelViewController : UIViewController
-(void)setEdgeInsets:(UIEdgeInsets)arg1 ;
@end

@interface CCUIScrollView : UIScrollView
@end

%hook SBUIChevronView

   //Hide chevron
   -(id)initWithFrame:(CGRect)arg1 {

	return nil;

   }

%end

%hook CCUIStatusLabelViewController

  //Move status labels under notch on iPhone X
  -(void)setEdgeInsets:(UIEdgeInsets)arg1 {

   if (IS_IPHONE_X) {

     arg1 = UIEdgeInsetsMake(30,0,0,0);

   }

   else{

      %orig;

   }

  }

  //kills status labels for dnd, wifi off etc.
  -(void)enqueueStatusUpdate:(id)arg1 forIdentifier:(id)arg2 {

      nil;

  }

%end

%hook CCUIStatusBar

  //Hide CC statusbar on iPhone X
  -(id)initWithFrame:(CGRect)frame{

	return nil;

  }

%end
%hook CCUIScrollView
-(void)setContentInset:(UIEdgeInsets)arg1 {

    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){

       arg1 = UIEdgeInsetsMake([prefs floatForKey:@"verticalLandscape"],0,0,0);
       %orig;

    }

    else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {

     arg1 = UIEdgeInsetsMake([prefs floatForKey:@"vertical"],0,0,0);
     %orig;

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

// Enable simutaneous scrolling and dismissing TODO add if statement for swiping up to kill
%hook SBFluidSwitcherViewController
- (double)_killGestureHysteresis {
  if([prefs boolForKey:@"enableKill"]){
    double orig = %orig;
    return orig == 30 ? 10 : orig;
  }else{
    return %orig;
  }
}
%end


// SOME REALLY COMPLEX STUFF TO DO WITH BUTTONS REMAP? I THINK - MY IQ LEVEL IS NOT HIGH ENOUGH FOR THIS
//You'll understand it, dw
//Thanks :)
//Lol
