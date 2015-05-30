//
//  RTThumbnail.h
//  Road Trip
//
//  Created by James Moore on 10/13/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Foundation;

@interface RTGRidImage : NSObject

@property NSImage *image;
@property NSString *title;

- (id)initWithTitle:(NSString *)title;

@end
