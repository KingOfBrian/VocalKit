//
//  VKFliteSpeaker.m
//  VocalKit
//
//  Created by Brian King on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VKFliteSpeaker.h"

#import "flite_version.h"
#include <AudioToolbox/AudioToolbox.h>


@implementation VKFliteSpeaker

- (id) init {
	self = [super init];
	if (self) {
		// Flite uses a global variable for voice list, this should be a singleton for that reason.
		if (flite_voice_list == 0) {
			flite_init();

			flite_voice_list = cons_val(voice_val(register_cmu_us_slt(NULL)),flite_voice_list);
			flite_voice_list = val_reverse(flite_voice_list);

		}
		feature_config = new_features();
	}
	return self;
}
- (void) speakText:(NSString*) text toFile:(NSString*) filename {
	float durs;
	if (text == nil || [text isEqual:@""]) {
		return;
	}
	if (desired_voice == 0) {
		desired_voice = flite_voice_select(NULL);
	}
	feat_copy_into(feature_config,desired_voice->features);
	
	durs = flite_text_to_speech([text UTF8String],desired_voice,[filename UTF8String]);
}


- (NSArray*) speakers {
	cst_voice *voice;
    const cst_val *v;
	
	NSMutableArray *result = [NSMutableArray array];
	
    for (v=flite_voice_list; v; v=val_cdr(v))
    {
        voice = val_voice(val_car(v));
		[result addObject:[NSString stringWithUTF8String:voice->name]];
    }
	
    return result;
}

- (void) setSpeaker:(NSString*)speakerName {
	desired_voice = flite_voice_select([speakerName UTF8String]);
}


- (void) setIntegerValue:(int)iValue forKey:(NSString*)key {
	feat_set_int(feature_config, [key UTF8String], iValue);
}

- (void) setFloatValue:(float)fValue forKey:(NSString*)key {
	feat_set_float(feature_config, [key UTF8String], fValue);
}

// [self setStringValue:@"Word" forKey:@"print_info_relation"
// [self setStringValue:@"Segment" forKey:@"print_info_relation"

- (void) setStringValue:(NSString*)string forKey:(NSString*)key {
	feat_set_string(feature_config, [key UTF8String], [string UTF8String]);
}

- (void) dealloc {
	if (feature_config != 0) {
		delete_features(feature_config);
		feature_config = 0;
	}
	if (flite_voice_list != 0) {
		delete_val(flite_voice_list);
		flite_voice_list = 0;
	}
	if (asi) {
		delete_audio_streaming_info(asi);
		asi = 0;
	}
	[super dealloc];
}

@end
