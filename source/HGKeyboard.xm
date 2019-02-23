#import "HomeGesture.h"
//Keyboard

%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
  if([prefs boolForKey:@"ipxKeyboard"]){
    UIEdgeInsets orig = %orig;
    orig.bottom = 44;
    return orig;
  }else{
    return %orig;
  }
    
}
%end

%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
  if([prefs boolForKey:@"ipxKeyboard"]){
    UIEdgeInsets orig = %orig;
    orig.bottom = 44;
    return orig;
  }else{
    return %orig;
  }
}

%end



%hook UIKeyboardDockView

- (CGRect)bounds {
  if([prefs boolForKey:@"ipxKeyboard"]){
    CGRect bounds = %orig;
    if (bounds.origin.y == 0) {
      bounds.origin.y -=12.5;
    }
    return bounds;
  }else{
    return %orig;
  }
    
}

- (void)layoutSubviews {
    %orig;
}

%end


%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
  if([prefs boolForKey:@"ipxKeyboard"]){
    return UIEdgeInsetsMake(0,0,44,0);
  }else{
    return %orig;
  }  
}
%end
//End Keyboard

%ctor {
  //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
    %init();
  }
}