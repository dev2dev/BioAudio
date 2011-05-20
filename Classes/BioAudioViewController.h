//
//  BioAudioViewController.h
//  BioAudio
//
//  Created by Brennon Bortz on 28/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@interface BioAudioViewController : UIViewController {
	IBOutlet UIButton *startAudioButton;
	IBOutlet UIButton *stopAudioButton;
    
    IBOutlet GraphView *graphView;
}

- (IBAction)didPressLink;
- (IBAction)didPressPostFile;
- (IBAction)startAudio;
- (IBAction)stopAudio;

@property (retain) IBOutlet UIButton *startAudioButton;
@property (retain) IBOutlet UIButton *stopAudioButton;
@property (retain) IBOutlet GraphView *graphView;

@end
