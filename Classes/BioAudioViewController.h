//
//  BioAudioViewController.h
//  BioAudio
//
//  Created by Brennon Bortz on 28/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BioAudioViewController : UIViewController {
	IBOutlet UILabel *freqLabel;
	IBOutlet UILabel *gainLabel;
	IBOutlet UISlider *freqSlider;
	IBOutlet UISlider *gainSlider;
}

- (IBAction)freqChanged:(id)sender;
- (IBAction)gainChanged:(id)sender;

@property (retain) IBOutlet UILabel *freqLabel;
@property (retain) IBOutlet UILabel *gainLabel;
@property (retain) IBOutlet UISlider *freqSlider;
@property (retain) IBOutlet UISlider *gainSlider;

@end
