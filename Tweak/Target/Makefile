TWEAK_NAME = VeTarget
VeTarget_FILES = VeTarget.m $(wildcard Controllers/*.swift Controllers/*/*.swift ../../Manager/*.m ../../Utils/*.m)
VeTarget_CFLAGS = -fobjc-arc -I.
VeTarget_FRAMEWORKS = UIKit
VeTarget_PRIVATE_FRAMEWORKS = Preferences
VeTarget_SWIFT_BRIDGING_HEADER = VeTarget-Bridging-Header.h
VeTarget_SWIFT_VERSION = 6

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
