#include <HomeGesture.h>
#include <CSColorPicker/CSColorPicker.h>

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import <objc/runtime.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

long _dismissalSlidingMode = 0;
bool originalButton;
long _homeButtonType = 1;
int applicationDidFinishLaunching;


//Quick Setup
@interface SBDashBoardViewController : UIViewController
@property (retain, nonatomic) UIView *welcomeView;
@property (retain, nonatomic) UIView *swipeExplainView;
@property (retain, nonatomic) UIView *thirdView;
@property (retain, nonatomic) UIButton *but;
@property (retain, nonatomic) UIView *swipeUpView;
@end

@interface SBDashBoardViewController (HomeGesture)
-(void)buttonAction;
@end
%group easySetup
%hook SBIdleTimerDefaults

-(double)minimumLockscreenIdleTime {
    // This is iOS 11 onwards
    return 1000;
}

%end

%hook SBDashBoardViewController
%property (retain, nonatomic) UIView *welcomeView;
%property (retain, nonatomic) UIButton *but;
%property (retain, nonatomic) UIView *swipeExplainView;
%property (retain, nonatomic) UIView *swipeUpView;

static NSMutableDictionary *pref = @{}.mutableCopy;

-(void)viewDidLoad {
  %orig;
  // Creating the welcomeView which will hold all the other stuff we add (centralization)
  if(!self.welcomeView){
    self.welcomeView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.welcomeView setBackgroundColor: [UIColor whiteColor]]; //just realised we dont need to color this
    [self.welcomeView setUserInteractionEnabled:TRUE ];
    [self.view addSubview:self.welcomeView];

    self.swipeUpView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.swipeUpView setBackgroundColor: [UIColor whiteColor]]; //just realised we dont need to color this
    [self.swipeUpView setUserInteractionEnabled:TRUE ];
  }
  if(!self.but){
    UIButton *but=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    but.frame= CGRectMake(0, self.welcomeView.frame.size.height, self.welcomeView.frame.size.height/3, 100);
    [but setTitle:@"Begin Setup" forState:UIControlStateNormal];
    but.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    but.titleLabel.font = [UIFont systemFontOfSize:30];
    [but addTarget:self action:@selector(secondView) forControlEvents:UIControlEventTouchUpInside];
    but.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.2 );
    [self.welcomeView addSubview:but];

    //HomeGesture Logo
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width/2-(self.welcomeView.frame.size.height*0.15)/2, 140, self.welcomeView.frame.size.height*0.15, self.welcomeView.frame.size.height*0.15)];
    logo.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/homeGesture.png"];
    [self.welcomeView addSubview:logo];

    //Bold Title at the Top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.welcomeView.frame.size.height/3, self.welcomeView.frame.size.width, 100)];
    bigTitle.text = @"Welcome";

    bigTitle.textAlignment = NSTextAlignmentCenter;
    bigTitle.font = [UIFont boldSystemFontOfSize:40];
    [self.welcomeView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, self.welcomeView.frame.size.height/3+60, self.welcomeView.frame.size.width, 100)];
    description.text = @"Thanks for installing HomeGesture\nLet's get setup fast...";
    description.textAlignment = NSTextAlignmentCenter;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 0;
    description.font = [UIFont systemFontOfSize:20];
    [self.welcomeView addSubview:description];

  }
}
%new
-(void)secondView{
  //set up view
  self.swipeExplainView = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.swipeExplainView setBackgroundColor: [UIColor whiteColor]];
  [self.swipeExplainView setUserInteractionEnabled:TRUE ];

  //Bold Title at the Top
  UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.welcomeView.frame.size.height/45, self.welcomeView.frame.size.width, 100)];
  bigTitle.text = @"Big Title";
  bigTitle.textAlignment = NSTextAlignmentCenter;
  bigTitle.font = [UIFont boldSystemFontOfSize:40];
  [self.swipeExplainView addSubview:bigTitle];

  //Description below Bold Title
  UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, self.welcomeView.frame.size.height/45+50, self.welcomeView.frame.size.width, 100)];
  description.text = @"This is a description of what this feature does";
  description.textAlignment = NSTextAlignmentCenter;
  description.lineBreakMode = NSLineBreakByWordWrapping;
  description.numberOfLines = 0;
  description.font = [UIFont systemFontOfSize:20];
  [self.swipeExplainView addSubview:description];

  //Center Image
  UIImageView *centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.62)/1.777777777)/2, 140, (self.welcomeView.frame.size.height*0.62)/1.777777777, self.welcomeView.frame.size.height*0.62)];
  centerImage.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/siri.png"];
  [self.swipeExplainView addSubview:centerImage];

  UIButton *yesButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
  yesButton.titleLabel.font = [UIFont systemFontOfSize:30];
  yesButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
  [yesButton setTitle:@"Yes" forState:UIControlStateNormal];
  [yesButton addTarget:self action:@selector(firstYes) forControlEvents:UIControlEventTouchUpInside];
  yesButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.15 );
  [self.swipeExplainView addSubview:yesButton];

  UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
  noButton.titleLabel.font = [UIFont systemFontOfSize:20];
  noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
  [noButton setTitle:@"No" forState:UIControlStateNormal];
  [noButton addTarget:self action:@selector(firstNo) forControlEvents:UIControlEventTouchUpInside];
  noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
  [self.swipeExplainView addSubview:noButton];

  //animate changing views
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1];
  [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp  forView:self.view cache:YES];
  self.welcomeView.hidden = TRUE;
  [self.view addSubview:self.swipeExplainView];
  [UIView commitAnimations];
}
%new
-(void)firstYes{
    [pref setObject:[NSNumber numberWithBool:1] forKey:@"someKey"];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp  forView:self.view cache:YES];

    [self.view addSubview:self.swipeUpView];
    [UIView commitAnimations];
  [self thirdView];
}

