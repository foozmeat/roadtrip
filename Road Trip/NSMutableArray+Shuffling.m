//
//  NSMutableArray+Shuffling.m
//  Road Trip
//
//  Created by James Moore on 1/12/14.
//  Copyright (c) 2014 James Moore. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
	u_int32_t count = (u_int32_t) [self count];
	for (uint i = 0; i < count; ++i)
	{
		// Select a random element between i and end of array to swap with.
		u_int32_t nElements = count - i;
		NSUInteger n = arc4random_uniform(nElements) + i;
		[self exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

@end
