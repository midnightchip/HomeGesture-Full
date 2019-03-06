#import "HomeGesture.h"
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>

OBJC_EXTERN IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator); //Creates referece for our client

#define powerButtonPressedInt 48 //HID int for power button pressed
#define volumeDownPressedInt 234 //HID int for volume down pressed
#define homeButtonPressedInt 64 //HID int for home button pressed

@interface UIApplication (Private)
-(void)takeScreenshotAndEdit:(BOOL)arg1;
@end

NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; //For Disabling Screen off

void remapScreenShotHandler(void *target, void *refcon, IOHIDEventQueueRef queue, IOHIDEventRef event) { //this is how an HIDEventHandler is declared
  static BOOL powerButtonPressed = NO;
  static BOOL volumeDownPressed = NO;
  static BOOL homeButtonPressed = NO;
    
  if(IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) { //checks event type (We want keyboard due to physical buttons)
    int keyDown = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown); //gets bool for current button that is/was pressed (pressed = True, released = false)
    int button = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage); //gets HID int for current button pressed
    switch(button) { //switch for the HID int
      case powerButtonPressedInt:
        powerButtonPressed = keyDown;
        break;
      case volumeDownPressedInt:
        volumeDownPressed = keyDown;
        break;
      case homeButtonPressedInt:
      	homeButtonPressed = keyDown;
      default:
        break;
    }//if [prefs boolForKey:@"remapScreen"] is True, it will use the traditional gesture (home + power), if it is false, it will do the new gesture (volDown + power)
    if(powerButtonPressed && ((volumeDownPressed && ![prefs boolForKey:@"remapScreen"]) || (homeButtonPressed && [prefs boolForKey:@"remapScreen"]))) { //Checks both BOOLs and prefs
      static BOOL origDefault = [defaults boolForKey:@"SBDontLockEver"];
	  	[defaults setBool:YES forKey:@"SBDontLockEver"]; //disables screen off
      [defaults synchronize];
      [[UIApplication sharedApplication] takeScreenshotAndEdit:NO];
      [defaults setBool:origDefault forKey:@"SBDontLockEver"]; //re-enables screen off
      [defaults synchronize];
    }
  }
}
//Hooks to disable default screenshot gesture completely
%hook SBLockHardwareButton
-(void)screenshotRecognizerDidRecognize:(id)arg1 {}
%end

%hook SBHomeHardwareButton
-(void)screenshotRecognizerDidRecognize:(id)arg1 {}
%end

%hook SBCombinationHardwareButton
-(void)screenshotGesture:(id)arg1 {}
%end

static IOHIDEventSystemClientRef ioClient; //declares client
static CFRunLoopRef ioLoopScedule; //declares loop

%ctor {
  ioClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault); //sets up client for the run loop
  ioLoopScedule = CFRunLoopGetMain(); //gets the main loop
    
  IOHIDEventSystemClientScheduleWithRunLoop(ioClient, ioLoopScedule, kCFRunLoopDefaultMode); //adds client to main loop
  IOHIDEventSystemClientRegisterEventCallback(ioClient, remapScreenShotHandler, NULL, NULL); //adds our handler to the client which then calls it repeatedly
  
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
  	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/HomeGesture/setup"]) {
		if([prefs boolForKey:@"remapScreen"]){
			%init();
		}
        }
    }
}

%dtor {
  IOHIDEventSystemClientUnregisterEventCallback(ioClient); //removes all events from out client
  IOHIDEventSystemClientUnscheduleWithRunLoop(ioClient, ioLoopScedule, kCFRunLoopDefaultMode); //unregisters our client from the main loop
}
