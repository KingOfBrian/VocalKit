//
//  VKController.h
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKDecoder.h"
@class VKAQRecorder;
@class VKFliteSpeaker;

typedef enum {
	VKDecoderTypePocketSphinx,
	VKDecoderTypeJulius // Unsupported
} VKDecoderType;

typedef enum {
	VKDecoderModeManual,
	VKDecoderModeOnStop,
	VKDecoderModeContinuous // Unsupported
} VKDecoderMode;

extern NSString * const VKRecognizedPhraseNotification;
extern NSString * const VKRecognizedPhraseNotificationTextKey;
extern NSString * const VKRecognizedPhraseNotificationIDKey;
extern NSString * const VKRecognizedPhraseNotificationScoreKey;


@interface VKController : NSObject {
	id<VKDecoder> decoder;
	VKAQRecorder *connector;
	
	VKDecoderType type;
	VKDecoderMode mode;
}
- (id) initWithType:(VKDecoderType)type configFile:(NSString*)configFile;
- (void) setMode:(VKDecoderMode)mode;

- (void) startListening;
- (void) stopListening;
- (BOOL) isListening;
- (void) postNotificationOfRecognizedText;

- (void) setConfigString:(NSString*)str forKey:(NSString*)key;
- (void) setConfigInt:(int)iValue       forKey:(NSString*)key;
- (void) setConfigFloat:(float)fValue   forKey:(NSString*)key;


@end
