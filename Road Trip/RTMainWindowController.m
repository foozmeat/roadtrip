//
//  RTMainWindowController.m
//  Road Trip
//
//  Created by James Moore on 7/29/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTMainWindowController.h"

#import "RTOutlineView.h"
#import "RTConversionManager.h"
#import "RTPlaylistWriter.h"
#import "RTGRidImage.h"
#import "RTPlaylistOutlineManager.h"

@interface RTMainWindowController ()
@property (strong) IBOutlet RTOutlineView *outlineView;
@property (strong) IBOutlet NSPathControl *cardPathControl;
@property (strong) IBOutlet NSButton *setPathButton;
@property (strong) IBOutlet NSTextField *remaingSizeLabel;
@property (strong) IBOutlet NSTextField *spaceAvailableLabel;
@property (strong) IBOutlet NSTextField *usedSizeLabel;
@property (strong) IBOutlet NSTextField *spaceUsedLabel;
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet NSCollectionView *coverView;
@property (strong) IBOutlet NSScrollView *coverScrollView;
@property (strong) IBOutlet RTPlaylistOutlineManager *outlineManager;
@property (strong) IBOutlet NSToolbarItem *startToolbarItem;

@property (strong) RTConversionManager *converter;
@property BOOL alreadyInitialized;
@property (strong) NSMutableArray *covers;
@property NSDate *lastUIUpdate;

// Bindings
@property (strong) NSString *selectedTracksLabel;
@property (strong) NSImage *exportButtonImage;
@property BOOL readyToExport;
@property NSUInteger progressBarMaxValue;
@property NSURL *pathControlURL;

@end

@implementation RTMainWindowController


#pragma mark - UI
- (void)updateExportButton
{
  if (self.converter.exporting) {
		self.exportButtonTitle = @"Stop";
		// We have to set the label explicitely because it doesn't have a binding.
		self.startToolbarItem.label = @"Stop";
		self.exportButtonImage = [NSImage imageNamed:@"StopTemplate"];
	} else {
		self.exportButtonTitle = @"Start";
		self.startToolbarItem.label = @"Start";
		self.exportButtonImage = [NSImage imageNamed:@"PlayTemplate"];
	}
}

#pragma mark - IBAction
- (IBAction)refreshLibrary:(id)sender
{
  [self.outlineManager reloadLibrary];
}

- (IBAction)exportButtonClicked:(id)sender
{

  if (self.converter.exporting) {
    [self.converter stopExport];
  } else {
    [self.converter startExport];
    self.progressBar.doubleValue = 0;
		[self.covers removeAllObjects];
		self.coverView.content = self.covers;
  }
}

#pragma mark - NSPathControl
//- (void) updateSizeLabels
//{
//	double interval = [self.lastUIUpdate timeIntervalSinceNow];
//	if (interval <= -1) {
//		// Update the free space at the path
//		NSFileManager *fm = [NSFileManager defaultManager];
//		NSURL *url = [[NSApp delegate] urlFromBookmark:[[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]];
//		NSString *path = [url path];
//		if (path) {
//			NSDictionary *attributes = [fm attributesOfFileSystemForPath:path error:nil];
//			NSNumber *fileSize = [attributes objectForKey:@"NSFileSystemFreeSize"];
//			NSNumber *usedSpace = [NSNumber numberWithInt:[self folderSize:path]];
//
//			self.remaingSizeLabel.integerValue = fileSize.integerValue;
//			self.usedSizeLabel.integerValue = usedSpace.integerValue;
//			self.spaceAvailableLabel.hidden = NO;
//			self.spaceUsedLabel.hidden = NO;
//
//
//		} else {
//			self.remaingSizeLabel.stringValue = @"";
//			self.usedSizeLabel.stringValue = @"";
//			self.spaceAvailableLabel.hidden = YES;
//			self.spaceUsedLabel.hidden = YES;
//		}
//		self.lastUIUpdate = [NSDate date];
//	}
//
//}

//- (unsigned int)folderSize:(NSString *)folderPath {
//	NSFileManager *fm = [NSFileManager defaultManager];
//	NSArray *filesArray = [fm subpathsOfDirectoryAtPath:folderPath error:nil];
//	NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
//	NSString *fileName;
//	NSError *error = nil;
//	unsigned int fileSize = 0;
//
//	while (fileName = [filesEnumerator nextObject]) {
//		NSDictionary *fileDictionary = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", folderPath, fileName] error:&error];
//		fileSize += [fileDictionary fileSize];
//	}
//
//	return fileSize;
//}

- (IBAction)showPathOpenPanel:(id)sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection:NO];
  [panel setCanChooseDirectories:YES];
  [panel setCanChooseFiles:NO];
  [panel setResolvesAliases:YES];

  NSString *panelTitle = NSLocalizedString(@"Choose a file", @"Title for the open panel");
  [panel setTitle:panelTitle];

  NSString *promptString = NSLocalizedString(@"Choose", @"Prompt for the open panel prompt");
  [panel setPrompt:promptString];

  [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){

    // Hide the open panel.
    [panel orderOut:self];

    if (result != NSOKButton) {
			// If the return code wasn't OK, don't do anything.
      return;
    }
    // Get the first URL returned from the Open Panel and set it at the first path component of the control.

    NSURL *url = [[panel URLs] objectAtIndex:0];
    NSData *data = [[NSApp delegate] bookmarkFromURL:url];
    
    if (data) {
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      [prefs setObject:data forKey:@"destinationPath"];
      [prefs synchronize];
    }

  }];
}

