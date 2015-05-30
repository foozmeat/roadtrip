//
//  RTGeneralPreferencesViewController.m
//  Road Trip
//
//  Created by James Moore on 9/11/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTGeneralPreferencesViewController.h"

@interface RTGeneralPreferencesViewController ()

@end

@implementation RTGeneralPreferencesViewController

- (id)init
{
	return [super initWithNibName:@"RTGeneralPreferencesView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
	return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
	return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
	return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (void)awakeFromNib
{
}

@end
