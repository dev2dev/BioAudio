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

@synthesize startAudioButton;
@synthesize stopAudioButton;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.stopAudioButton.enabled = NO;
	self.startAudioButton.enabled = YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)didPressLink
{
	DBLoginController* controller = [[DBLoginController new] autorelease];
	[controller presentFromController:self];
}

- (IBAction)didPressPostFile
{
	BioAudioAppDelegate *appDelegate = (BioAudioAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate postFile];
	NSLog(@"-[BioAudioViewController postFile]");
}

- (IBAction)startAudio
{
	BioAudioAppDelegate *appDelegate = (BioAudioAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.bioAudio startAudio];
	self.startAudioButton.enabled = NO;
	self.stopAudioButton.enabled = YES;
	NSLog(@"-[BioAudioViewController startAudio]");
}

- (IBAction)stopAudio
{
	BioAudioAppDelegate *appDelegate = (BioAudioAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.bioAudio stopAudio];
	self.stopAudioButton.enabled = NO;
	self.startAudioButton.enabled = YES;
	NSLog(@"-[BioAudioViewController stopAudio]");
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

- (void)viewWillAppear:(BOOL)animated
{
	// to fix the controller showing under the status bar
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
}

- (void)dealloc {
	[self.stopAudioButton release];
	self.stopAudioButton = nil;
	[self.startAudioButton release];
	self.startAudioButton = nil;
    [super dealloc];
}


@end
