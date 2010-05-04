//
//  VKDecoder.h
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol VKDecoder <NSObject>

- (void) gramarStates:(NSDictionary*)states transitions:(NSDictionary*)transitions named:(NSString*)name;
- (void) startDecode;
- (void) recievePackets:(UInt32)packetCount fromBuffer:(AudioQueueBufferRef)buffer;
- (void) stopDecode;
- (void) printDebug;
- (void) postNotificationOfRecognizedText;

@end
