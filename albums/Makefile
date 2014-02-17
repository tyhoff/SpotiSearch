export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotifySearchAlbums
SpotifySearchAlbums_FILES = Albums.m
SpotifySearchAlbums_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotifySearchAlbums_BUNDLE_EXTENSION = searchBundle
SpotifySearchAlbums_LDFLAGS = -lspotlight
SpotifySearchAlbums_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotifySearchAlbums.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Albums.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotifySearchAlbums.plist
