export THEOS_PACKAGE_SCHEME = rootless

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerformancePlus

PerformancePlus_FILES = Tweak.x
PerformancePlus_CFLAGS = -fobjc-arc
PerformancePlus_FRAMEWORKS = UIKit Foundation
PerformancePlus_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package:: stage
	chmod -R u=rwX,go=rX "$(THEOS_STAGING_DIR)"
	chmod 755 "$(THEOS_STAGING_DIR)/DEBIAN"
	chmod 644 "$(THEOS_STAGING_DIR)/DEBIAN/control"

internal-package:: before-package
