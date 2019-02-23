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
  //return NSClassFromString(@"UIStatusBar_Modern");
}

+ (Class)_implementationClass {
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"]){
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
    if([prefs boolForKey:@"statusBarX"]){
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
  if([prefs boolForKey:@"statusBarX"]){
    if (arg1 == 1 || arg1 == 2) {
        return %orig - 9;
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
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")) {
    if([prefs boolForKey:@"statusBarX"]){
      return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    }else if([prefs boolForKey:@"statusBarPad"]){
      return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
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
    if([prefs boolForKey:@"statusBarX"]){
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
  //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]){
    %init();
  }
}
