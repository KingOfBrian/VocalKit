//
//  VKDecoder.m
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VKPocketSphinxDecoder.h"

#import "VKController.h"

static const arg_t vk_args_def[] = {
    POCKETSPHINX_OPTIONS,
    /* Argument file. */
    { "-argfile",
		ARG_STRING,
		NULL,
		"Argument file giving extra arguments." },
    { "-adcdev", ARG_STRING, NULL, "Name of audio device to use for input." },
    CMDLN_EMPTY_OPTION
};


@implementation VKPocketSphinxDecoder
@synthesize configFile;

- (id) initWithConfigFile:(NSString*)config {
	self = [super init];
	if (self) {
		self.configFile = config;
		_ps = nil;
		_config = nil;
	}
	return self;
}

- (cmd_ln_t*) config {
	if (_config) { return _config; }
	
	_config = cmd_ln_parse_file_r(NULL, vk_args_def, [[self configFile] UTF8String], TRUE);

	return _config;
}

- (void) setConfigString:(NSString*)str forKey:(NSString*)key {
	cmd_ln_set_str_r([self config], [key UTF8String], [str UTF8String]);
}

- (void) setConfigInt:(int)iValue forKey:(NSString*)key {
	cmd_ln_set_int_r([self config], [key UTF8String], iValue);
}

- (void) setConfigFloat:(float)fValue forKey:(NSString*)key {
	cmd_ln_set_float_r([self config], [key UTF8String], fValue);
}


- (ps_decoder_t*) ps {
	if (_ps) { return _ps; }
	
	_ps = ps_init([self config]);
	
	return _ps;
}

- (void) startDecode {
	ps_start_utt([self ps], NULL);
}
- (void) stopDecode {
	ps_end_utt([self ps]);
}

- (void) postNotificationOfRecognizedText {
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	int32 score;
	const char* uttid;
	const char* hyp = ps_get_hyp([self ps], &score, &uttid);
	
	[dnc postNotificationName:VKRecognizedPhraseNotification
					   object:self 
					 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							   [NSString stringWithCString:hyp encoding:[NSString defaultCStringEncoding]], 
							   VKRecognizedPhraseNotificationTextKey,
   							   [NSString stringWithCString:uttid encoding:[NSString defaultCStringEncoding]], 
							   VKRecognizedPhraseNotificationIDKey,
							   [NSNumber numberWithInt:score], 
							   VKRecognizedPhraseNotificationScoreKey,
							   nil]
	 ];
}

- (void) recievePackets:(UInt32)packetCount fromBuffer:(AudioQueueBufferRef)buffer {
	ps_process_raw([self ps], (int16*)buffer->mAudioData, packetCount, 1, 0);
}

- (void) gramarStates:(NSDictionary*)states transitions:(NSDictionary*)transitions named:(NSString*)name {

//	for (NSString *name in [states allKeys]) {
//		NSArray *words = [states objectForKey:name];
//
//		for (id<NSObject> state in words) {
//			if ([state isKindOfClass:[NSArray class]]) {
//				// Multiple Pronunciations
//				NSString* baseWord = nil;
//			} else {
//				// Single Pronunciation
//			}
//		}
//	}
}



- (void) printDebug {
	int32 score;
	const char* uttid;

	const char* hyp = ps_get_hyp([self ps], &score, &uttid);
	NSLog(@"M=%s", hyp);
}

- (void) dealloc {
	// Are we leaking _config?
	if (_ps) {
		ps_free(_ps);
	}
	[super dealloc];
}

@end
