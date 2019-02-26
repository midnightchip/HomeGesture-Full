//This is here so I can retain iOS 11 support, without screwing up iOS 12. Yes its a mess. Im sorry :/
#include <CSColorPicker/CSColorPicker.h>
#import <HGPProvider.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import <objc/runtime.h>
#import <spawn.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define SYSTEM_VERSION_LESS_THAN(v)   ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


long _dismissalSlidingMode11 = 0;
bool originalButton11;
long _homeButtonType11 = 1;
int applicationDidFinishLaunching11;


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
@interface fancyButton11 : UIButton
@property (nonatomic, assign) CGFloat highlightAlpha;
@end

@implementation fancyButton11
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.alpha = 0.8;
    }
    else {
        self.alpha = 1.0;
    }
}
@end

%group easySetup
//Hide Swipe Up to unlock on first launch.
%hook SBDashBoardTeachableMomentsContainerViewController
- (void)_updateTextLabel {
    return;
}
%end

//Status Bar
%hook UIStatusBar

@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

-(UIColor *)foregroundColor{
  return [UIColor blackColor];
}

%end


%hook SBDashBoardQuickActionsViewController
-(BOOL)hasFlashlight{
	return NO;
}

// Hide Camera Button on Coversheet
-(BOOL)hasCamera{
	return NO;
}
%end

//Disable Screen Shutting off while setup
%hook SBIdleTimerDefaults

-(double)minimumLockscreenIdleTime {
    // This is iOS 11 onwards
    return 1000;
}

%end

@interface SBDashBoardView : UIView
@end
%hook SBDashBoardView
-(void)layoutSubviews{
  %orig;
  self.backgroundColor = [UIColor whiteColor];
}
%end

%hook SBDashBoardViewController
%property (retain, nonatomic) UIView *welcomeView;
%property (retain, nonatomic) UIButton *but;
%property (retain, nonatomic) UIView *swipeExplainView;
%property (retain, nonatomic) UIView *swipeUpView;
%property (retain, nonatomic) UIView *videoView;
%property (retain, nonatomic) UIView *doingAlot;
%property (retain, nonatomic) UIView *controlCenterView;
%property (retain, nonatomic) UIView *statusBarView;
%property (retain, nonatomic) UIView *killStyleView;
%property (retain, nonatomic) UIView *oneHandSSView;
%property (retain, nonatomic) UIView *classicSiriView;
%property (retain, nonatomic) UIView *homeBarView;
%property (retain, nonatomic) UIView *exitView;
%property (retain, nonatomic) UIView *hideView;

static NSMutableDictionary *pref = @{}.mutableCopy;

