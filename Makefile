ARCHS = arm64
TARGET = iphone:clang:11.2:10.0

DEBUG = 0
FINALPACKAGE = 0
GO_EASY_ON_ME = 0

<package>_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HomeGesture
HomeGesture_FILES = $(wildcard source/*.m source/*.xm)
HomeGesture_FRAMEWORKS = 
HomeGesture_LIBRARIES = sparkapplist MobileGestalt CSColorPicker CSPreferencesProvider 
HomeGesture_PRIVATE_FRAMEWORKS = 
HomeGesture_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source
#HomeGesture_LDFLAGS += -lCSColorPicker -lCSPreferencesProvider

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
