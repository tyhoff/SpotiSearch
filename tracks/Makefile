export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotifySearchTracks
SpotifySearchTracks_FILES = Tracks.m
SpotifySearchTracks_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotifySearchTracks_BUNDLE_EXTENSION = searchBundle
SpotifySearchTracks_LDFLAGS = -lspotlight
SpotifySearchTracks_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotifySearchTracks.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Tracks.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotifySearchTracks.plist
