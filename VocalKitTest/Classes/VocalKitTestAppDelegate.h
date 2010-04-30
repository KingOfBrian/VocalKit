//
//  VocalKitTestAppDelegate.h
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VocalKitTestViewController;

@interface VocalKitTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    VocalKitTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet VocalKitTestViewController *viewController;

@end

