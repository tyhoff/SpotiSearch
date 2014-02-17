/*%%%%%
%% Store.m
%% Spotlight+ Store Search Bundle
%% by theiostream
%%
%% iTunes Search API: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>


@interface TLSpotifyAlbumsDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLSpotifyAlbumsDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	int limit = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.spotifysearch.albums.plist"] objectForKey:@"Limit"] intValue] ?: 5;

	searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

	NSString *format = [NSString stringWithFormat:@"http://ws.spotify.com/search/1/album.json?q=%@", searchString];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
	
	TLRequireInternet(YES);
	$usingInternet = YES;

	NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		if (data != nil) {
			NSMutableArray *searchResults = [NSMutableArray array];
			
			NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSArray *items = [root objectForKey:@"albums"];

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

				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:[item objectForKey:@"name"]];
				[result setSubtitle:artistString];

				NSString *url = [item objectForKey:@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
				count++;
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.spotify.client.albums", @"SpotifySearchAlbums"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
	
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.spotify.client.albums", @"SpotifySearchAlbums")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.spotify.client.albums";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