%new
-(void)firstNo{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"someKey"];

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1];
  [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp  forView:self.view cache:YES];

  [self.view addSubview:self.swipeUpView];
  [UIView commitAnimations];
[self thirdView];
}
%new
-(void) thirdView{

}
%end
%end
//end first run


// Enable Home Gestures
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

// Restore Footer Indicators
%hook SBDashBoardViewController
- (void)viewDidLoad {
	originalButton = YES;
	%orig;
}
%end

// Press Home Button for Siri
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

// Hide Notification Hints
%hook NCNotificationListSectionRevealHintView
- (void)_updateHintTitle {
	if(![prefs boolForKey:@"notificationHint"]){
		%orig;
	}else{
		return;
	}
}
%end

// Hide "Swipe up to unlock" on Coversheet
%hook SBDashBoardTeachableMomentsContainerViewController
- (void)_updateTextLabel {
	if(![prefs boolForKey:@"unlockHint"]){
		%orig;
	}else{
		return;
	}
}
%end

// Disable Breadcrumb
%hook SBWorkspaceDefaults
- (bool)isBreadcrumbDisabled {
	if (![prefs boolForKey:@"enableBread"]){
		return NO;
	}else{
		return YES;
	}
}
%end

// Swipe to Kill in App Switcher
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

//Grid Swicher
/*
-(NSInteger)switcherStyle {
			return 2;
		}
		*/

%end

//Grid Switcher
/*
%hook SBGridSwitcherPersonality
	-(BOOL)shouldShowControlCenter {
		return NO;
	}
%end
*/

// Enable Simutaneous Scrolling and Dismissing
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

// Hide Control Center Indicator on Coversheet
%hook SBDashBoardTeachableMomentsContainerView
-(void)_addControlCenterGrabber {
	if ([prefs boolForKey:@"notificationHint"]){

	}else{
		return %orig;
	}
}
%end

// Hide Torch Button on CoverSheet
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

// Hide Coversheet Page Dots
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

// Coversheet Home Bar Color
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
@interface CCUIStatusLabelViewController : UIViewController
-(void)setEdgeInsets:(UIEdgeInsets)arg1 ;
@end

@interface CCUIScrollView : UIScrollView
@end

-(CGRect)contentBounds{
      if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        return CGRectMake (0,0,SCREEN_WIDTH,30);
      }
      else{
        return CGRectMake (0,0,SCREEN_WIDTH,65);
      }
  }
  //Make Frame Match our Inset
  -(CGRect)frame {
      return CGRectMake (0,0,SCREEN_WIDTH,[prefs floatForKey:@"vertical"]);
  }
  //Hide Header Blur
  -(void)setBackgroundAlpha:(double)arg1{
      arg1 = 0.0;
      %orig;
  }
  //Nedded to Make Buttons Work
  -(BOOL)isUserInteractionEnabled {
      return NO;
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

// iPhone X Status bar
%hook UIStatusBar_Base
+ (BOOL)forceModern {
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

//Hide Status Bar in Control Center
%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
	if ([prefs boolForKey:@"statusBarCC"]){
		return %orig;
	}
	else {
		return;
	}
}
%end

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
%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
	if ([prefs boolForKey:@"remapScreen"]) {
		return %orig(arg1, _homeButtonType, arg3, arg4);
	}
	return %orig;
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
	if ([prefs boolForKey:@"remapScreen"]) {
		return %orig(arg1, _homeButtonType);
	}
	return %orig;
}
%end

%ctor {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
		%init(easySetup);
	}
	%init(_ungrouped);
}
