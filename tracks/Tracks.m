/*%%%%%
%% Store.m
%% Spotlight+ Store Search Bundle
%% by theiostream
%%
%% iTunes Search API: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#define GET_INT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).intValue : default)
#define GET_STR(key, default) (prefs[key] ? prefs[key] : default)

@interface TLSpotifyTracksDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLSpotifyTracksDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.spotifysearch.plist"];
	int limit = GET_INT(@"TrackLimit", 5);
	NSString * countryCode = GET_STR(@"Country", @"US");

	searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

	NSString *format = [NSString stringWithFormat:@"http://ws.spotify.com/search/1/track.json?q=%@", searchString];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
	
	TLRequireInternet(YES);
	$usingInternet = YES;

	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		if (data != nil) {
			NSMutableArray *searchResults = [NSMutableArray array];
			
			NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSArray *tracks = [root objectForKey:@"tracks"];

			for (int i=0; i<[tracks count]; i++) {
				NSDictionary *track = [tracks objectAtIndex:i];
				if (i >= limit)
					break;

				/* create the album string */
				NSDictionary *album = [track objectForKey:@"album"];

				NSString * territories = [[album objectForKey:@"availability"] objectForKey:@"territories"];
				if ([territories rangeOfString:countryCode].location == NSNotFound) {
					continue;
				}

				NSString *albumString = [NSString stringWithFormat:@"%@ - %@", [album objectForKey:@"name"], [album objectForKey:@"released"]];
				

				/* create the artist string */
				NSMutableString * artistString = [NSMutableString string];
				NSArray * artists = [track objectForKey:@"artists"];
				for (int j=0; j<[artists count]; j++) {
					NSDictionary *artist = [artists objectAtIndex:j];

					if (j == [artists count] - 1)
						[artistString appendString:[NSString stringWithFormat:@"%@", [artist objectForKey:@"name"]]];
					else
						[artistString appendString:[NSString stringWithFormat:@"%@, ", [artist objectForKey:@"name"]]];
				}


				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:[track objectForKey:@"name"]];
				[result setSubtitle:artistString];
				[result setSummary:albumString];

				NSString *url = [track objectForKey:@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.spotify.client.tracks", @"SpotifySearchTracks"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
	
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.spotify.client.tracks", @"SpotifySearchTracks")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.spotify.client.tracks";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
