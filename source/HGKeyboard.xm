#import "HomeGesture.h"
//Keyboard

%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
  UIEdgeInsets orig = %orig;
  orig.bottom = 44;
  return orig; 
}
%end

%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
  UIEdgeInsets orig = %orig;
  orig.bottom = 44;
  return orig;
}

%end



%hook UIKeyboardDockView

- (CGRect)bounds {
  CGRect bounds = %orig;
  if (bounds.origin.y == 0) {
    bounds.origin.y -=13;
  }
  return bounds; 
}

- (void)layoutSubviews {
    %orig;
}

%end


%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
  return UIEdgeInsetsMake(0,0,44,0);
}
%end
//End Keyboard

%ctor {
  //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"] && [prefs boolForKey:@"ipxKeyboard"]){
      %init();
      }
  }
}