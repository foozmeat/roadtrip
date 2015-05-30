//
//  RTPlaylistPreferencesViewController.m
//  Road Trip
//
//  Created by James Moore on 1/11/14.
//  Copyright (c) 2014 James Moore. All rights reserved.
//

#import "RTPlaylistPreferencesViewController.h"

@implementation RTPlaylistPreferencesViewController

- (id)init
{
	return [super initWithNibName:@"RTPlaylistPreferencesView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
	return @"PlaylistPreferences";
}

- (NSImage *)toolbarItemImage
{
	return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
	return NSLocalizedString(@"Playlists", @"Toolbar item name for the Playlist preference pane");
}

- (void)awakeFromNib
{
}

@end