-(void)viewDidLoad {
  %orig;
  //self.view.backgroundColor = [UIColor whiteColor];
  // Creating the welcomeView which will hold all the other stuff we add (centralization)
  if(!self.welcomeView){
    self.hideView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.hideView setBackgroundColor: [UIColor whiteColor]];
    [self.hideView setUserInteractionEnabled:FALSE ];
    [self.view addSubview:self.hideView];

    self.welcomeView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.welcomeView setBackgroundColor: [UIColor whiteColor]];
    [self.welcomeView setUserInteractionEnabled:TRUE ];
    [self.view addSubview:self.welcomeView];

    self.swipeUpView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.swipeUpView setBackgroundColor: [UIColor whiteColor]];
    [self.swipeUpView setUserInteractionEnabled:TRUE ];

    self.videoView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.videoView setBackgroundColor: [UIColor whiteColor]];
    [self.videoView setUserInteractionEnabled:TRUE ];

  }
  if(!self.but){

    //Next Button
    fancyButton11 *nextButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        nextButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
        nextButton.layer.cornerRadius = 7.5;
        nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        nextButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.09);
        nextButton.titleLabel.textColor = [UIColor whiteColor];
        nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [nextButton addTarget:self action:@selector(toSwipeUpHome) forControlEvents:UIControlEventTouchUpInside];
        nextButton.highlightAlpha = 0.5;
        [self.welcomeView addSubview:nextButton];

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
-(void) toSwipeUpHome{
    //Set up view
    self.swipeExplainView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.swipeExplainView setBackgroundColor: [UIColor whiteColor]];
    [self.swipeExplainView setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"Get Home Fast";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.swipeExplainView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Swipe up to go Home.";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.swipeExplainView addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/swipeToGoHome.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.swipeExplainView.layer addSublayer:playerLayer];


    [self.welcomeView addSubview:self.swipeExplainView];
    self.swipeExplainView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.swipeExplainView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [player play];
    }];

    //Next Button
    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Next" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.09);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(toDoingAlot) forControlEvents:UIControlEventTouchUpInside];
      [self.swipeExplainView addSubview:enableButton];

}
%new
-(void) toDoingAlot{
    //Set up view
    self.doingAlot = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.doingAlot setBackgroundColor: [UIColor whiteColor]];
    [self.doingAlot setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"Doing a lot?";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.doingAlot addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Swipe up and hold to enter multitasking.";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.doingAlot addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/appSwitcher.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.doingAlot.layer addSublayer:playerLayer];

    //Animate changing views
    [self.welcomeView addSubview: self.doingAlot];
    self.doingAlot.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.doingAlot.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.swipeExplainView removeFromSuperview];
      [player play];
    }];

    //Next Button
    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Next" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.09);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(controlOnDemand) forControlEvents:UIControlEventTouchUpInside];
      [self.doingAlot addSubview:enableButton];

      //Create navigation bar
      UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
      //Make navigation bar background transparent
      [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
      navBar.shadowImage = [UIImage new];
      navBar.translucent = YES;

      UINavigationItem *navItem = [[UINavigationItem alloc] init];

      //Create the back button view
      UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

      UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
      leftButton.backgroundColor = [UIColor clearColor];
      leftButton.frame = leftButtonView.frame;
      [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
      [leftButton setTitle:@"Back" forState:UIControlStateNormal];
      leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      leftButton.autoresizesSubviews = YES;
      leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
      leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [leftButton addTarget:self action:@selector(toSwipeUpHome) forControlEvents:UIControlEventTouchUpInside];
      [leftButtonView addSubview:leftButton];

      //Add back button to navigation bar
      UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
      navItem.leftBarButtonItem = leftBarButton;

      navBar.items = @[ navItem ];
      [self.doingAlot addSubview:navBar];

}
%new
-(void) controlOnDemand{
    //Set up view
    self.controlCenterView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.controlCenterView setBackgroundColor: [UIColor whiteColor]];
    [self.controlCenterView setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"Control On Demand";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.controlCenterView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Swipe down from the top right for the Control Center.";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.controlCenterView addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/controlCentre.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.controlCenterView.layer addSublayer:playerLayer];

    [self.welcomeView addSubview: self.controlCenterView];
    self.controlCenterView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.controlCenterView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.doingAlot removeFromSuperview];
      [player play];
    }];

    //Next Button
    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Next" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.09);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(statusInStyle) forControlEvents:UIControlEventTouchUpInside];
      [self.controlCenterView addSubview:enableButton];

      //Create navigation bar
      UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
      //Make navigation bar background transparent
      [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
      navBar.shadowImage = [UIImage new];
      navBar.translucent = YES;

      UINavigationItem *navItem = [[UINavigationItem alloc] init];

      //Create the back button view
      UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

      UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
      leftButton.backgroundColor = [UIColor clearColor];
      leftButton.frame = leftButtonView.frame;
      [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
      [leftButton setTitle:@"Back" forState:UIControlStateNormal];
      leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      leftButton.autoresizesSubviews = YES;
      leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
      leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [leftButton addTarget:self action:@selector(toDoingAlot) forControlEvents:UIControlEventTouchUpInside];
      [leftButtonView addSubview:leftButton];

      //Add back button to navigation bar
      UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
      navItem.leftBarButtonItem = leftBarButton;

      navBar.items = @[ navItem ];
      [self.controlCenterView addSubview:navBar];

}
%new
-(void) statusInStyle{
    //Set up view
    self.statusBarView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.statusBarView setBackgroundColor: [UIColor whiteColor]];
    [self.statusBarView setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"Status in Style?";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.statusBarView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Style your status bar like the iPhone X?";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.statusBarView addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/statusBar.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.statusBarView.layer addSublayer:playerLayer];

    //Animate changing views
    [self.welcomeView addSubview: self.statusBarView];
    self.statusBarView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.statusBarView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.controlCenterView removeFromSuperview];
      [player play];
    }];

    //Next Button
    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Enable X Status Bar" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.15);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(statusYes) forControlEvents:UIControlEventTouchUpInside];
      [self.statusBarView addSubview:enableButton];

    //Not Now Button
    UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        noButton.titleLabel.font = [UIFont systemFontOfSize:18];
        noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
        [noButton setTitle:@"Not Now" forState:UIControlStateNormal];
        [noButton addTarget:self action:@selector(statusNo) forControlEvents:UIControlEventTouchUpInside];
        noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
        [self.statusBarView addSubview:noButton];

        //Create navigation bar
        UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
        //Make navigation bar background transparent
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navBar.shadowImage = [UIImage new];
        navBar.translucent = YES;

        UINavigationItem *navItem = [[UINavigationItem alloc] init];

        //Create the back button view
        UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = leftButtonView.frame;
        [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
        [leftButton setTitle:@"Back" forState:UIControlStateNormal];
        leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
        leftButton.autoresizesSubviews = YES;
        leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [leftButton addTarget:self action:@selector(controlOnDemand) forControlEvents:UIControlEventTouchUpInside];
        [leftButtonView addSubview:leftButton];

        //Add back button to navigation bar
        UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
        navItem.leftBarButtonItem = leftBarButton;

        navBar.items = @[ navItem ];
        [self.statusBarView addSubview:navBar];


}
%new
-(void)statusYes{
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"statusBarX"];

  [self.welcomeView addSubview: self.killStyleView];
    self.killStyleView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.killStyleView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.statusBarView removeFromSuperview];
    }];
