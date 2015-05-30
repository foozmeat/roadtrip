//
//  NSImage+NSImage_ProportionalScaling.h
//  Road Trip
//
//  Created by James Moore on 10/9/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Cocoa;

@interface NSImage (Additions)

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize;
- (void) saveAsJpegWithName:(NSString*) fileName;
- (void)dump;

@end
