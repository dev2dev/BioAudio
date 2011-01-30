//
//  BioAudioViewController.m
//  BioAudio
//
//  Created by Brennon Bortz on 28/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import "BioAudioViewController.h"
#import	"BioAudioAppDelegate.h"


@implementation BioAudioViewController

@synthesize freqLabel;
@synthesize gainLabel;
@synthesize freqSlider;
@synthesize gainSlider;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)gainChanged:(id)sender
{
	BioAudioAppDelegate *appDelegate = (BioAudioAppDelegate *) [[UIApplication sharedApplication] delegate];
	UISlider *slider = (UISlider *)sender;
	[appDelegate.bioAudio setGain:(float)slider.value];
	gainLabel.text = [NSString stringWithFormat:@"%f", slider.value];
	NSLog(@"-[BioAudioViewController gainChanged]");
}

- (IBAction)freqChanged:(id)sender
{
	BioAudioAppDelegate *appDelegate = (BioAudioAppDelegate *) [[UIApplication sharedApplication] delegate];
	UISlider *slider = (UISlider *)sender;
	[appDelegate.bioAudio setFreq:(float)slider.value];
	freqLabel.text = [NSString stringWithFormat:@"%f", slider.value];
	NSLog(@"-[BioAudioViewController freqChanged]");
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[freqLabel release];
	freqLabel = nil;
	[gainLabel release];
	gainLabel = nil;
	[freqSlider release];
	freqSlider = nil;
	[gainSlider release];
	gainSlider = nil;
    [super dealloc];
}


@end
