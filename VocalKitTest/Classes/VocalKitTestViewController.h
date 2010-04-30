//
//  VocalKitTestViewController.h
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKController.h"

@interface VocalKitTestViewController : UIViewController {
	IBOutlet UITextView *textView;
	IBOutlet UIButton *listenButton;
	VKController *vk;
}

- (IBAction) recordOrStopPressed:(id)sender;

@end

