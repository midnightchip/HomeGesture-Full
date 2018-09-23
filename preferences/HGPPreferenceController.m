#include "HGPPreferenceController.h"
#import <SparkAppListTableViewController.h>
#import <spawn.h>
#import <AudioToolbox/AudioToolbox.h>

@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end
@interface UIApplication (close)
   - (void)close;
@end
@implementation UIApplication (close)
- (void)close{
    // Check if the current device supports background execution.
BOOL multitaskingSupported = NO;
    // iOS < 4.0 compatibility check.
if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
        multitaskingSupported = [UIDevice currentDevice].multitaskingSupported;
    // Good practice, we're using a private method.
if ([self respondsToSelector:@selector(suspend)])
    {
      if (multitaskingSupported)
        {
            [self beginBackgroundTaskWithExpirationHandler:^{}];
            // Change the delay to your liking. I think 0.4 seconds feels just right (the "close" animation lasts 0.3 seconds).
            [self performSelector:@selector(exit) withObject:nil afterDelay:0.4];
        }
        [self suspend];
    }
    else
        [self exit];
   }

   - (void)exit
   {
    // Again, good practice.
    if ([self respondsToSelector:@selector(terminateWithSuccess)])
        [self terminateWithSuccess];
    else
        exit(EXIT_SUCCESS);
}

@end

@implementation CSPListController (BetterSettings)
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
@end

@implementation HGPPreferenceController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkPrefVer];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applySettings)];
        self.navigationItem.rightBarButtonItem = applyButton;


}
- (void)checkPrefVer{
  NSString *string = [CSPUProcessManager stringFromProcessAtPath:@"/bin/bash" handle:nil arguments:@[@"-c", @"dpkg -s com.creaturecoding.libcspreferences | grep '^Version: 0.9.9.9'"]];
  //[CSPUProcessManager stringFromProcessAtPath:@"/bin/bash" handle:nil arguments:@[@"-c", @"cat /tmp/hgpackages.txt"]];
  if([string rangeOfString:@"0.9.9.9"].location != NSNotFound) {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Required Update"
                  message:@"Please wait a moment while we update libCSPreferences"
                  preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self downloadDeb];

  }else{
    NSLog(@"ITS NOT ");
  }
}
- (void)downloadDeb{
  NSString *stringURL = @"https://github.com/CreatureSurvive/creaturesurvive.github.io/raw/master/debs/com.creaturecoding.libcspreferences_1.0.1_iphoneos-arm.deb";
  NSURL  *url = [NSURL URLWithString:stringURL];
  NSData *urlData = [NSData dataWithContentsOfURL:url];
  if ( urlData )
  {
    NSString  *filePath = [NSString stringWithFormat:@"/tmp/cspref.deb"];
    [urlData writeToFile:filePath atomically:YES];
  }
  NSString *text = [CSPUProcessManager stringFromProcessAtPath:@"/usr/bin/almighty" handle:nil arguments:@[@"-i", @"/tmp/cspref.deb"]];
  NSLog(@"HI THERE %@", text);
  [[UIApplication sharedApplication] close];
  [[UIApplication sharedApplication] terminateWithSuccess];
}
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


- (void)applySettings {
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
@end
