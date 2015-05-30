//
//  RTMediaManager.m
//  Road Trip
//
//  Created by James Moore on 11/24/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTMediaManager.h"

@implementation RTMediaManager

+ (NSError *)prepMedia
{
	NSError *error;
  NSURL *url = [[NSApp delegate] urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *spotlightFolder = [[url URLByAppendingPathComponent:@".Spotlight-V100"] path];

	// Have we already prepped this path?
	BOOL isDir = NO;
	BOOL pathExists = [fm fileExistsAtPath:spotlightFolder isDirectory:&isDir];

	if (pathExists && isDir) {
		DDLogVerbose(@"Media has not been prepped");

		NSString *metaData = [[url URLByAppendingPathComponent:@".metadata_never_index"] path];
		[fm createFileAtPath:metaData contents:nil attributes:nil];

		[fm removeItemAtPath:spotlightFolder error:&error];
		DDLogVerbose(@"%@", error.localizedDescription);
		[fm createFileAtPath:spotlightFolder contents:nil attributes:nil];

		NSString *trashes = [[url URLByAppendingPathComponent:@".Trashes"] path];
		[fm removeItemAtPath:trashes error:&error];
		DDLogVerbose(@"%@", error.localizedDescription);
		[fm createFileAtPath:trashes contents:nil attributes:nil];

		NSString *fsevents = [[url URLByAppendingPathComponent:@".fseventsd"] path];
		[fm removeItemAtPath:fsevents error:&error];
		DDLogVerbose(@"%@", error.localizedDescription);
		[fm createFileAtPath:fsevents contents:nil attributes:nil];

		NSString *temp = [[url URLByAppendingPathComponent:@".TemporaryItems"] path];
		[fm removeItemAtPath:temp error:&error];
		DDLogVerbose(@"%@", error.localizedDescription);
		[fm createFileAtPath:temp contents:nil attributes:nil];

	} else if (pathExists && !isDir) {
		DDLogVerbose(@"Media has already been prepped");
	} else {
		DDLogVerbose(@"No spotlight folder found. Perhaps this isn't a removable device?");
	}

	return error;
}

+ (NSError *)removeMetadata
{
	DDLogInfo(@"Removing metadata files");

	NSError *locationError;
  NSURL *url = [[NSApp delegate] urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];

	NSTask *deleteTask = [[NSTask alloc] init];
	deleteTask.launchPath = @"/usr/bin/find";
	deleteTask.arguments = @[ url.path, @"-type", @"f", @"-iname", @"._*", @"-delete", @"-print" ];
	[deleteTask launch];
	[deleteTask waitUntilExit];
	int status = [deleteTask terminationStatus];

	if (status != 0) {
		NSString *errorDetail = [NSString stringWithFormat:@"An error occured removing metadata from device" ];
		locationError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:errorDetail}];
		DDLogError(@"%@", locationError.localizedFailureReason);
	}

	return locationError;

}

@end
