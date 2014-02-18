//
//  SpotifySearchPrefsListController.m
//  SpotifySearchPrefs
//
//  Created by Tyler H on 18.02.2014.
//  Copyright (c) 2014 Tyler H. All rights reserved.
//

#import "SpotifySearchPrefsListController.h"

@implementation SpotifySearchPrefsListController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"SpotifySearchPrefs" target:self];
	}
    
	return _specifiers;
}

@end
