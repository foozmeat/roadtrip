//
//  RTWriter.h
//  Road Trip
//
//  Created by James Moore on 10/10/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Foundation;

@class RTConversionManager;

@protocol RTWriterDelegate <NSObject>
- (void)errorOccured:(NSError *)error;
@end

@interface RTWriter : NSOperation
@property (strong) RTConversionManager <RTWriterDelegate> *delegate;


@end

