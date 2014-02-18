export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotiSearchArtists
SpotiSearchArtists_FILES = Artists.m
SpotiSearchArtists_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotiSearchArtists_BUNDLE_EXTENSION = searchBundle
SpotiSearchArtists_LDFLAGS = -lspotlight
SpotiSearchArtists_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotiSearchArtists.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Artists.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotiSearchArtists.plist
