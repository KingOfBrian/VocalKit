//
//  VKController.m
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VKController.h"

#import "VKPocketSphinxDecoder.h"
#import "VKAudioQueueConnector.h"


NSString * const VKRecognizedPhraseNotification = @"VKRecognizedPhraseNotification";
NSString * const VKRecognizedPhraseNotificationTextKey = @"VKRecognizedPhraseNotificationTextKey";
NSString * const VKRecognizedPhraseNotificationIDKey = @"VKRecognizedPhraseNotificationIDKey";
NSString * const VKRecognizedPhraseNotificationScoreKey = @"VKRecognizedPhraseNotificationScoreKey";


@interface VKController(Private)
- (void) configureConnector;

@end


@implementation VKController


- (id) initWithType:(VKDecoderType)dType configFile:(NSString*)configFile {
	self = [super init];
	if (self) {
		if (type == VKDecoderTypePocketSphinx) {
			VKPocketSphinxDecoder *psDecoder = [[VKPocketSphinxDecoder alloc] initWithConfigFile:configFile];
			decoder = psDecoder;
			type = dType;
		} else {
			NSAssert(false, @"Unsupported Decoder Type");
		}
	
		[self configureConnector];
	}
	return self;
}


- (void) setMode:(VKDecoderMode)dMode {
	mode = dMode;
}

- (void) setConfigString:(NSString*)str forKey:(NSString*)key {
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder*)decoder;
	
	[psDecoder setConfigString:str forKey:key];
}
- (void) setConfigInt:(int)iValue       forKey:(NSString*)key {
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder*)decoder;
	
	[psDecoder setConfigInt:iValue forKey:key];	
}
- (void) setConfigFloat:(float)fValue   forKey:(NSString*)key {
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder*)decoder;
	
	[psDecoder setConfigFloat:fValue forKey:key];
}


- (void) configureConnector {
	VKAudioQueueConnector *aqc = [[VKAudioQueueConnector alloc] initWithDecorder:decoder];
	
	connector = aqc;
}

- (void) startListening {
	VKAudioQueueConnector *aqc = (VKAudioQueueConnector*)connector;

	[decoder startDecode];
	[aqc startListening];
}
- (void) stopListening {
	VKAudioQueueConnector *aqc = (VKAudioQueueConnector*)connector;
	
	[aqc stopListening];
	[decoder stopDecode];
}

- (BOOL) isListening {
	VKAudioQueueConnector *aqc = (VKAudioQueueConnector*)connector;
	
	return [aqc listening];
}
- (void) postNotificationOfRecognizedText {
	[decoder postNotificationOfRecognizedText];
}
- (void) showListened {
	[decoder printDebug];
}

- (void) dealloc {
	if (decoder) {
		[decoder release];
	}
	if (connector) {
		[connector release];
	}
	[super dealloc];
}

@end
