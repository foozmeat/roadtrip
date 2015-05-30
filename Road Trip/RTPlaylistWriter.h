//
//  RTPlaylistWriter.h
//  Road Trip
//
//  Created by James Moore on 8/5/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Foundation;
#import "RTWriter.h"

@interface RTPlaylistWriter : RTWriter

- (id)initWithPlaylist:(ITLibPlaylist *)playlist;

@property (nonatomic, strong) ITLibPlaylist *playlist;

@end