[self closeWithEase];
}
%new
-(void)statusNo{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"statusBarX"];

  [self.welcomeView addSubview: self.killStyleView];
    self.killStyleView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.killStyleView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.statusBarView removeFromSuperview];
    }];
[self closeWithEase];
}
%new
-(void) closeWithEase{
    //Set up view
    self.killStyleView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.killStyleView setBackgroundColor: [UIColor whiteColor]];
    [self.killStyleView setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"Close with Ease";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.killStyleView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Swipe up to close your applications?";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.killStyleView addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/swipeToClose.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.killStyleView.layer addSublayer:playerLayer];

    //Animate changing views
    [self.welcomeView addSubview: self.killStyleView];
    self.killStyleView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.killStyleView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [player play];
    }];

    //Next Button
    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Enable Swipe to Close" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.15);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(closeYes) forControlEvents:UIControlEventTouchUpInside];
      [self.killStyleView addSubview:enableButton];

    UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        noButton.titleLabel.font = [UIFont systemFontOfSize:18];
        noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
        [noButton setTitle:@"Not Now" forState:UIControlStateNormal];
        [noButton addTarget:self action:@selector(closeNo) forControlEvents:UIControlEventTouchUpInside];
        noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
        [self.killStyleView addSubview:noButton];

        //Create navigation bar
        UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
        //Make navigation bar background transparent
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navBar.shadowImage = [UIImage new];
        navBar.translucent = YES;

        UINavigationItem *navItem = [[UINavigationItem alloc] init];

        //Create the back button view
        UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = leftButtonView.frame;
        [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
        [leftButton setTitle:@"Back" forState:UIControlStateNormal];
        leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
        leftButton.autoresizesSubviews = YES;
        leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [leftButton addTarget:self action:@selector(statusInStyle) forControlEvents:UIControlEventTouchUpInside];
        [leftButtonView addSubview:leftButton];

        //Add back button to navigation bar
        UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
        navItem.leftBarButtonItem = leftBarButton;

        navBar.items = @[ navItem ];
        [self.killStyleView addSubview:navBar];


}
%new
-(void)closeYes{
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"enableKill"];

  [self.welcomeView addSubview: self.oneHandSSView];
    self.oneHandSSView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.oneHandSSView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.killStyleView removeFromSuperview];
    }];
[self oneHandSS];
}
%new
-(void)closeNo{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"enableKill"];

   [self.welcomeView addSubview: self.oneHandSSView];
    self.oneHandSSView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.oneHandSSView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.killStyleView removeFromSuperview];
    }];
