//
//  BioAudioAppDelegate.h
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif

#import <UIKit/UIKit.h>
#import "BioAudio.h"
#import "BioAudioViewController.h"

@interface BioAudioAppDelegate : NSObject <UIApplicationDelegate> {
	BioAudio	*bioAudio;
    UIWindow	*window;
	BioAudioViewController *baViewController;
}

@property (nonatomic, retain) IBOutlet	UIWindow	*window;
@property (retain)						BioAudio	*bioAudio;
@property (retain) BioAudioViewController *baViewController;

@end

