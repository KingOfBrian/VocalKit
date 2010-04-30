//
//  VKAudioQueueConnector.h
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#import "VKDecoder.h"


#define kNumberRecordBuffers	3


@interface VKAudioQueueConnector : NSObject {
	
	id<VKDecoder> _decoder;

	AudioQueueRef				_queue;
	AudioQueueBufferRef			_buffers[kNumberRecordBuffers];
	NSUInteger					_currentPacket;
	AudioStreamBasicDescription	_streamFormat;
	BOOL						_listening;
}

- (AudioQueueRef) AudioQueue;

- (id) initWithDecorder:(id<VKDecoder>)decoder;
- (void) startListening;
- (void) stopListening;

@property (retain, nonatomic) id<VKDecoder> decoder;
@property (assign, nonatomic) BOOL listening;
@property (assign, nonatomic) NSUInteger currentPacket;

@end
