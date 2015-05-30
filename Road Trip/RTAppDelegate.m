//
//  RTAppDelegate.m
//  Road Trip
//
//  Created by James Moore on 7/29/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTAppDelegate.h"
#import "RTMainWindowController.h"
#import "MASPreferencesWindowController.h"
#import "RTGeneralPreferencesViewController.h"
#import "RTPlaylistPreferencesViewController.h"
#import <DCOAboutWindow/DCOAboutWindowController.h>

@interface RTAppDelegate ()

- (IBAction)showPreferences:(id)sender;

@property (nonatomic, strong) RTMainWindowController *myWindowController;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
@property (nonatomic, strong) DCOAboutWindowController *aboutWindowController;
@property (nonatomic, strong) DDFileLogger *fileLogger;
@end

@implementation RTAppDelegate

@synthesize preferencesWindowController = _preferencesWindowController;
@synthesize myWindowController = _myWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

	// Logging
	PCFileFunctionLevelFormatter *fileFormatter = [PCFileFunctionLevelFormatter new];

	[DDLog addLogger:[DDTTYLogger sharedInstance]];
//	[DDLog addLogger:[DDASLLogger sharedInstance]];

	_fileLogger = [[DDFileLogger alloc] init];
	_fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
	_fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
	_fileLogger.logFormatter = fileFormatter;
	
	[DDLog addLogger:_fileLogger];

	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
	[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithRed:0.714f green:0.729f blue:0.714f alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
	[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithRed:0.624f green:0.635f blue:0.337f alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_INFO];
	[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithRed:0.839f green:0.631f blue:0.298f alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_WARN];
	[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithRed:0.925 green:0.000 blue:0.000 alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
	
	PCFileFunctionLevelFormatter *consoleFormatter = [PCFileFunctionLevelFormatter new];
	[[DDTTYLogger sharedInstance] setLogFormatter:consoleFormatter];
	

  if (!NSClassFromString(@"ITLibrary")) {
		// Check to make sure that iTunes 11 Framework is installed.
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"You must have iTunes 11 installed in order to use Road Trip."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Download iTunes"];

    if ([alert runModal] == NSAlertSecondButtonReturn) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://apple.com/itunes/"]];

    }

  } else {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

		// General Settings
		[settings setObject:[NSNumber numberWithBool:NO] forKey:@"exportUncheckedTracks"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"copyMusicFiles"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"convertFiles"];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:@"embedAlbumArt"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"resizeAlbumArt"];

		// Playlist Settings
    [settings setObject:[NSNumber numberWithBool:NO] forKey:@"shufflePlaylistOrder"];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:@"useExtendedM3U"];

    [settings setObject:[[NSURL URLWithString:@""] absoluteString] forKey:@"destinationPath"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:settings];

    // Check to make sure the path in the prefs exists
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [self urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];

    if (![fm fileExistsAtPath:url.path]) {
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"destinationPath"];
    }

    _myWindowController = [[RTMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [self.myWindowController showWindow:self];

  }
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

#ifdef DEBUG
	NSString *compileDate = [NSString stringWithUTF8String:__DATE__];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM d yyyy"];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:locale];
	NSDate *buildDate = [dateFormatter dateFromString:compileDate];
	NSDate *expirationDate = [buildDate dateByAddingTimeInterval:(60.0 * 60.0 * 24.0 * 14.0)];

	NSTimeInterval interval = [expirationDate timeIntervalSinceDate:[NSDate date]];
	
  if (interval < 0) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"This copy of Road Trip has expired. Please delete and reinstall from the Mac App Store."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert addButtonWithTitle:@"Quit"];
		long result = [alert runModal];

		if (result == NSAlertFirstButtonReturn) {
			//quit
			[[NSApplication sharedApplication] terminate:self];
		}
	}
#endif
}

- (void)setMyWindowController:(RTMainWindowController *)myWindowController
{
  _myWindowController = myWindowController;
}

