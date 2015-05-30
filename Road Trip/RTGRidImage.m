//
//  RTThumbnail.m
//  Road Trip
//
//  Created by James Moore on 10/13/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "RTGRidImage.h"

@implementation RTGRidImage

- (id)initWithTitle:(NSString *)title
{
	self = [super init];

	if (self) {
		self.title = title;
	}

	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	RTGRidImage *newGridImage = [[[self class] allocWithZone:zone] init];
	newGridImage->_image = [_image copyWithZone:zone];
	newGridImage->_title = [_title copyWithZone:zone];
	// etc...
	return newGridImage;
}

@end
