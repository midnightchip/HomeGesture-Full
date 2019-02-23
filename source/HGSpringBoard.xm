#import "HomeGesture.h"

bool originalButton;
long _homeButtonType = 1;
long _dismissalSlidingMode = 0;
//SpringBoard Stuff

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


long currentCachedMode = 99;

static CALayer* playbackIcon;
static CALayer* AirPlayIcon;

%hook MediaControlsRoutingButtonView
- (void)_updateGlyph {

    if (self.currentMode == currentCachedMode) { return; }

    currentCachedMode = self.currentMode;


    if (self.layer.sublayers.count >= 1) {
        if (self.layer.sublayers[0].sublayers.count >= 1) {
            if (self.layer.sublayers[0].sublayers[0].sublayers.count == 2) {

                playbackIcon = self.layer.sublayers[0].sublayers[0].sublayers[1].sublayers[0];
                AirPlayIcon = self.layer.sublayers[0].sublayers[0].sublayers[1].sublayers[1];

                if (self.currentMode == 2) { // Play/Pause Mode

                    // Play/Pause Icon
                    playbackIcon.speed = 0.5;

                    [UIView animateWithDuration:1
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{

                                         playbackIcon.transform = CATransform3DMakeScale(-1, -1, 1);
                                         playbackIcon.opacity = 0.75;
                                     }
                                     completion:^(BOOL finished){}];

                    // AirPlay Icon
                    AirPlayIcon.speed = 0.75;

                    [UIView animateWithDuration:1
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         AirPlayIcon.transform = CATransform3DMakeScale(0.85, 0.85, 1);
                                         AirPlayIcon.opacity = -0.75;
                                     }
                                     completion:^(BOOL finished){}];

                } else if (self.currentMode == 0 || self.currentMode == 1) { // AirPlay Mode

                    // Play/Pause Icon
                    playbackIcon.speed = 0.75;

                    [UIView animateWithDuration:1
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{

                                         playbackIcon.transform = CATransform3DMakeScale(-0.85, -0.85, 1);
                                         playbackIcon.opacity = -0.75;
                                     }
                                     completion:^(BOOL finished){}];

                    // AirPlay Icon
                    AirPlayIcon.speed = 0.5;

                    [UIView animateWithDuration:1
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         AirPlayIcon.transform = CATransform3DMakeScale(1, 1, 1);
                                         AirPlayIcon.opacity = 0.75;
                                     }
                                     completion:^(BOOL finished){}];
                }
            }
        }
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

//Enable Torch/Camera buttons on unsupported devices
%hook SBDashBoardQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return YES;
}
%end

// Reinitialize quick action toggles
%hook SBDashBoardQuickActionsView
- (void)_layoutQuickActionButtons {
    %orig;
    for (UIView *subview in self.subviews) {
        if (subview.frame.size.width < 50) {
            if (subview.frame.origin.x < 50) {
                CGRect _frame = subview.frame;
                _frame = CGRectMake(46, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
                //Stupid Compiler, this does actually work, I have no idea why this is getting flagged
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wunused-value"
                [subview init];
                #pragma clang diagnostic pop
            }
            if (subview.frame.origin.x > 100) {
                CGFloat _screenWidth = subview.frame.origin.x + subview.frame.size.width / 2;
                CGRect _frame = subview.frame;
                _frame = CGRectMake(_screenWidth - 96, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wunused-value"
                [subview init];
                #pragma clang diagnostic pop
            }
        }
    }
}
%end

// Override rendered corner radius in app switcher page, (for anytime the fluid switcher gestures are running).
%hook SBAppSwitcherPageView
- (void)_updateCornerRadius {
    if (self.cornerRadius == 20) {
        self.cornerRadius = 5;
    }
    %orig;
    return;
}
%end

// Override Reachability corner radius.
%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return 5;
}
%end

//Icon transition
%hook SBIconView
- (void)setHighlighted:(bool)arg1 {

    if (arg1 == YES) {
        [UIView animateWithDuration:0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{%orig;}
                         completion:^(BOOL finished){ }];
    } else {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{%orig;}
                         completion:^(BOOL finished){ }];
    }
    return;
}
%end

//Home Bar
// Hide HomeBar
%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	if ([prefs boolForKey:@"hideBar"]){
		return %orig;
		}else{
			return NULL;
		}
}
%end

// Coversheet Home Bar Color
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
-(id)initWithFrame:(CGRect)arg1{
  if ([prefs boolForKey:@"hideBar"]){
		return %orig;
		}else{
			return NULL;
		}
}
%end

// Hide home bar in cover sheet
%hook SBDashboardHomeAffordanceView
- (void)_createStaticHomeAffordance {
	if ([prefs boolForKey:@"hideBarCover"]){
		return %orig;
		}else{
			return;
		}
}
%end

//TODO  ADDED HERE

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

// Hide Coversheet Page Dots

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






%ctor{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([bundleID isEqualToString:@"com.apple.springboard"] &&  [fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]) {
        %init();
    }
}