- (RTMainWindowController *)myWindowController
{
  if (_myWindowController == nil) {
    _myWindowController = [[RTMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
  }

  return _myWindowController;

}

- (NSWindowController *)preferencesWindowController
{
	if (_preferencesWindowController == nil) {
		NSViewController *generalViewController = [RTGeneralPreferencesViewController new];
		NSViewController *playlistViewController = [RTPlaylistPreferencesViewController new];

		NSArray *controllers = @[generalViewController, playlistViewController];

		// To add a flexible space between General and Advanced preference panes insert [NSNull null]:
		//     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];

		NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
		_preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
	}

	return _preferencesWindowController;
}

- (DCOAboutWindowController *)aboutWindowController {
	if(!_aboutWindowController) {
		_aboutWindowController = [[DCOAboutWindowController alloc] init];
	}
	return _aboutWindowController;
}

// --------
#pragma mark - NSMenu actions

- (IBAction)showAboutWindow:(id)sender {
	
	// Set about window values (override defaults)
	self.aboutWindowController.appWebsiteURL = [NSURL URLWithString:@"http://jmoore.me/projects/roadtrip/"];
	
	// Show the about window
	[self.aboutWindowController showWindow:nil];
	self.aboutWindowController.acknowledgementsPath = nil;
	
}

- (IBAction)showPreferences:(id)sender
{
	[self.preferencesWindowController showWindow:nil];
}

- (IBAction)setDestination:(id)sender
{
  [self.myWindowController showPathOpenPanel:self];
}

- (IBAction)refreshLibrary:(id)sender
{
  [self.myWindowController refreshLibrary:self];
}

- (IBAction)startExport:(id)sender
{
  [self willChangeValueForKey:@"exportMenuItemTile"];
  [self.myWindowController exportButtonClicked:self];
  [self didChangeValueForKey:@"exportMenuItemTile"];

}

- (NSString *)exportMenuItemTile
{
	NSString *title = self.myWindowController.exportButtonTitle ? self.myWindowController.exportButtonTitle : @"Start";

  return [NSString stringWithFormat:@"%@ Export", title];
}

- (BOOL)readyToExport
{
  return self.myWindowController.readyToExport;
}

// --------
#pragma mark - Helper methods

- (NSURL *)playlistURL:(ITLibPlaylist *)playlist
{
  NSURL *file = [[self playlistFolder] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u", playlist.name]];

  return file;
}

- (NSURL *)playlistFolder
{
  NSURL *url = [self urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];

	return url;

	// It might work best to put the playlists at the root
  NSURL *folderURL = [url URLByAppendingPathComponent:@"Playlists"];

  return folderURL;

}

- (NSURL *)musicFolder
{
  NSURL *url = [self urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];

	return url;

  NSURL *musicURL = [url URLByAppendingPathComponent:@"Music"];

  return musicURL;

}

- (NSURL *)urlFromBookmark:(NSData *)bookmark
{
  NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark
                                         options:NSURLBookmarkResolutionWithSecurityScope
                                   relativeToURL:NULL
                             bookmarkDataIsStale:NO
                                           error:NULL];

  return url;
}

- (NSData *)bookmarkFromURL:(NSURL *)url
{
  NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                   includingResourceValuesForKeys:NULL
                                    relativeToURL:NULL
                                            error:NULL];

  return bookmark;
}

- (void)handleError:(NSError *)error
{
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *path = [error.userInfo valueForKey:@"sourcePath"];

	NSString *errorText = [NSString stringWithFormat:@"%@\n%@", error.localizedDescription, path];
	[alert setMessageText:errorText];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert runModal];
}

// -------------------------------------------------------------------------------
//	applicationShouldTerminateAfterLastWindowClosed:sender
//
//	NSApplication delegate method placed here so the sample conveniently quits
//	after we close the window.
// -------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;

}

@end
