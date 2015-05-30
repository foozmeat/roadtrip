//
//  RTOutlineView.m
//  Road Trip
//
//  Created by James Moore on 7/31/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTOutlineView.h"

@implementation RTOutlineView

#define kOutlineCellWidth 14
#define kOutlineMinLeftMargin 1

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
{
  NSRect superFrame = [super frameOfCellAtColumn:column row:row];

  if (column == 0) {
    // expand by kOutlineCellWidth to the left to cancel the indent
    CGFloat adjustment = kOutlineCellWidth;

    // ...but be extra defensive because we have no fucking clue what is going on here

    if (superFrame.origin.x - adjustment < kOutlineMinLeftMargin) {
      NSLog(@"%@ adjustment amount is incorrect: adjustment = %f, superFrame = %@, kOutlineMinLeftMargin = %f", NSStringFromClass([self class]), (float)adjustment, NSStringFromRect(superFrame), (float)kOutlineMinLeftMargin);
      adjustment = MAX(0, superFrame.origin.x - kOutlineMinLeftMargin);
    }

    return NSMakeRect(superFrame.origin.x - adjustment, superFrame.origin.y, superFrame.size.width + adjustment, superFrame.size.height);
  }

  return superFrame;
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		// Initialization code here.
	}
  
	return self;
}

@end
