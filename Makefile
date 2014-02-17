SUBPROJECTS = tracks

export ARCHS = armv7 arm64

include theos/makefiles/common.mk

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Internal/$(ECHO_END)
	$(ECHO_NOTHING)touch $(THEOS_STAGING_DIR)/Library/SearchLoader/Internal/extendedwatcher.dat$(ECHO_END)

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"