[self oneHandSS];
}
%new
-(void) oneHandSS{
  //Set up view
  self.oneHandSSView = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.oneHandSSView setBackgroundColor: [UIColor whiteColor]];
  [self.oneHandSSView setUserInteractionEnabled:TRUE ];

  //Bold Title at the top
  UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
  bigTitle.text = @"One Handed?";
  bigTitle.textAlignment = NSTextAlignmentCenter;
  bigTitle.font = [UIFont boldSystemFontOfSize:35];
  [self.oneHandSSView addSubview:bigTitle];

  //Description below Bold Title
  UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
    description.text = @"Take screenshots with Volume Up + Lock?";
    description.textAlignment = NSTextAlignmentCenter;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 0;
    description.font = [UIFont systemFontOfSize:20];
    [self.oneHandSSView addSubview:description];

  //Center Image
  UIImageView *centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width/2-(self.welcomeView.frame.size.height*0.59)/2, 150, self.welcomeView.frame.size.height*0.59, self.welcomeView.frame.size.height*0.59)];
    centerImage.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/screenshot.png"];
    [self.oneHandSSView addSubview:centerImage];

  //Disable Button
  UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    noButton.titleLabel.font = [UIFont systemFontOfSize:18];
    noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
    [noButton setTitle:@"Not Now" forState:UIControlStateNormal];
    [noButton addTarget:self action:@selector(oneHandNo) forControlEvents:UIControlEventTouchUpInside];
    noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
    [self.oneHandSSView addSubview:noButton];

  //Animate changing views
   [self.welcomeView addSubview: self.oneHandSSView];
    self.oneHandSSView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.oneHandSSView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.killStyleView removeFromSuperview];
    }];

  //Enable Button
  fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [enableButton setTitle:@"Enable Feature" forState:UIControlStateNormal];
    [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    enableButton.layer.cornerRadius = 7.5;
    enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.15);
    enableButton.titleLabel.textColor = [UIColor whiteColor];
    enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [enableButton addTarget:self action:@selector(oneHandYes) forControlEvents:UIControlEventTouchUpInside];
    [self.oneHandSSView addSubview:enableButton];

    //Create navigation bar
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
    //Make navigation bar background transparent
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    navBar.translucent = YES;

    UINavigationItem *navItem = [[UINavigationItem alloc] init];

    //Create the back button view
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = leftButtonView.frame;
    [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
    [leftButton setTitle:@"Back" forState:UIControlStateNormal];
    leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    leftButton.autoresizesSubviews = YES;
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftButton addTarget:self action:@selector(closeWithEase) forControlEvents:UIControlEventTouchUpInside];
    [leftButtonView addSubview:leftButton];

    //Add back button to navigation bar
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
    navItem.leftBarButtonItem = leftBarButton;

    navBar.items = @[ navItem ];
    [self.oneHandSSView addSubview:navBar];
}
%new
-(void)oneHandYes{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"remapScreen"];

   [self.welcomeView addSubview: self.classicSiriView];
    self.classicSiriView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.classicSiriView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.oneHandSSView removeFromSuperview];
    }];
[self classicSiri];
}
%new
-(void)oneHandNo{
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"remapScreen"];

  [self.welcomeView addSubview: self.classicSiriView];
    self.classicSiriView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.classicSiriView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.oneHandSSView removeFromSuperview];
    }];
