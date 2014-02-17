export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotifySearchArtists
SpotifySearchArtists_FILES = Artists.m
SpotifySearchArtists_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotifySearchArtists_BUNDLE_EXTENSION = searchBundle
SpotifySearchArtists_LDFLAGS = -lspotlight
SpotifySearchArtists_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotifySearchArtists.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Artists.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotifySearchArtists.plist
