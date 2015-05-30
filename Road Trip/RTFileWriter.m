//
//  RTFileWriter.m
//  Road Trip
//
//  Created by James on 9/8/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTFileWriter.h"
#import "NSImage+Additions.h"
#import "RTConversionManager.h"
#import "RTGRidImage.h"

@interface RTFileWriter ()
@end

@implementation RTFileWriter

- (id)initWithTrack:(ITLibMediaItem *)track
{

	if ((self = [super init]) != nil) {
		self.track = track;

		return self;
	} else {

		return nil;
	}
}

- (void)main
{
  if ( self.isCancelled ) return;
	@autoreleasepool {


		BOOL convertFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"convertFiles"];
		BOOL embedAlbumArt = [[NSUserDefaults standardUserDefaults] boolForKey:@"embedAlbumArt"];
		BOOL resizeAlbumArt = [[NSUserDefaults standardUserDefaults] boolForKey:@"resizeAlbumArt"];

		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;

		NSString *artistName;

		if (self.track.album.isCompilation) {
			artistName = @"Compilations";
		} else {
			artistName = self.track.artist.name;
		}

		NSString *aaFolder = [NSString stringWithFormat:@"%@/%@", artistName, self.track.album.title];
		NSURL *destinationFolder = [[[NSApp delegate] musicFolder] URLByAppendingPathComponent:aaFolder];

		[fm createDirectoryAtURL:destinationFolder withIntermediateDirectories:YES attributes:nil error:&error];

		if (error) {
//			DDLogError(@"%@", error.localizedFailureReason);
			// There might be a race condition creating this folder but it's probably harmless.
			//			[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:error waitUntilDone:NO];
			//			return;
			error = nil;
		}

		NSURL *sourceURL = self.track.location;
		NSString *sourceFilename = sourceURL.lastPathComponent;

		if (!sourceFilename || ![sourceURL startAccessingSecurityScopedResource]) {
			NSString *errorDetail = [NSString stringWithFormat:@"Track location for \"%@\" couldn't be read from iTunes", self.track.title ];
			NSError *locationError __attribute__((unused)) = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
																													code:1
																											userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];

			[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:locationError waitUntilDone:NO];
			return;
		}

		RTGRidImage *thumbnail = [[RTGRidImage alloc] initWithTitle:[NSString stringWithFormat:@"%@/%@", aaFolder, self.track.title]];

		NSString *finalFilename;

		if (convertFiles) {
			finalFilename = [NSString stringWithFormat:@"%@.mp3", [sourceFilename stringByDeletingPathExtension]];

			if ([finalFilename isEqualToString:sourceFilename]) {
				// When the source is already an MP3 don't convert it
				convertFiles = NO;
			}

		} else {
			finalFilename = sourceFilename;
		}

		NSURL *destinationURL = [destinationFolder URLByAppendingPathComponent:finalFilename];

		if (!sourceURL) {
			NSString *errorDetail = [NSString stringWithFormat:@"Track location for \"%@\" couldn't be read from iTunes", self.track.title ];
			NSError *locationError __attribute__((unused)) = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
																													code:1
																											userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];
			[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:locationError waitUntilDone:NO];

			return;
		}

		NSString *execPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"ffmpeg"];
		NSURL *ffmpegURL = [[NSURL alloc] initFileURLWithPath:execPath];
		NSString *trackTempFilename = [NSTemporaryDirectory() stringByAppendingString:finalFilename];

		if (![fm fileExistsAtPath:destinationURL.path]) {
			// Destination file doesn't exist

			if (convertFiles) {
				// Convert
				DDLogVerbose(@"Converting track %@ to %@", sourceURL.path, trackTempFilename);

				NSTask *convertTask = [[NSTask alloc] init];
				convertTask.launchPath = ffmpegURL.path;
				convertTask.arguments = @[ @"-i", sourceURL.path,
																	 @"-loglevel", @"quiet",
																	 @"-acodec", @"libmp3lame", @"-ab", @"128k", @"-y", @"-map", @"a",
																	 trackTempFilename ];

				[convertTask launch];
				[convertTask waitUntilExit];

				int status = [convertTask terminationStatus];

				if (status != 0) {
					NSString *errorDetail = [NSString stringWithFormat:@"An error occured converting \"%@\".", self.track.title ];
					NSError *locationError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];
					[sourceURL stopAccessingSecurityScopedResource];
					[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:locationError waitUntilDone:NO];
					return;
				}
			} else {
				// don't convert, copy
				DDLogInfo(@"Copying track %@ to %@", sourceURL.path, destinationURL.path);

				NSTask *copyTask = [[NSTask alloc] init];
				copyTask.launchPath = ffmpegURL.path;
				copyTask.arguments = @[ @"-y", @"-i",sourceURL.path,
																@"-loglevel", @"quiet",
																@"-c:a", @"copy", @"-map", @"a",  destinationURL.path ];
				DDLogVerbose(@"Running copy: %@", copyTask.arguments);
				[copyTask launch];
				[copyTask waitUntilExit];
				int status = [copyTask terminationStatus];

				if (status != 0) {
					NSString *errorDetail = [NSString stringWithFormat:@"An error occured copying \"%@\".", self.track.title ];
					NSError *locationError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];
					[sourceURL stopAccessingSecurityScopedResource];
					[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:locationError waitUntilDone:NO];
					return;
				}
			}
		} else {
			DDLogInfo(@"%@ exists, not copying", destinationURL.lastPathComponent);
//			embedAlbumArt = NO;
//			convertFiles = NO;
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackCompleted" object:thumbnail userInfo:@{@"skipped": [NSNumber numberWithBool:YES]}];
			});
			return;
		}

		// Extract album art

		NSImage *art;

		if (self.track.artworkAvailable) {
			art = self.track.artwork.image;
			thumbnail.image = [art imageByScalingProportionallyToSize:NSSizeFromString(@"{100,100}")];
		}

		if (self.track.artworkAvailable && embedAlbumArt) {

			NSString *artFilename = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.jpg", [self stringWithUUID]];;

			// Resize album art

			if (resizeAlbumArt) {
				NSImage *scaledArt = [art imageByScalingProportionallyToSize:NSSizeFromString(@"{400,400}")];
				[scaledArt saveAsJpegWithName:artFilename];
						DDLogVerbose(@"Scaled art saved to %@", artFilename);
			} else {
				[art saveAsJpegWithName:artFilename];
						DDLogVerbose(@"Art saved to %@", artFilename);
			}

			// Add album art back in
			NSTask *embedTask = [[NSTask alloc] init];
			embedTask.launchPath = ffmpegURL.path;
			embedTask.arguments = @[ @"-i", trackTempFilename, @"-i", artFilename, @"-y",
															 @"-loglevel", @"quiet",
															 @"-map", @"0", @"-map", @"1", @"-c", @"copy", @"-id3v2_version", @"3",
															 @"-metadata:s:v", @"title=\"Album cover\"", @"-metadata:s:v", @"comment=\"Cover (Front)\"",
															 destinationURL.path ];
				DDLogVerbose(@"Embedding artwork: %@", embedTask.arguments);

			[embedTask launch];
			[embedTask waitUntilExit];

			// Remove temp image
			[fm removeItemAtPath:artFilename error:&error];

			if (error) {
				NSLog(@"Unable to remove %@", artFilename);
				[sourceURL stopAccessingSecurityScopedResource];
				[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:error waitUntilDone:NO];
				return;
			}
			[fm removeItemAtPath:trackTempFilename error:&error];

			if (error) {
				NSLog(@"Unable to remove %@", artFilename);
				[sourceURL stopAccessingSecurityScopedResource];
				[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:error waitUntilDone:NO];
				return;
			}
			
		} else if (convertFiles) {
			// Not using artwork so mv the temp file into place
			[fm moveItemAtPath:trackTempFilename toPath:destinationURL.path error:&error];

			if (error) {
				NSLog(@"Unable to move %@", trackTempFilename);
				[sourceURL stopAccessingSecurityScopedResource];
				[error.userInfo setValue:sourceURL.path forKey:@"sourcePath"];
				[self.delegate performSelectorOnMainThread:@selector(errorOccured:) withObject:error waitUntilDone:NO];
				return;
			}
		}
		[sourceURL stopAccessingSecurityScopedResource];

		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackCompleted" object:thumbnail userInfo:@{@"skipped": [NSNumber numberWithBool:NO]}];
		});

	
	} // autorelease pool
}

- (NSString *)stringWithUUID
{

	NSUUID *uuid = [NSUUID UUID];

	return [uuid UUIDString];
}

@end
