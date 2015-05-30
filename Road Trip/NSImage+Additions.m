//
//  NSImage+NSImage_ProportionalScaling.m
//  Road Trip
//
//  Created by James Moore on 10/9/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "NSImage+Additions.h"

@implementation NSImage (Additions)

- (void) saveAsJpegWithName:(NSString*) fileName
{
	// Cache the reduced image
	NSData *imageData = [self TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
	imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
	[imageData writeToFile:fileName atomically:NO];
}

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize
{
  NSImage* sourceImage = self;
  NSImage* newImage = nil;

  if ([sourceImage isValid])
  {
    NSSize imageSize = [sourceImage size];
    double width  = imageSize.width;
    double height = imageSize.height;
		CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];

    double targetWidth  = targetSize.width * screenScale;
    double targetHeight = targetSize.height * screenScale;

    double scaleFactor  = 0.0;
    double scaledWidth  = targetWidth;
    double scaledHeight = targetHeight;


    NSPoint thumbnailPoint = NSZeroPoint;

    if ( NSEqualSizes( imageSize, targetSize ) == NO )
    {

      double widthFactor  = targetWidth / width;
      double heightFactor = targetHeight / height;

      if ( widthFactor < heightFactor )
        scaleFactor = widthFactor;
      else
        scaleFactor = heightFactor;

      scaledWidth  = width  * scaleFactor / screenScale;
      scaledHeight = height * scaleFactor / screenScale;

      if ( widthFactor < heightFactor )
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;

      else if ( widthFactor > heightFactor )
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }

    newImage = [[NSImage alloc] initWithSize:targetSize];

    [newImage lockFocus];

		NSRect thumbnailRect;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width = scaledWidth;
		thumbnailRect.size.height = scaledHeight;

		[sourceImage drawInRect: thumbnailRect
									 fromRect: NSZeroRect
									operation: NSCompositeSourceOver
									 fraction: 1.0];

    [newImage unlockFocus];

  }

  return newImage;
}

- (void)dump {
	NSBitmapImageRep *imageRep = [[self representations] objectAtIndex: 0];
	NSData *data = [imageRep representationUsingType: NSPNGFileType properties: nil];
	[data writeToFile: @"/tmp/image.png" atomically: NO];
}

@end
