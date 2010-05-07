//
//  VocalKitTestViewController.h
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKController.h"
//#import "VKFliteSpeaker.h"
#import <AVFoundation/AVFoundation.h>


@interface VocalKitTestViewController : UIViewController {
	IBOutlet UITextView *textView;

	IBOutlet UIButton *listenButton;
	IBOutlet UIButton *speakButton;
	VKController *vk;
	VKFliteSpeaker *vkSpeaker;
	
	AVAudioPlayer *audioPlayer;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

- (IBAction) recordOrStopPressed:(id)sender;
- (IBAction) speakPressed:(id)sender;

@end

