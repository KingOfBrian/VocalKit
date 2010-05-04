//
//  VocalKitTestViewController.m
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "VocalKitTestViewController.h"

@implementation VocalKitTestViewController


- (IBAction) recordOrStopPressed:(id)sender {
	if (![vk isListening]) {
		[listenButton setTitle:@"Recognize" forState:UIControlStateNormal];
		[vk startListening];
	} else {
		[listenButton setTitle:@"Listen" forState:UIControlStateNormal];
		[vk stopListening];
		[vk showListened];
		[vk postNotificationOfRecognizedText];
	}

}
- (void)awakeFromNib
{		
	// Allocate our singleton instance for the recorder & player object
	
	OSStatus error = AudioSessionInitialize(NULL, NULL, NULL, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", error);
	else 
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");
		
//		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
//		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", error);
		if (!inputAvailable) {
			NSLog(@"No Input Available!");
		}
			
		
		// we also need to listen to see if input availability changes
//		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
//		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
		
		error = AudioSessionSetActive(true); 
		if (error) printf("AudioSessionSetActive (true) failed");
	}
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
	
	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
}

#pragma mark  Notification updates
- (void) recognizedTextNotification:(NSNotification*)notification {
	NSDictionary *dict = [notification userInfo];

	NSString *phrase = [dict objectForKey:VKRecognizedPhraseNotificationTextKey];
	
	[textView setText:phrase];
	
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	vk = [[VKController alloc] initWithType:VKDecoderTypePocketSphinx 
								 configFile:[[NSBundle mainBundle] pathForResource:@"pocketsphinx" 
																			ofType:@"conf"
																	   inDirectory:@"model"]];
	[vk setConfigString:[[NSBundle mainBundle] pathForResource:@"0407" 
														ofType:@"lm"
												   inDirectory:@"model/lm/raven"] 
				 forKey:@"-lm"];

	[vk setConfigString:[[NSBundle mainBundle] pathForResource:@"0407" 
														ofType:@"dic"
												   inDirectory:@"model/lm/raven"] 
				 forKey:@"-dict"];	
	[vk setConfigString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"model/hmm/wsj1"]
				 forKey:@"-hmm"];	
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(recognizedTextNotification:) 
				name:VKRecognizedPhraseNotification 
			  object:nil];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
