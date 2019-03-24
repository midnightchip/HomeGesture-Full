#import "HomeGesture.h"

%hook CCUIHeaderPocketView
-(void)layoutSubviews{
  %orig;
  CGRect _frame = self.frame;
  if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
    _frame.origin.y = -10;
  }else{
    _frame.origin.y = -24;
  }
  self.frame = _frame;
  if ([self valueForKey:@"_headerBackgroundView"]) {
    UIView *backgroundView = (UIView *)[self valueForKey:@"_headerBackgroundView"];
    backgroundView.hidden = YES;
  }
  if ([self valueForKey:@"_headerLineView"]) {
    UIView *lineView = (UIView *)[self valueForKey:@"_headerLineView"];
    lineView.hidden = YES;
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

%group FUGap
//Start FUGap
%hook CCUIHeaderPocketView

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
%end 

%ctor{
    //NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
      NSFileManager *fileManager = [NSFileManager defaultManager];
      if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]) {
        %init();
        if([prefs boolForKey:@"enableFUGAP"]){
          %init(FUGap);
          }
        }
    }
}