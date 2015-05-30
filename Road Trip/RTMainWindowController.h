//
//  RTMainWindowController.h
//  Road Trip
//
//  Created by James Moore on 7/29/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Cocoa;
#import "RTConversionManager.h"

@interface RTMainWindowController : NSWindowController

- (IBAction)showPathOpenPanel:(id)sender;
- (IBAction)refreshLibrary:(id)sender;
- (IBAction)exportButtonClicked:(id)sender;
- (BOOL)readyToExport;

@property (strong) NSString *exportButtonTitle;

@end
