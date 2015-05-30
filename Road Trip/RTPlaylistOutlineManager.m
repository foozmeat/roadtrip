//
//  RTPlaylistManager.m
//  iTLibTest
//
//  Created by James Moore on 7/29/13.
//  Copyright (c) 2013 Panic Inc. All rights reserved.
//

#import "RTPlaylistOutlineManager.h"
#import "RTOutlineView.h"

@interface RTPlaylistOutlineManager ()
@property BOOL libraryLoaded;
@property (nonatomic, strong) NSArray *library;
@property (strong) IBOutlet RTOutlineView *myOutline;

@end

@implementation RTPlaylistOutlineManager

static ITLibrary *itLibrary = nil;

@synthesize library = _library;

- (id)init
{
  self = [super init];

  if (self) {
    self.libraryLoaded = NO;
    [self loadLibrary];
//		[[NSNotificationCenter defaultCenter] addObserver: self
//																						 selector: @selector(reloadLibrary)
//																								 name: NSApplicationWillBecomeActiveNotification
//																							 object: NULL];

  }

  return self;
}

- (void)reloadLibrary
{
	self.libraryLoaded = NO;
	self.library = nil;
	itLibrary = nil;
	[self loadLibrary];
	[self.myOutline reloadData];
	[self.myOutline expandItem:nil expandChildren:YES];

}

- (void)loadLibrary
{
  NSError *error = nil;
  itLibrary = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
  
  if (itLibrary) {
    NSMutableArray *allPlaylists = [itLibrary.allPlaylists mutableCopy]; //  <- NSArray of ITLibPlaylist

    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"distinguishedKind == %i OR distinguishedKind == %i", ITLibDistinguishedPlaylistKindNone, ITLibDistinguishedPlaylistKindPodcasts];
    NSPredicate *visiblePredicate = [NSPredicate predicateWithFormat:@"visible == YES"];
    NSPredicate *countPredicate = [NSPredicate predicateWithFormat:@"filteredItems.@count > 0"];
    NSPredicate *allPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[typePredicate, visiblePredicate, countPredicate]];

    [allPlaylists filterUsingPredicate:allPredicates];

    _library = allPlaylists;

		if (allPlaylists.count == 0) {
			NSMutableDictionary *details = [NSMutableDictionary dictionary];
			[details setValue:@"Your iTunes library is empty. Please add some music and relaunch Road Trip." forKey:NSLocalizedDescriptionKey];
			// populate the error object with the details
			error = [NSError errorWithDomain:@"world" code:200 userInfo:details];

			[NSApp presentError:error];
			[NSApp terminate:nil];

		} else {

//			for (ITLibPlaylist *p in _library) {
//        DDLogVerbose(@"%@ -- %@ -- %@ -- %li", p.name, p.parentID, p.persistentID, [p countOfFilteredItems]);
//			}

			self.libraryLoaded = YES;
		}
  } else {
    [NSApp presentError:error];
    [NSApp terminate:nil];
    _library = nil;
  }

  DDLogInfo(@"Library loaded with %lu playlists", self.library.count);

}

- (NSArray *)library
{
  if (!self.libraryLoaded) {
    [self loadLibrary];
  }

  return _library;
}

- (ITLibPlaylist *)rootItem
{
  NSPredicate *root = [NSPredicate predicateWithFormat:@"master == YES"];
  NSArray *results = [self.library filteredArrayUsingPredicate:root];
    
	if (results.count > 0) {
		return [results objectAtIndex:0];
	} else {
		return nil;
	}

}

- (NSArray *)childrenOfPlaylist:(ITLibPlaylist *)playlist
{
  NSArray *results;

  if (playlist.master == YES) {
    NSPredicate *root = [NSPredicate predicateWithFormat:@"master == NO"];
    NSPredicate *children = [NSPredicate predicateWithFormat:@"parentID == NULL"];
    NSPredicate *allPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[root, children]];
    results = [self.library filteredArrayUsingPredicate:allPredicates];
  } else {
    NSPredicate *children = [NSPredicate predicateWithFormat:@"parentID == %@", playlist.persistentID];
    results = [self.library filteredArrayUsingPredicate:children];

  }

  return results;
}

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(ITLibPlaylist *)item
{
  // If item is nil then it's looking for the root item

  if (item == nil) {
    return 1;
  }

  NSArray *results = [self childrenOfPlaylist:item];

  return results.count;

}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(ITLibPlaylist *)item
{
  // If item is nil then it's looking for the root item

  if (item == nil) {

    return YES;
	}

  NSArray *results = [self childrenOfPlaylist:item];

  if (results.count > 0) {
    return YES;
  } else {
    return NO;
  }

}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(ITLibPlaylist *)item
{

  if (item == nil) {
    return [self rootItem];
  }

  NSArray *results = [self childrenOfPlaylist:item];

  return [results objectAtIndex:index];

}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(ITLibPlaylist *)item
{
  if ([tableColumn.identifier isEqualToString:@"nameColumn"]) {
    return item.name;
  } else {
    return [NSString stringWithFormat:@"%li", [item countOfFilteredItems]];
    
  }
}

@end