[self classicSiri];
}
%new
-(void) classicSiri{
  //Set up view
  self.classicSiriView = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.classicSiriView setBackgroundColor: [UIColor whiteColor]];
  [self.classicSiriView setUserInteractionEnabled:TRUE ];

  //Bold Title at the top
  UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
  bigTitle.text = @"Classic Siri?";
  bigTitle.textAlignment = NSTextAlignmentCenter;
  bigTitle.font = [UIFont boldSystemFontOfSize:35];
  [self.classicSiriView addSubview:bigTitle];

  //Description below Bold Title
  UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
    description.text = @"Don't like the power button? Hold Home to access Siri!";
    description.textAlignment = NSTextAlignmentCenter;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 0;
    description.font = [UIFont systemFontOfSize:20];
    [self.classicSiriView addSubview:description];

  //Center Image
  UIImageView *centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, (self.welcomeView.frame.size.height*0.59)/1.777777777, self.welcomeView.frame.size.height*0.59)];
    centerImage.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/siri.png"];
    [self.classicSiriView addSubview:centerImage];

  //Disable Button
  UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    noButton.titleLabel.font = [UIFont systemFontOfSize:18];
    noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, self.welcomeView.frame.size.width, 100);
    [noButton setTitle:@"Hold Lock Button" forState:UIControlStateNormal];
    [noButton addTarget:self action:@selector(siriNo) forControlEvents:UIControlEventTouchUpInside];
    noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
    [self.classicSiriView addSubview:noButton];

  //Animate changing views
  [self.welcomeView addSubview: self.classicSiriView];
    self.classicSiriView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.classicSiriView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.oneHandSSView removeFromSuperview];
    }];

  //Enable Button
  fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [enableButton setTitle:@"Hold Home for Siri" forState:UIControlStateNormal];
    [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    enableButton.layer.cornerRadius = 7.5;
    enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.15);
    enableButton.titleLabel.textColor = [UIColor whiteColor];
    enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [enableButton addTarget:self action:@selector(siriYes) forControlEvents:UIControlEventTouchUpInside];
    [self.classicSiriView addSubview:enableButton];

    //Create navigation bar
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
    //Make navigation bar background transparent
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    navBar.translucent = YES;

    UINavigationItem *navItem = [[UINavigationItem alloc] init];

    //Create the back button view
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = leftButtonView.frame;
    [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
    [leftButton setTitle:@"Back" forState:UIControlStateNormal];
    leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    leftButton.autoresizesSubviews = YES;
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftButton addTarget:self action:@selector(oneHandSS) forControlEvents:UIControlEventTouchUpInside];
    [leftButtonView addSubview:leftButton];

    //Add back button to navigation bar
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
    navItem.leftBarButtonItem = leftBarButton;

    navBar.items = @[ navItem ];
    [self.classicSiriView addSubview:navBar];
}
%new
-(void)siriYes{
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"siriHome"];

  [self.welcomeView addSubview: self.homeBarView];
    self.homeBarView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.homeBarView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.classicSiriView removeFromSuperview];
    }];
[self homeBar];
}
%new
-(void)siriNo{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"siriHome"];

  [self.welcomeView addSubview: self.homeBarView];
    self.homeBarView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.homeBarView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.classicSiriView removeFromSuperview];
    }];
[self homeBar];
}
%new
-(void)homeBar{
  //Set up view
  self.homeBarView = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.homeBarView setBackgroundColor: [UIColor whiteColor]];
  [self.homeBarView setUserInteractionEnabled:TRUE ];

  //Bold Title at the top
  UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
  bigTitle.text = @"Forgot Everything?";
  bigTitle.textAlignment = NSTextAlignmentCenter;
  bigTitle.font = [UIFont boldSystemFontOfSize:35];
  [self.homeBarView addSubview:bigTitle];

  //Description below Bold Title
  UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
    description.text = @"Enable the Home Bar indicator?";
    description.textAlignment = NSTextAlignmentCenter;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 0;
    description.font = [UIFont systemFontOfSize:20];
    [self.homeBarView addSubview:description];

    //Center Video
    CGFloat width = (self.welcomeView.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.welcomeView.frame.size.height*0.59;
    NSString *moviePath = @"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/homeBar.mp4";
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(self.welcomeView.frame.size.width/2-((self.welcomeView.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:[player currentItem]];
    [self.homeBarView.layer addSublayer:playerLayer];
    [player play];

  //Disable Button
  UIButton *noButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    noButton.titleLabel.font = [UIFont systemFontOfSize:18];
    noButton.frame= CGRectMake(self.welcomeView.frame.size.width/3, self.welcomeView.frame.size.height, 100, 100);
    [noButton setTitle:@"Not Now" forState:UIControlStateNormal];
    [noButton addTarget:self action:@selector(homeBarNo) forControlEvents:UIControlEventTouchUpInside];
    noButton.center = CGPointMake(self.welcomeView.frame.size.width/2, self.welcomeView.frame.size.height/1.05 );
    [self.homeBarView addSubview:noButton];

  //Animate changing views
  [self.welcomeView addSubview: self.homeBarView];
    self.homeBarView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.homeBarView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.classicSiriView removeFromSuperview];
    }];

  //Enable Button
  fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [enableButton setTitle:@"Enable Home Bar" forState:UIControlStateNormal];
    [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    enableButton.layer.cornerRadius = 7.5;
    enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.15);
    enableButton.titleLabel.textColor = [UIColor whiteColor];
    enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [enableButton addTarget:self action:@selector(homeBarYes) forControlEvents:UIControlEventTouchUpInside];
    [self.homeBarView addSubview:enableButton];

    //Create navigation bar
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
    //Make navigation bar background transparent
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    navBar.translucent = YES;

    UINavigationItem *navItem = [[UINavigationItem alloc] init];

    //Create the back button view
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = leftButtonView.frame;
    [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
    [leftButton setTitle:@"Back" forState:UIControlStateNormal];
    leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    leftButton.autoresizesSubviews = YES;
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftButton addTarget:self action:@selector(classicSiri) forControlEvents:UIControlEventTouchUpInside];
    [leftButtonView addSubview:leftButton];

    //Add back button to navigation bar
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
    navItem.leftBarButtonItem = leftBarButton;

    navBar.items = @[ navItem ];
    [self.homeBarView addSubview:navBar];
}
%new
-(void)homeBarYes{
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"hideBar"];
  [pref setObject:[NSNumber numberWithBool:1] forKey:@"hideBarCover"];

  [self.welcomeView addSubview: self.exitView];
    self.exitView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.exitView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.homeBarView removeFromSuperview];
    }];

