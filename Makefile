ARCHS = arm64
TARGET = iphone:clang:11.2:10.0

DEBUG = 0
FINALPACKAGE = 0
GO_EASY_ON_ME = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HomeGesture
$(TWEAK_NAME)_FILES = $(wildcard source/*.m source/*.xm)
$(TWEAK_NAME)_FRAMEWORKS =
$(TWEAK_NAME)_LIBRARIES = sparkapplist MobileGestalt
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS =
$(TWEAK_NAME)_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source
$(TWEAK_NAME)_LDFLAGS += -lCSColorPicker -lCSPreferencesProvider

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
