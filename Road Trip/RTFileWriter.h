//
//  RTFileWriter.h
//  Road Trip
//
//  Created by James on 9/8/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Foundation;
#import "RTWriter.h"
#import "RTGRidImage.h"

@interface RTFileWriter : RTWriter

- (id)initWithTrack:(ITLibMediaItem *)track;

@property (nonatomic, strong) ITLibMediaItem *track;

@end
