ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerformancePlusPrefs

PerformancePlusPrefs_FILES = PPListController.m ../PPManager.m
PerformancePlusPrefs_CFLAGS = -fobjc-arc
PerformancePlusPrefs_FRAMEWORKS = UIKit Foundation
PerformancePlusPrefs_PRIVATE_FRAMEWORKS = Preferences
PerformancePlusPrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk
