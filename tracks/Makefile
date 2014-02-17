export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotifySearch
SpotifySearch_FILES = SpotifySearch.m
SpotifySearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotifySearch_BUNDLE_EXTENSION = searchBundle
SpotifySearch_LDFLAGS = -lspotlight
SpotifySearch_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotifySearch.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp SpotifySearch.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotifySearch.plist
