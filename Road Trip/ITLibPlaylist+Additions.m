//
//  ITLibPlaylist+Additions.m
//  Road Trip
//
//  Created by James Moore on 8/5/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "ITLibPlaylist+Additions.h"
@class ITLibPlaylist;

@implementation ITLibPlaylist (Additions)

- (NSArray *)getFilteredItems
{
  NSMutableArray *results = [self.items mutableCopy];

  NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"mediaKind == %i OR mediaKind == %i", ITLibMediaItemMediaKindSong, ITLibMediaItemMediaKindPodcast];
  NSPredicate *location = [NSPredicate predicateWithFormat:@"locationType == %i", ITLibMediaItemLocationTypeFile];
  NSPredicate *kind = [NSPredicate predicateWithFormat:@"kind != %@", @"iTunes LP"];
  NSPredicate *required = [NSCompoundPredicate andPredicateWithSubpredicates:@[typePredicate, location, kind]];

  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"exportUncheckedTracks"]) {
    NSPredicate *checked = [NSPredicate predicateWithFormat:@"userDisabled == NO"];
    NSPredicate *allPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[checked, required]];
    [results filterUsingPredicate:allPredicates];
  } else {
    [results filterUsingPredicate:required];
  }

  return results;

}

- (NSUInteger)countOfFilteredItems
{
  return [[self getFilteredItems] count];
}

@end
