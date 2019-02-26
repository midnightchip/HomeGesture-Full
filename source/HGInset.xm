#import "HomeGesture.h"
//UIBar
%hook UITabBar

- (void)layoutSubviews {
    %orig;
    if([prefs boolForKey:@"inset"]){
      CGRect _frame = self.frame;
      if (_frame.size.height == 49) {
        _frame.size.height = 70;
        _frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 70;
        }
        self.frame = _frame;
    }
}

%end



%hook UIApplicationSceneSettings

- (UIEdgeInsets)_inferredLayoutMargins {
  if([prefs boolForKey:@"inset"]){
    return UIEdgeInsetsMake(32,0,0,0);
  }else{
    return %orig;
  }
    
}
- (UIEdgeInsets)safeAreaInsetsLandscapeLeft {
  if([prefs boolForKey:@"inset"]){
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
  }else{
    return %orig;
  }
}
- (UIEdgeInsets)safeAreaInsetsLandscapeRight {
  if([prefs boolForKey:@"inset"]){
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
  }else{
    return %orig;
  }
}
- (UIEdgeInsets)safeAreaInsetsPortrait {
  if([prefs boolForKey:@"inset"]){
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
  }else{
    return %orig;
  }
}
- (UIEdgeInsets)safeAreaInsetsPortraitUpsideDown {
  if([prefs boolForKey:@"inset"]){
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
  }else{
    return %orig;
  }
}

%end

%ctor {
  //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
      %init();
      }
  }
}