[self exitSetup];

}
%new
-(void)homeBarNo{
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"hideBar"];
  [pref setObject:[NSNumber numberWithBool:0] forKey:@"hideBarCover"];

  [self.welcomeView addSubview: self.exitView];
    self.exitView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.exitView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.homeBarView removeFromSuperview];
    }];
[self exitSetup];
}
%new
-(void) exitSetup{
    //Set up view
    self.exitView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.exitView setBackgroundColor: [UIColor whiteColor]];
    [self.exitView setUserInteractionEnabled:TRUE ];

    //Bold Title at the top
    UILabel *bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.welcomeView.frame.size.width, 100)];
      bigTitle.text = @"All Done";
      bigTitle.textAlignment = NSTextAlignmentCenter;
      bigTitle.font = [UIFont boldSystemFontOfSize:35];
      [self.exitView addSubview:bigTitle];

    //Description below Bold Title
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width*0.1, 75, self.welcomeView.frame.size.width*0.8, 100)];
      description.text = @"Setup must respring to complete changes.";
      description.textAlignment = NSTextAlignmentCenter;
      description.lineBreakMode = NSLineBreakByWordWrapping;
      description.numberOfLines = 0;
      description.font = [UIFont systemFontOfSize:20];
      [self.exitView addSubview:description];

      //Center Image
      UIImageView *centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.welcomeView.frame.size.width/2-185, 150, 370, 370)];
        centerImage.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/final.png"];
        [self.exitView addSubview:centerImage];

    //Animate changing views
    [self.welcomeView addSubview: self.exitView];
    self.exitView.center = CGPointMake(self.welcomeView.frame.size.width/2 + 350, self.welcomeView.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
    ///Move new view into frame and above old view
    self.exitView.center = self.welcomeView.center;
    }
    completion:^(BOOL finished){
      [self.homeBarView removeFromSuperview];
    }];

    fancyButton11 *enableButton = [[fancyButton11 alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
      [enableButton setTitle:@"Finish and Respring" forState:UIControlStateNormal];
      [enableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      enableButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      enableButton.layer.cornerRadius = 7.5;
      enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      enableButton.center = CGPointMake(self.view.frame.size.width / 2, self.welcomeView.frame.size.height/1.09);
      enableButton.titleLabel.textColor = [UIColor whiteColor];
      enableButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [enableButton addTarget:self action:@selector(cleanUp) forControlEvents:UIControlEventTouchUpInside];
      [self.exitView addSubview:enableButton];

      //Create navigation bar
      UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.welcomeView.frame.size.width, 50)];
      //Make navigation bar background transparent
      [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
      navBar.shadowImage = [UIImage new];
      navBar.translucent = YES;

      UINavigationItem *navItem = [[UINavigationItem alloc] init];

      //Create the back button view
      UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];

      UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
      leftButton.backgroundColor = [UIColor clearColor];
      leftButton.frame = leftButtonView.frame;
      [leftButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HomeGesture.bundle/quickSetup/back.png"] forState:UIControlStateNormal];
      [leftButton setTitle:@"Back" forState:UIControlStateNormal];
      leftButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
      leftButton.autoresizesSubviews = YES;
      leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
      leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
      [leftButton addTarget:self action:@selector(homeBar) forControlEvents:UIControlEventTouchUpInside];
      [leftButtonView addSubview:leftButton];

      //Add back button to navigation bar
      UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
      navItem.leftBarButtonItem = leftBarButton;

      navBar.items = @[ navItem ];
      [self.exitView addSubview:navBar];
}
%new
-(void)cleanUp{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager createDirectoryAtPath:@"/var/mobile/Library/Preferences/HomeGesture/" withIntermediateDirectories:NO attributes:nil error:nil];
  [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup" contents:nil attributes:nil];
  [pref writeToFile:@"/var/mobile/Library/Preferences/com.vitataf.homegesture.plist" atomically:YES];
  [self startRespring];

}
%new
- (void)startRespring {
    //make a visual effect view to fade in for the blur
    [self.view endEditing:YES]; //save changes to text fields and dismiss keyboard

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    visualEffectView.frame = [[UIApplication sharedApplication] keyWindow].bounds;
    visualEffectView.alpha = 0.0;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:visualEffectView];

    //animate in the alpha
    [UIView animateWithDuration:3.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         visualEffectView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             NSLog(@"Squiddy says hello");
                             NSLog(@"Midnight replys with 'where am I?'");
                             //call the animation here for the screen fade and respring
                             [self graduallyAdjustBrightnessToValue:0.0f];
                         }
                     }];

    //sleep(15);

    //[[UIScreen mainScreen] setBrightness:0.0f]; //so the screen fades back in when the respringing is done
}
%new
- (void)graduallyAdjustBrightnessToValue:(CGFloat)endValue{
    CGFloat startValue = [[UIScreen mainScreen] brightness];

    CGFloat fadeInterval = 0.01;
    double delayInSeconds = 0.005;
    if (endValue < startValue)
        fadeInterval = -fadeInterval;

    CGFloat brightness = startValue;
    while (fabs(brightness-endValue)>0) {

        brightness += fadeInterval;

        if (fabs(brightness-endValue) < fabs(fadeInterval))
            brightness = endValue;

        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UIScreen mainScreen] setBrightness:brightness];
        });
    }
    UIView *finalDarkScreen = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
    finalDarkScreen.backgroundColor = [UIColor blackColor];
    finalDarkScreen.alpha = 0.3;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:finalDarkScreen];

    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         finalDarkScreen.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             //DIE
                        AudioServicesPlaySystemSound(1521);
                        sleep(1);
                             pid_t pid;
                             const char* args[] = {"killall", "-9", "backboardd", NULL};
                             posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                         }
                     }];
}
%new
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
%end
%end
//End Quick Setup

