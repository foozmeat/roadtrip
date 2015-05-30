//
//  NSSound+AlertAudioAdditions.m
//  Road Trip
//
//  Created by James Moore on 9/13/13.
//  Copyright (c) 2013 James Moore. All rights reserved.
//

#import "NSSound+AlertAudioAdditions.h"
@import CoreAudio;

@implementation NSSound (AlertAudioAdditions)
+ (NSString*)_alertSoundAlertDeviceIdentifier
{
	AudioDeviceID deviceID = 0;
	UInt32 size = sizeof( AudioDeviceID );

	// get the system default audio output device …
	AudioObjectPropertyAddress address = {
		kAudioHardwarePropertyDefaultSystemOutputDevice,
		kAudioObjectPropertyScopeGlobal,
		kAudioObjectPropertyElementMaster
	};

	OSStatus error = AudioObjectGetPropertyData( kAudioObjectSystemObject, &address, 0, NULL, &size, &deviceID );
	if ( error != noErr ) return nil;

	// … then, since one exists, get the unique identifier …
	UInt32 stringSize = sizeof( CFStringRef );
	CFStringRef deviceUniqueIdentifier = NULL;

	address.mSelector = kAudioDevicePropertyDeviceUID;
	address.mScope = kAudioObjectPropertyScopeGlobal;
	address.mElement = kAudioObjectPropertyElementMaster;

	error = AudioObjectGetPropertyData( deviceID, &address, 0, NULL, &stringSize, &deviceUniqueIdentifier );
	if ( error != noErr ) return nil;

	return (__bridge NSString*) deviceUniqueIdentifier;
}

+ (id)alertSoundNamed: (NSString*)name
{
	NSSound *sound = [NSSound soundNamed: name];
	[sound setPlaybackDeviceIdentifier: [self _alertSoundAlertDeviceIdentifier]];
	return sound;
}


@end
