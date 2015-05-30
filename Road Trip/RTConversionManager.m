//
//  RTPlaylistConverter.m
//  Road Trip
//
//  Created by James Moore on 8/2/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTConversionManager.h"
#import "RTPlaylistWriter.h"
#import "RTFileWriter.h"
#import "NSSound+AlertAudioAdditions.h"
#import "RTMediaManager.h"

@interface RTConversionManager ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (atomic) BOOL processingError;
@end

@implementation RTConversionManager

@synthesize playlists = _playlists;

- (id)init
{
  self = [super init];

  if (self) {

    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = (int) [NSProcessInfo processInfo].processorCount;
    [self.queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
		self.processingError = NO;
  }

  return self;
}

- (void)startExport
{

	if (self.exporting) {
    DDLogDebug(@"We're already exporting…");
    return;
  }

	self.processingError = NO;
	
  DDLogInfo(@"Export started with %i tracks", self.trackCount);
  self.exporting = YES;

  NSError *error = nil;

  BOOL copy = [[NSUserDefaults standardUserDefaults] boolForKey:@"copyMusicFiles"];

  NSFileManager *fm = [NSFileManager defaultManager];

  if (![[NSApp delegate] playlistFolder] || ![[NSApp delegate] musicFolder]) {
    DDLogError(@"Unable to find playlist folder");
		return;
	}

	// Prep our destination
	[RTMediaManager prepMedia];

  [fm createDirectoryAtURL:[[NSApp delegate] playlistFolder] withIntermediateDirectories:YES attributes:nil error:&error];

	if (error) {
		DDLogError(@"%@", error.localizedFailureReason);
		[self errorOccured:error];
		return;
	}
  [fm createDirectoryAtURL:[[NSApp delegate] musicFolder] withIntermediateDirectories:YES attributes:nil error:&error];

	if (error) {
		DDLogError(@"%@", error.localizedFailureReason);
		[self errorOccured:error];
		return;
	}

  for (ITLibPlaylist *p in self.playlists) {

    RTPlaylistWriter *pw = [[RTPlaylistWriter alloc] initWithPlaylist:p];
		pw.delegate = self;
    [self.queue addOperation:pw];

    if (copy) {
      for (ITLibMediaItem *item in [p getFilteredItems]) {
        RTFileWriter *fw = [[RTFileWriter alloc] initWithTrack:item];
				fw.delegate = self;
        [self.queue addOperation:fw];
      }
    }
  }

}

- (void)errorOccured:(NSError *)error
{
	NSLog(@"An error has occured: %@ -- %@", error.localizedFailureReason, error.localizedDescription);
	NSString *path = [error.userInfo valueForKey:@"sourcePath"];
	
	if (path) {
    NSLog(@"The error occured with %@", path);
	}

//	if (!self.processingError) {
//		self.processingError = YES;
//		[self stopExport];
//		NSBeep();
//		[[NSApp delegate] handleError:error];
//	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{

  if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
    if (self.queue.operationCount == 0 && self.exporting) {
      // Do something here when your queue has completed
			[self exportCompleted];
    } else if (self.queue.operationCount == 0) {
			DDLogInfo(@"Queue is empty");
    }

  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)exportCompleted
{
	DDLogInfo(@"queue has completed");
	self.exporting = NO;

	[RTMediaManager removeMetadata];

	NSUserNotification *notification = [NSUserNotification new];
	notification.title = @"Export Completed";
	//			notification.informativeText = [NSString stringWithFormat:@"details details details"];
	notification.soundName = NSUserNotificationDefaultSoundName;
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

}

- (void)stopExport
{
  if (!self.exporting) {
    DDLogInfo(@"We're already stopped…");
    return;
  }

  DDLogInfo(@"Export stopped");
  [self.queue cancelAllOperations];
  self.exporting = NO;

}

- (int)trackCount
{
  int count = 0;

  for (ITLibPlaylist *p in self.playlists) {
    count += [p countOfFilteredItems];
  }

  return count;
}

- (NSMutableArray *)playlists
{
  return _playlists;
}

- (void)setPlaylists:(NSMutableArray *)playlists
{
  _playlists = playlists;
  DDLogVerbose(@"Track Count is now %i", self.trackCount);
}

@end
