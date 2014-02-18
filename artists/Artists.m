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

@interface TLSpotiArtistsDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLSpotiArtistsDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.spotisearch.plist"];
	int limit = GET_INT(@"ArtistLimit", 5);

	searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

	NSString *format = [NSString stringWithFormat:@"http://ws.spotify.com/search/1/artist.json?q=%@", searchString];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
	
	TLRequireInternet(YES);
	$usingInternet = YES;

	NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		if (data != nil) {
			NSMutableArray *searchResults = [NSMutableArray array];
			
			NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSArray *artists = root[@"artists"];

			int count = 0;
			for (NSDictionary *artist in artists) {
				if (count >= limit)
					break;

				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:artist[@"name"]];

				NSString *url = artist[@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
				count++;
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.spotify.client.artists", @"SpotiSearchArtists"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
	
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.spotify.client.artists", @"SpotiSearchArtists")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.spotify.client.artists";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
