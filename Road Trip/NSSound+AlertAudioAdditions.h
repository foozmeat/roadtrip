//
//  NSSound+AlertAudioAdditions.h
//  Road Trip
//
//  Created by James Moore on 9/13/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

@import Cocoa;

@interface NSSound (AlertAudioAdditions)
+ (NSString*)_alertSoundAlertDeviceIdentifier;
+ (id)alertSoundNamed: (NSString*)name;

@end
