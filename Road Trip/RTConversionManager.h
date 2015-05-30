//
//  RTPlaylistConverter.h
//  Road Trip
//
//  Created by James Moore on 8/2/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Foundation;
#import "RTWriter.h"

//@protocol RTConversionManagerDelegate <NSObject>
//
//- (void)trackCompleted;
//- (void)exportCompleted;
//- (void)addThumbnail:(NSImage *)thumbnail;
//@end

@interface RTConversionManager : NSObject <RTWriterDelegate>

//@property (strong) NSWindowController <RTConversionManagerDelegate> *delegate;

@property (strong) NSMutableArray *playlists;
@property (strong) NSURL *destinationPath;
@property (atomic) BOOL exporting;

@property (readonly) int trackCount;

- (void)startExport;
- (void)stopExport;

@end
