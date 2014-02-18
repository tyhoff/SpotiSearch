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
	// NSString * countryCode = GET_STR(@"Country", @"US");

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
			NSArray *items = [root objectForKey:@"tracks"];

			int count = 0;
			for (NSDictionary *item in items) {
				if (count >= limit)
					break;

				/* create the artist string */
				NSMutableString * artistString = [NSMutableString string];
				NSArray * artists = [item objectForKey:@"artists"];
				for (int i=0; i<[artists count]; i++) {
					NSDictionary *artist = [artists objectAtIndex:i];

					if (i == [artists count] - 1)
						[artistString appendString:[NSString stringWithFormat:@"%@", [artist objectForKey:@"name"]]];
					else
						[artistString appendString:[NSString stringWithFormat:@"%@, ", [artist objectForKey:@"name"]]];
				}


				/* create the album string */
				NSDictionary *album = [item objectForKey:@"album"];
				NSString *albumString = [NSString stringWithFormat:@"%@ - %@", [album objectForKey:@"name"], [album objectForKey:@"released"]];

				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:[item objectForKey:@"name"]];
				[result setSubtitle:artistString];
				[result setSummary:albumString];

				NSString *url = [item objectForKey:@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
				count++;
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
