ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:7

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = SpotiSearchPrefs
SpotiSearchPrefs_CFLAGS = -fobjc-arc
SpotiSearchPrefs_FILES = SpotiSearchPrefsListController.m
SpotiSearchPrefs_INSTALL_PATH = /Library/PreferenceBundles
SpotiSearchPrefs_FRAMEWORKS = Foundation UIKit
SpotiSearchPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SpotiSearchPrefs.plist$(ECHO_END)
