//
//  SpotiSearchPrefsListController.m
//  SpotiSearchPrefs
//
//  Created by Tyler H on 18.02.2014.
//  Copyright (c) 2014 Tyler H. All rights reserved.
//

#import "SpotiSearchPrefsListController.h"

@implementation SpotiSearchPrefsListController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"SpotiSearchPrefs" target:self];
	}
    
	return _specifiers;
}

@end
