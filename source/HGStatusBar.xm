#import "HomeGesture.h"

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

%hook _UIStatusBarData
- (void)setBackNavigationEntry:(id)arg1 {
  if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
    return;
  }else{
    %orig;
  }
}
%end

// iPhone X Status bar
%hook UIStatusBar_Base
+ (BOOL)forceModern {
	if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
		return [prefs boolForKey:@"statusBarX"];
	}else{
		return %orig;
	}
}
+ (Class)_statusBarImplementationClass {
	if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
		return NSClassFromString(@"UIStatusBar_Modern");
	}else{
		return %orig;
	}
  //return NSClassFromString(@"UIStatusBar_Modern");
}


+ (Class)_implementationClass {
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
      return NSClassFromString(@"UIStatusBar_Modern");
    }else if([prefs boolForKey:@"statusBarPad"]){
      return NSClassFromString(@"UIStatusBar_Modern");
    }else{
      return %orig;
    }
  }else{
    return %orig;
  }
}
+ (void)_setImplementationClass:(Class)arg1 {
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
    }else if([prefs boolForKey:@"statusBarPad"]){
      %orig(NSClassFromString(@"UIStatusBar_Modern"));
    }else{
      %orig;
    }
  }else{
    %orig;
  }
}
%end



%hook _UIStatusBar
//TODO ONLY FOR SPLIT 58
+ (double)heightForOrientation:(long long)arg1 {
  if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED ){
    if (arg1 == 1 || arg1 == 2) {
        return %orig - 10;
    } else {
        return %orig;
    }
  }else{
    return %orig;
  }
    
}
%end 

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
  /*NSString *currentApp;
  if (![CURRENT_BUNDLE isEqualToString:@"com.apple.springboard"]){
	  SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
	  SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
	  currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
  }else{
    currentApp = CURRENT_BUNDLE;
  }*/
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
      return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    }else if([prefs boolForKey:@"statusBarPad"]){
      return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
    }else if (@available(iOS 12.1, *)){
      return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    }else{
      return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");//%orig;
    } 
    //
  }else{
    return %orig;
  }
}
%end
// Thanks duraid

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"] && !IS_BLOCKED){
      %orig(NSClassFromString(@"UIStatusBar_Modern"));
    }else if([prefs boolForKey:@"statusBarPad"]){
      %orig(NSClassFromString(@"UIStatusBar_Modern"));
    }else{
      %orig;
    }
  }else{
    %orig;
  }  
}
%end

%ctor {
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
      %init();
    }
  }
}
