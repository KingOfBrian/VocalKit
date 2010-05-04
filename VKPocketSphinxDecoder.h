//
//  VKDecoder.h
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "PocketSphinx.h"


#import "VKDecoder.h"

@interface VKPocketSphinxDecoder : NSObject <VKDecoder> {

	NSString *configFile;
	ps_decoder_t *_ps;

	cmd_ln_t *_config;
}

- (id) initWithConfigFile:(NSString*)config;
- (void) setConfigString:(NSString*)str forKey:(NSString*)key;
- (void) setConfigInt:(int)iValue       forKey:(NSString*)key;
- (void) setConfigFloat:(float)fValue   forKey:(NSString*)key;

@property (nonatomic, copy) NSString* configFile;
- (ps_decoder_t*) ps;
- (cmd_ln_t*) config;

//- (void) reset;
//- (void) recieveAudioFile:(NSString*)filePath;



@end