- (IBAction)pathControlClicked:(id)sender
{
  if ([self.cardPathControl clickedPathComponentCell] != nil) {

    [[NSWorkspace sharedWorkspace] openURL:[self.cardPathControl URL]];
  }
}

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  ITLibPlaylist *plItem = item;

  if ([tableColumn.identifier isEqualToString:@"nameColumn"]) {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    cellView.textField.stringValue = plItem.name;

    return cellView;
  } else {

    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"CountCell" owner:self];
    // We need to use this dummy parent view so that sizeToFit will work right on the button
    NSView *parent = [[cellView subviews] objectAtIndex:0];
    NSButton *countButton = [parent viewWithTag:1];
    countButton.title = [NSString stringWithFormat:@"%li", [plItem countOfFilteredItems]];
    [countButton sizeToFit];

    double originX = parent.frame.size.width - countButton.frame.size.width - 10.0;

    NSRect buttonRect = NSRectFromString([NSString stringWithFormat:@"%f, %i, %f, %f",
                                          originX,
                                          -4,
                                          countButton.frame.size.width,
                                          countButton.frame.size.height]);
    countButton.frame = buttonRect;

    return parent;

  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
  return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  NSIndexSet *selectedRowIndexes = self.outlineView.selectedRowIndexes;
  NSMutableArray *selectedPlaylists = [NSMutableArray new];

  [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    DDLogVerbose(@"Selected row %li", idx);
		ITLibPlaylist *p = (ITLibPlaylist *)[self.outlineView itemAtRow:idx];
    [selectedPlaylists addObject:p];
  }];

  self.converter.playlists = selectedPlaylists;

  int trackCount = self.converter.trackCount;

	if (trackCount == 0) {
    self.selectedTracksLabel = @"";
		self.readyToExport = NO;
  } else {
    self.selectedTracksLabel = [NSString stringWithFormat:@"%i tracks selected", trackCount];

		if ([[NSUserDefaults standardUserDefaults] dataForKey:@"destinationPath"]) {
			self.readyToExport = YES;
		}
  }

	self.progressBarMaxValue = self.converter.trackCount + selectedRowIndexes.count;

}

- (void)playlistCompleted:(NSNotification *)notification
{
	if (!self.converter.exporting) {
		return;
	}
	
  [self.progressBar incrementBy:1.0];

}

- (void)trackCompleted:(NSNotification *)notification
{
  [self.progressBar incrementBy:1.0];

	NSDictionary *userinfo = notification.userInfo;
	BOOL skipped = [(NSNumber *)[userinfo objectForKey:@"skipped"] boolValue];

	if (!skipped) {
		RTGRidImage *image = (RTGRidImage *)notification.object;

		[self addThumbnail:image];

	}

	//	[self updateSizeLabels];

}

- (void)addThumbnail:(RTGRidImage *)thumbnail
{

	if (!thumbnail) {
		thumbnail = [RTGRidImage new];
	}

	if (!thumbnail.image) {
		thumbnail.image = [NSImage imageNamed:@"Blank"];
	}

	[self.covers addObject:thumbnail];
	self.coverView.content = self.covers;

//	[[self mutableArrayValueForKey:@"covers"] addObject:thumbnail];

	NSRect newItemRect = [self.coverView frameForItemAtIndex:self.covers.count - 1];
	[self.coverView scrollRectToVisible:newItemRect];

}

#pragma mark - View Lifecycle
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"destinationPath"]) {

		NSURL *url = [[NSApp delegate] urlFromBookmark:[change objectForKey:@"new"]];

		self.pathControlURL = url;
		self.converter.destinationPath = url;

		if (self.converter.trackCount > 0) {
			self.readyToExport = YES;
		}

//    [self updateSizeLabels];
  } else if ([keyPath isEqualToString:@"exportUncheckedTracks"]) {
    [self.outlineView reloadData];
  } else if ([keyPath isEqualToString:@"exporting"]) {
    [self updateExportButton];
  }

}

//-(void)handleNotifications:(NSNotification*)aNotification
//{
//	if ([[aNotification name] isEqualToString:@"NSApplicationWillBecomeActiveNotification"]) {
//		[self updateSizeLabels];
//	}
//}
- (void)awakeFromNib
{

  if (! self.alreadyInitialized) {
    self.alreadyInitialized = YES;

		self.covers = [NSMutableArray new];
		self.coverView.content = self.covers;

    self.converter = [RTConversionManager new];
//    self.converter.delegate = self;

		self.lastUIUpdate = [NSDate dateWithTimeIntervalSince1970:0];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults addObserver:self forKeyPath:@"destinationPath" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial ) context:NULL];
    [defaults addObserver:self forKeyPath:@"exportUncheckedTracks" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial ) context:NULL];

		[self.converter addObserver:self forKeyPath:@"exporting" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial ) context:NULL];

//		[[NSNotificationCenter defaultCenter] addObserver: self
//																						 selector: @selector(handleNotifications:)
//																								 name: NSApplicationWillBecomeActiveNotification object: NULL];

    [[self outlineView] expandItem:nil expandChildren:YES];

		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(trackCompleted:)
																								 name:@"TrackCompleted"
																							 object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(playlistCompleted:)
																								 name:@"PlaylistCompleted"
																							 object:nil];

    self.progressBar.maxValue = 0;
		self.readyToExport = NO;

		self.spaceUsedLabel.hidden = YES;
		self.spaceAvailableLabel.hidden = YES;
		self.remaingSizeLabel.hidden = YES;
		self.usedSizeLabel.hidden = YES;

		NSURL *path = [[NSApp delegate] urlFromBookmark:[defaults dataForKey:@"destinationPath"]];
		self.pathControlURL = path;

    if (path) {
      [path startAccessingSecurityScopedResource];
    }

  }
}

@end
