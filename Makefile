THEOS_PACKAGE_SCHEME ?= roothide
export THEOS_PACKAGE_SCHEME
export ARCHS = arm64 arm64e
export TARGET = iphone:clang::16.0

INSTALL_TARGET_PROCESSES = SpringBoard Preferences
SUBPROJECTS = Tweak/Core Tweak/Target Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
