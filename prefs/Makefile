

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HomeGesture
HomeGesture_FILES = HGPRootListController.m
HomeGesture_INSTALL_PATH = /Library/PreferenceBundles
HomeGesture_FRAMEWORKS = UIKit
HomeGesture_PRIVATE_FRAMEWORKS = Preferences
HomeGesture_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
HomeGesture_LIBRARIES = sparkapplist colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HomeGesture.plist$(ECHO_END)
