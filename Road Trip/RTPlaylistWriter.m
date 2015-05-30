//
//  RTPlaylistWriter.m
//  Road Trip
//
//  Created by James Moore on 8/5/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTPlaylistWriter.h"
#import "RTConversionManager.h"
#import "NSMutableArray+Shuffling.h"

@interface RTPlaylistWriter ()

@end

@implementation RTPlaylistWriter

- (id)initWithPlaylist:(ITLibPlaylist *)playlist
{
	if ((self = [super init]) != nil) {
		[self setPlaylist:playlist];

		return self;
	} else {

		return nil;
	}
}

- (void)main
{
  if ( self.isCancelled ) return;
	BOOL convertFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"convertFiles"];
	BOOL shufflePlaylist = [[NSUserDefaults standardUserDefaults] boolForKey:@"shufflePlaylistOrder"];
	BOOL useM3U = [[NSUserDefaults standardUserDefaults] boolForKey:@"useExtendedM3U"];

	@autoreleasepool {
		DDLogInfo(@"Processing Playlist %@", self.playlist.name);

		NSMutableString *playlistFile = [NSMutableString new];

		if (useM3U) {
			[playlistFile appendString:@"#EXTM3U\n"];
		}

		NSString *filename;
		NSError *error = nil;

		NSArray *filteredItems;

		if (shufflePlaylist) {
			NSMutableArray *m = [self.playlist.getFilteredItems mutableCopy];
			[m shuffle];
			filteredItems = [NSArray arrayWithArray:m];
		} else {
			filteredItems = self.playlist.getFilteredItems;
		}

		// loop over tracks

		for (ITLibMediaItem *track in filteredItems) {

			NSURL *trackLocation = track.location;
			BOOL s = [trackLocation startAccessingSecurityScopedResource];
			NSString *finalFilename;

			if (trackLocation && s) {
				// mediaItemLocation can be now used to read/write
				// the media file
				filename = [trackLocation lastPathComponent];

				if (convertFiles) {
					finalFilename = [NSString stringWithFormat:@"%@.mp3", [filename stringByDeletingPathExtension]];
				} else {
					finalFilename = filename;
				}

				[trackLocation stopAccessingSecurityScopedResource];
			} else {
				NSString *errorDetail = [NSString stringWithFormat:@"Track location for \"%@\" couldn't be read from iTunes", track.title ];
				NSError *locationError __attribute__((unused)) = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
																														code:1
																												userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];
				[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:locationError waitUntilDone:NO];
				continue;
			}

			NSString *artistName;

			if (track.album.isCompilation) {
				artistName = @"Compilations";
			} else {
				artistName = track.artist.name;
			}

			if (useM3U) {
				int time = (int)track.totalTime / 1000;
				[playlistFile appendFormat:@"#EXTINF:%i,%@ - %@\n", time, track.title, track.artist.name];
			}

			[playlistFile appendFormat:@"/%@/%@/%@\n", artistName, track.album.title, finalFilename];

		}

		[playlistFile writeToFile:[NSString stringWithFormat:@"%@", [[[NSApp delegate] playlistURL:self.playlist] path]]
										atomically:YES
											encoding:NSUTF8StringEncoding
												 error:&error];

		if (error) {
			// Failed to write the playlist file
			[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:error waitUntilDone:NO];
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistCompleted" object:nil];
		});
	}
}

@end
