//
//  VKAudioQueueConnector.m
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VKAudioQueueConnector.h"

@interface VKAudioQueueConnector(Private)
- (void) setupAudioWithFormat:(UInt32) inFormatID;
- (NSInteger) computeBufferSize:(float) seconds;
@end


static void VKAudioQueueConnectorInputBufferHandler(void *								inUserData,
													AudioQueueRef						inAQ,
													AudioQueueBufferRef					inBuffer,
													const AudioTimeStamp *				inStartTime,
													UInt32								inNumPackets,
													const AudioStreamPacketDescription*	inPacketDesc) {

	OSStatus err;
	VKAudioQueueConnector *connector = (VKAudioQueueConnector*)inUserData;
	if (inNumPackets > 0) {
		[connector setCurrentPacket:[connector currentPacket] + inNumPackets];
			
		[[connector decoder] recievePackets:inNumPackets fromBuffer:inBuffer];
	}
		
	// if we're not stopping, re-enqueue the buffe so that it gets filled again
	if ([connector listening]) {
		err = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
		NSCAssert(!err, @"AudioQueueEnqueueBuffer failed");
	}
}


@implementation VKAudioQueueConnector
@synthesize listening=_listening, decoder=_decoder, currentPacket=_currentPacket;

- (id) initWithDecorder:(id<VKDecoder>)decoder {
	self = [super init];
	if (!self) return nil;
	
	self.listening = NO;
	self.decoder = decoder;

	
	return self;
}

- (AudioQueueRef) AudioQueue {
	return _queue;
}

- (void) setupAudioWithFormat:(UInt32) inFormatID {
	OSStatus err;
	memset(&_streamFormat, 0, sizeof(_streamFormat));
	
	UInt32 size = sizeof(_streamFormat.mSampleRate);
	err = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
								  &size, 
								  &_streamFormat.mSampleRate);
	NSAssert(!err, @"couldn't get hardware sample rate");

	
	size = sizeof(_streamFormat.mChannelsPerFrame);
	err = AudioSessionGetProperty(	kAudioSessionProperty_CurrentHardwareInputNumberChannels, 
										  &size, 
								  &_streamFormat.mChannelsPerFrame);
	NSAssert(!err, @"couldn't get input channel count");
	
	_streamFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM)
	{
		// if we want pcm, default to signed 16-bit little-endian
		_streamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		_streamFormat.mBitsPerChannel = 16;
		_streamFormat.mChannelsPerFrame = 1;
		_streamFormat.mBytesPerPacket = _streamFormat.mBytesPerFrame = (_streamFormat.mBitsPerChannel / 8) * _streamFormat.mChannelsPerFrame;
		_streamFormat.mFramesPerPacket = 1;
		_streamFormat.mSampleRate = 8000;
	}
}

- (NSInteger) computeBufferSize:(float) seconds {
	OSStatus err;
	int packets, frames, bytes = 0;
	frames = (int)ceil(seconds * _streamFormat.mSampleRate);
		
	if (_streamFormat.mBytesPerFrame > 0)
		bytes = frames * _streamFormat.mBytesPerFrame;
	else {
		UInt32 maxPacketSize;
		if (_streamFormat.mBytesPerPacket > 0)
			maxPacketSize = _streamFormat.mBytesPerPacket;	// constant packet size
		else {
			UInt32 propertySize = sizeof(maxPacketSize);
			 err = AudioQueueGetProperty(_queue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
										 &propertySize);
			NSAssert(!err, @"couldn't get queue's maximum output packet size");
		}
		if (_streamFormat.mFramesPerPacket > 0)
			packets = frames / _streamFormat.mFramesPerPacket;
		else
			packets = frames;	// worst-case scenario: 1 frame in a packet
		if (packets == 0)		// sanity check
			packets = 1;
		bytes = packets * maxPacketSize;
	}
	return bytes;
}


- (void) startListening {
	OSStatus err;
	NSInteger i, bufferByteSize;
	UInt32 size;
	
	// specify the recording format
	[self setupAudioWithFormat:kAudioFormatLinearPCM];
		
	// create the queue
	err = AudioQueueNewInput(&_streamFormat,
							 VKAudioQueueConnectorInputBufferHandler,
							 self /* userData */,
							 NULL /* run loop */, NULL /* run loop mode */,
							 0 /* flags */, &_queue);
	NSAssert(!err, @"AudioQueueNewInput failed");
	
	// get the record format back from the queue's audio converter --
	// the file may require a more specific stream description than was necessary to create the encoder.
	size = sizeof(_streamFormat);
	err = AudioQueueGetProperty(_queue, kAudioQueueProperty_StreamDescription,	
								&_streamFormat, &size);
	NSAssert(!err, @"couldn't get queue's format");
	
	
	// allocate and enqueue buffers
	bufferByteSize = [self computeBufferSize:1.0];	// enough bytes for half a second
	
	for (i = 0; i < kNumberRecordBuffers; ++i) {
		err = AudioQueueAllocateBuffer(_queue, bufferByteSize, &_buffers[i]);
		NSAssert(!err, @"couldn't get queue's format");
		err = AudioQueueEnqueueBuffer(_queue, _buffers[i], 0, NULL);
		NSAssert(!err, @"AudioQueueEnqueueBuffer failed");
	}
	// start the queue
	err = AudioQueueStart(_queue, NULL);
	NSAssert(!err, @"AudioQueueStart failed");
	
	self.listening = YES;
}

- (void) stopListening {
	OSStatus err;
	// end recording
	self.listening = NO;
	err = AudioQueueStop(_queue, true);
	NSAssert(!err, @"AudioQueueStop failed");	

	AudioQueueDispose(_queue, true);
}
	



@end
