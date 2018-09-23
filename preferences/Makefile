ARCHS = arm64
TARGET = iphone:clang:11.2:10.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HomeGesture
$(BUNDLE_NAME)_FILES = HGPPreferenceController.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit AudioToolbox
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_CFLAGS += -fobjc-arc
$(BUNDLE_NAME)_LDFLAGS += -lCSPreferences -lCSColorPicker -lCSPUtilities
$(BUNDLE_NAME)_LIBRARIES = sparkapplist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HomeGesture.plist$(ECHO_END)
