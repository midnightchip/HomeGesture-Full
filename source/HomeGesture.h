#import <HGPProvider.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#include <CSColorPicker/CSColorPicker.h>

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import <objc/runtime.h>
#import <spawn.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define CURRENT_BUNDLE [NSBundle mainBundle].bundleIdentifier
#define IS_BLOCKED [SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"statusBlack" containBundleIdentifier:CURRENT_BUNDLE]

//Quick Setup
@interface SBDashBoardViewController : UIViewController
@property (retain, nonatomic) UIView *welcomeView;
@property (retain, nonatomic) UIView *swipeExplainView;
@property (retain, nonatomic) UIView *thirdView;
@property (retain, nonatomic) UIButton *but;
@property (retain, nonatomic) UIView *swipeUpView;
@property (retain, nonatomic) UIView *videoView;
@property (retain, nonatomic) UIView *doingAlot;
@property (retain, nonatomic) UIView *controlCenterView;
@property (retain, nonatomic) UIView *statusBarView;
@property (retain, nonatomic) UIView *killStyleView;
@property (retain, nonatomic) UIView *oneHandSSView;
@property (retain, nonatomic) UIView *classicSiriView;
@property (retain, nonatomic) UIView *homeBarView;
@property (retain, nonatomic) UIView *exitView;
@property (retain, nonatomic) UIView *hideView;
@end

@interface SBDashBoardViewController (HomeGesture)
-(void)buttonAction;
-(void)closeWithEase;
-(void)oneHandSS;
-(void)classicSiri;
-(void)homeBar;
-(void)exitSetup;
-(void)graduallyAdjustBrightnessToValue:(CGFloat)endValue;
- (void)startRespring;
@end

//Fancy Button
@interface fancyButton : UIButton
@property (nonatomic, assign) CGFloat highlightAlpha;
@end


@interface MTLumaDodgePillView : UIView
@end

@interface MTStaticColorPillView : UIView
@end

@interface SBDashboardHomeAffordanceView : UIView
@end

@interface SBDashBoardPageControl : UIView
@end

@interface CCUIHeaderPocketView : UIView
@end

@interface CCUIStatusLabelViewController : UIViewController
-(void)setEdgeInsets:(UIEdgeInsets)arg1 ;
@end

@interface CCUIScrollView : UIScrollView
@end

@interface _UIStatusBarVisualProvider_iOS : NSObject
+ (CGSize)intrinsicContentSizeForOrientation:(NSInteger)orientation;
@end


@interface _UIStatusBarVisualProvider_Phone : _UIStatusBarVisualProvider_iOS
@end 

@interface _UIStatusBarVisualProvider_Split : _UIStatusBarVisualProvider_Phone
@end 

@interface _UIStatusBarVisualProvider_Split58 : _UIStatusBarVisualProvider_Split
+(double)referenceWidth;
@end 

@interface _UIStatusBar
+ (void)setVisualProviderClass:(Class)classOb;
@end

@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
@end

@interface UIKeyboardDockView : UIView
@end

@interface MediaControlsRoutingButtonView : UIView
- (long long)currentMode;
@end

@interface SBIconView : UIView
- (void)setHighlighted:(bool)arg1;
@property(nonatomic, getter=isHighlighted) _Bool highlighted;
@end

@interface SBAppSwitcherPageView : UIView
@property(nonatomic, assign) double cornerRadius;
@end

@interface CALayer (CornerAddition)
-(bool)continuousCorners;
@property (assign) bool continuousCorners;
-(void)setContinuousCorners:(bool)arg1;
@end

@interface PTSettings : NSObject
@end 

@interface _UISettings : PTSettings
@end 

@interface SBUISettings : _UISettings
@end 

@interface SBHomeGestureSettings : SBUISettings
+ (SBHomeGestureSettings *)sharedInstance;
@end 

