export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotiSearchAlbums
SpotiSearchAlbums_FILES = Albums.m
SpotiSearchAlbums_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotiSearchAlbums_BUNDLE_EXTENSION = searchBundle
SpotiSearchAlbums_LDFLAGS = -lspotlight
SpotiSearchAlbums_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotiSearchAlbums.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Albums.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotiSearchAlbums.plist
