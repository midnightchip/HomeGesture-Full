#include "HGPRootListController.h"
#import <spawn.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SparkAppListTableViewController.h>
#import "libcolorpicker.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation HGPRootListController
//colorpicker
- (void)selectColor {
	NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.midnight.homegesture.plist"];
	if (!prefsDict) prefsDict = [NSMutableDictionary dictionary];
		NSString *fallbackHex = @"#ff0000";  // (You want to load from prefs probably)
	    UIColor *startColor = LCPParseColorString([prefsDict objectForKey:@"customColour"], fallbackHex); // this color will be used at startup
	    PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:YES];
	    [alert displayWithCompletion:
	    ^void (UIColor *pickedColor){
				NSString *hexString = [UIColor hexFromColor:pickedColor];
				[prefsDict setObject:hexString forKey:@"customColour"];
				[prefsDict writeToFile:@"/var/mobile/Library/Preferences/com.midnight.homegesture.plist" atomically:YES];
	    }];
}
//SparkAppList
-(void)selectExcludeApps{
SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps"];
[self.navigationController pushViewController:s animated:YES];
self.navigationItem.hidesBackButton = FALSE;
}
-(void)selectBlackList{
SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.midnight.homegesture.plist" andKey:@"blackList"];
[self.navigationController pushViewController:s animated:YES];
self.navigationItem.hidesBackButton = FALSE;
}
/*-(void)selectStatus{
SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.midnight.homegesture.plist" andKey:@"statusBar"];
[self.navigationController pushViewController:s animated:YES];
self.navigationItem.hidesBackButton = FALSE;
}*/
//Make The Respring Pretty
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


- (void)respring {
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
                             //call the animation here for the screen fade and respring
                             [self graduallyAdjustBrightnessToValue:0.0f];
                         }
                     }];

    //sleep(15);

    //[[UIScreen mainScreen] setBrightness:0.0f]; //so the screen fades back in when the respringing is done
}


+ (NSString *)hb_specifierPlist {
	return @"Root";
}
- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearance = [[HBAppearanceSettings alloc] init];
		appearance.tintColor = UIColorFromRGB(0x39BBB3);
    appearance.tableViewCellTextColor = UIColorFromRGB(0x39BBB3);
		self.hb_appearanceSettings = appearance;
	}

	return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

		UIImage *icon = [UIImage imageNamed:@"/Library/PreferenceBundles/HomeGesture.bundle/icon.png"];
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:icon];

    UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]  initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
		[respringButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: UIColorFromRGB(0x39BBB3),  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:respringButton];

		//self.navigationController.navigationController.navigationBar.tintColor = [UIColor blackColor];
}




- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}
/*
- (void)ContactMePin {
		NSURL *url = [NSURL URLWithString:@"https://twitter.com/TPinpal"];
		[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
- (void)ContactMeMidnight {
		NSURL *url = [NSURL URLWithString:@"https://twitter.com/MidnightChip"];
		[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
- (void)ContactMeVita {
		NSURL *url = [NSURL URLWithString:@"https://www.reddit.com/user/VitaTaf/"];
		[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
*/
@end
