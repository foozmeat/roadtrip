//
//  ITLibPlaylist+Additions.h
//  Road Trip
//
//  Created by James Moore on 8/5/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import <iTunesLibrary/ITLibPlaylist.h>

@interface ITLibPlaylist (Additions)

- (NSArray *)getFilteredItems;
- (NSUInteger)countOfFilteredItems;

@end