// Enable Home Gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	_homeButtonType11 = %orig;
	if (originalButton11) {
		originalButton11 = NO;
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
	if ((_dismissalSlidingMode11 != 1) && (arg1 == 0)) {
		return;
	} else {
		%orig;
	}
}
- (long long)dismissalSlidingMode {
	_dismissalSlidingMode11 = %orig;
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
	originalButton11 = YES;
	%orig;
}
%end

// Press Home Button for Siri
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
	if([prefs boolForKey:@"siriHome"]){
		return %orig(_homeButtonType11, arg2);
	}else{
		return %orig;
	}
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
	if([prefs boolForKey:@"siriHome"]){
		return %orig(_homeButtonType11);
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
	applicationDidFinishLaunching11 = 2;
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
	if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching11 == 2 && [prefs boolForKey:@"remapScreen"]) {
		%orig(lockHome);
		applicationDidFinishLaunching11--;
		return;
	}
	%orig;
}
%end
%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
	if (applicationDidFinishLaunching11 == 1 && [prefs boolForKey:@"remapScreen"]) {
		applicationDidFinishLaunching11--;
		return;
	}
	%orig;
}
%end
%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
	if ([prefs boolForKey:@"remapScreen"]) {
		return %orig(arg1, _homeButtonType11, arg3, arg4);
	}
	return %orig;
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
	if ([prefs boolForKey:@"remapScreen"]) {
		return %orig(arg1, _homeButtonType11);
	}
	return %orig;
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

//Enable Torch/Camera buttons on unsupported devices
%hook SBDashBoardQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return YES;
}
%end

%ctor {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if(SYSTEM_VERSION_LESS_THAN(@"12.0")){
    if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
        %init(easySetup);
        }else{
            %init(_ungrouped);
        }
    }
}
