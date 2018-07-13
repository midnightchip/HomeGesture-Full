GO_EASY_ON_ME = 1

THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HomeGesture
HomeGesture_FILES = Tweak.xm
HomeGesture_LIBRARIES = sparkapplist colorpicker
HomeGesture_FRAMEWORKS = IOKit
HomeGesture_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
