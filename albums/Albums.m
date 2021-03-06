#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#define GET_INT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).intValue : default)
#define GET_STR(key, default) (prefs[key] ? prefs[key] : default)

@interface TLSpotiAlbumsDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLSpotiAlbumsDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.spotisearch.plist"];
	int limit = GET_INT(@"AlbumLimit", 5);
	NSString * countryCode = GET_STR(@"Country", @"US");

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
			NSArray *albums = root[@"albums"];

			int count = 0;
			for (NSDictionary *album in albums) {
				if (count >= limit)
					break;

				/* create the artist string */
				NSMutableString * artistString = [NSMutableString string];
				NSArray * artists = album[@"artists"];
				for (int i=0; i<[artists count]; i++) {
					NSDictionary *artist = artists[i];

					if (i == [artists count] - 1)
						[artistString appendString:[NSString stringWithFormat:@"%@", artist[@"name"]]];
					else
						[artistString appendString:[NSString stringWithFormat:@"%@, ", artist[@"name"]]];
				}

				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				[result setTitle:album[@"name"]];
				[result setSubtitle:artistString];

				NSString * territories = album[@"availabiity"][@"territories"];
				if ([territories rangeOfString:countryCode].location == NSNotFound) {
					[result setSummary:@"Full album not available due to territory restrictions"];
				}

				NSString *url = album[@"href"];
				[result setUrl:url];
				[searchResults addObject:result];
				count++;
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.spotify.client.albums", @"SpotiSearchAlbums"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
	
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.spotify.client.albums", @"SpotiSearchAlbums")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.spotify.client.albums";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
