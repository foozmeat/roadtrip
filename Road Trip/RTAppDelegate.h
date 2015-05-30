//
//  RTAppDelegate.h
//  Road Trip
//
//  Created by James Moore on 7/29/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Cocoa;

@interface RTAppDelegate : NSObject <NSUserNotificationCenterDelegate>



- (NSURL *)playlistURL:(ITLibPlaylist *)playlist;
- (NSURL *)playlistFolder;
- (NSURL *)urlFromBookmark:(NSData *)bookmark;
- (NSURL *)musicFolder;
- (NSData *)bookmarkFromURL:(NSURL *)url;
- (void)handleError:(NSError *)error;


@end
