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

@interface TLSpotiTracksDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLSpotiTracksDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.spotisearch.plist"];
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
			NSArray *tracks = root[@"tracks"];

			int count = 0;
			for (NSDictionary *track in tracks) {
				if (count >= limit)
					break;

				/* create the album string */
				NSDictionary *album = track[@"album"];

				NSString * territories = album[@"availability"][@"territories"];
				if ([territories rangeOfString:countryCode].location == NSNotFound) {
					continue;
				}

				NSString *albumString = [NSString stringWithFormat:@"%@ - %@", album[@"name"], album[@"released"]];
				

				/* create the artist string */
				NSMutableString * artistString = [NSMutableString string];
				NSArray * artists = track[@"artists"];
				for (int j=0; j<[artists count]; j++) {
					NSDictionary *artist = [artists objectAtIndex:j];

					if (j == [artists count] - 1)
						[artistString appendString:[NSString stringWithFormat:@"%@", artist[@"name"]]];
					else
						[artistString appendString:[NSString stringWithFormat:@"%@, ", artist[@"name"]]];
				}


				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:track[@"name"]];
				[result setSubtitle:artistString];
				[result setSummary:albumString];

				NSString *url = track[@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
				count++;
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.spotify.client.tracks", @"SpotiSearchTracks"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
	
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.spotify.client.tracks", @"SpotiSearchTracks")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.spotify.client.tracks";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
