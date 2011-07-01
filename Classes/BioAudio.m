//
//  BioAudio.m
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import "BioAudio.h"
// #import <lo/lo.h>
#import "DemodCoefs.h"

//#include <float.h>

@implementation BioAudio

@synthesize remoteIOUnit;

#pragma mark init/dealloc
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */
- (void)dealloc {
    [super dealloc];
}

#pragma mark Setup Audio Session
- (void)setUpAudioSession
{

	// Initialise Audio Session
	OSStatus setUpAudioSessionErr = AudioSessionInitialize(NULL, // default run loop
                                                           NULL, // default run loop mode
                                                           nil, // interruption callback
                                                           self); // client callback data

	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't initialize audio session");
	
	// Set Audio Session to Play and Record
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	setUpAudioSessionErr = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
													sizeof (sessionCategory),
													&sessionCategory);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't set audio session property");
    
    // Set Audio Session Sample Rate
	Float64 sessionSampleRate = 11025.0;
	setUpAudioSessionErr = AudioSessionSetProperty (kAudioSessionProperty_PreferredHardwareSampleRate,
													sizeof (sessionSampleRate),
													&sessionSampleRate);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't set audio session sample rate");
    
	// Check Audio Session sample rate
	UInt32 f64PropertySize = sizeof (Float64);
	setUpAudioSessionErr = AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareSampleRate,
													&f64PropertySize,
													&hardwareSampleRate);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't get current hardware sample rate");
	NSLog (@"-[BioAudio setUpAudioSession] -- Current hardware sample rate = %f", hardwareSampleRate);
    
    NSString *srMessage = [NSString stringWithFormat:@"Sample rate: %6f", hardwareSampleRate];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sample Rate" 
                                                    message:srMessage 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
	
	// Check for audio input
	UInt32 ui32PropertySize = sizeof (UInt32);
	UInt32 inputAvailable;
	setUpAudioSessionErr = AudioSessionGetProperty (kAudioSessionProperty_AudioInputAvailable,
													&ui32PropertySize,
													&inputAvailable);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't get current audio input available prop");

	if (!inputAvailable) {
		UIAlertView *noInputAlert =
		[[UIAlertView alloc] initWithTitle:@"No audio input"
								   message:@"No audio input device is currently attached.  This program will not run correctly."
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[noInputAlert show];
		[noInputAlert release];
	}
	

	// I thought this would override the audio route so that I could use headphones for input and speaker for output
	// UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	// size_t aroSize = sizeof(audioRouteOverride);
	// setUpAudioSessionErr = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, aroSize, &audioRouteOverride);
	

	// Listen for changes in mic status
	// setupErr = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, MyInputAvailableListener, self);
	// NSAssert (setupAudioSessionErr == noErr, @"Couldn't setup audio input available prop listener");

	
	// Set Audio Session as active
	setUpAudioSessionErr = AudioSessionSetActive(true);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't set audio session as active");
	NSLog(@"-[BioAudio setUpAudioSession] -- Audio Session active");	
}

#pragma mark Remote I/O Callback Setup
OSStatus CopyInputRenderCallback (void *							inRefCon,
								  AudioUnitRenderActionFlags *		ioActionFlags,
								  const AudioTimeStamp *			inTimeStamp,
								  UInt32							inBusNumber,
								  UInt32							inNumberFrames,
								  AudioBufferList *					ioData) {
	
	EffectState *effectState = (EffectState *)inRefCon;
	AudioUnit rioUnit = effectState->rioUnit;
	OSStatus renderErr = noErr;
	UInt32 bus1 = 1;

	// Ask Remote I/O unit to render samples into ioData buffer
	renderErr = AudioUnitRender(rioUnit,
								ioActionFlags,
								inTimeStamp,
								bus1,
								inNumberFrames,
								ioData);
	
	// Process each frame
	AudioSampleType sample = 0.0f;
	AudioBuffer buf = ioData->mBuffers[0];
	int currentFrame = 0;
	while (currentFrame < inNumberFrames) {		
		// Copy from incoming buffer to a local buffer
		// (We're only concerned with first channel right now)
		memcpy(&sample, buf.mData + (currentFrame * 4), sizeof(AudioSampleType));
            
        // Uncomment for real input
        double scaledSample = (double) sample / 32768.0;
        //double scaledSample = 1.0;
        
        // Generate two sine waves, one at 100Hz, one at 200Hz
        // double modSignal1 = sin(effectState->test1Phase);// * 0.2 + 0.5;
        // double modSignal2 = sin(effectState->test2Phase);// * 0.2 + 0.5;
        
//        double modSignal1 = 0.01;
//        double modSignal2 = 0.9;
//        double testSignal = (modSignal1 * sin(effectState->ch1Phase)) + (modSignal2 * sin(effectState->ch2Phase));

        double scaledSignal1 = scaledSample * sin(effectState->ch1Phase);
        double scaledSignal2 = scaledSample * sin(effectState->ch2Phase);
        
        // Uncomment for real input
        // double scaledSignal1 = sin(effectState->ch1Phase) * scaledSample;
        // double scaledSignal2 = sin(effectState->ch2Phase) * scaledSample;        
        
        effectState->ch1Phase += effectState->ch1PhaseIncrement;
        effectState->ch2Phase += effectState->ch2PhaseIncrement;            
        
        if (effectState->ch1Phase >= (2 * M_PI * 100.0F)) {
            effectState->ch1Phase = effectState->ch1Phase - (2 * M_PI * 100.0F);
        }
        
        if (effectState->ch2Phase >= (2 * M_PI * 200.0F)) {
            effectState->ch2Phase = effectState->ch2Phase - (2 * M_PI * 200.0F);
        }

/*        
        effectState->test1Phase += effectState->test1PhaseIncrement;
        effectState->test2Phase += effectState->test2PhaseIncrement;
        
        if (effectState->test1Phase >= (2 * M_PI * 1.3F)) {
            effectState->test1Phase = effectState->test1Phase - (2 * M_PI * 1.3F);
        }
        
        if (effectState->test2Phase >= (2 * M_PI * 9.2F)) {
            effectState->test2Phase = effectState->test2Phase - (2 * M_PI * 9.2F);
        }
*/
        // End sine wave multiplication            

        // Inefficient filter!?
        // Shuffle input history array
        for (int j=(b_length-1); j > 0; j--) {
            effectState->dmFilter1.zx[j] = effectState->dmFilter1.zx[j-1];
            effectState->dmFilter2.zx[j] = effectState->dmFilter2.zx[j-1];
        }
        
        // Store input in input history array
        effectState->dmFilter1.zx[0] = scaledSignal1;
        effectState->dmFilter2.zx[0] = scaledSignal2;
        
        double accumulator1 = 0.0;
        double accumulator2 = 0.0;
        
        // Multiply and sum
        for (int j=0; j < b_length; j++) {
            accumulator1 += effectState->dmFilter1.zx[j] * b[j];
            accumulator2 += effectState->dmFilter2.zx[j] * b[j];
        }
        
        // effectState->currentValues[0] = accumulator1;
        // effectState->currentValues[1] = accumulator2;

        
        AudioSampleType ch1Signal = (AudioSampleType) (accumulator1 * 32767);
        AudioSampleType ch2Signal = (AudioSampleType) (accumulator2 * 32767);
        
//        double ch1Signal = (AudioSampleType) (scaledSignal1 * 32767.5 - 0.5);
//        double ch2Signal = (AudioSampleType) (scaledSignal2 * 32767.5 - 0.5);
        
//        memcpy(buf.mData + (currentFrame * 4), &ch1Signal, sizeof(AudioSampleType));
//        memcpy(buf.mData + (currentFrame * 4) + 2, &ch2Signal, sizeof(AudioSampleType));
        
//        AudioSampleType s16IntSignal1 = (AudioSampleType) (scaledSignal1 * 32767);
//        AudioSampleType s16IntSignal2 = (AudioSampleType) (scaledSignal2 * 32767);    

        // memcpy(buf.mData + (currentFrame * 4), &ch1Signal, sizeof(AudioSampleType));
        // memcpy(buf.mData + (currentFrame * 4) + 2, &ch2Signal, sizeof(AudioSampleType));
        
        memcpy(buf.mData + (currentFrame * 4), &sample, sizeof(AudioSampleType));
        memcpy(buf.mData + (currentFrame * 4) + 2, &sample, sizeof(AudioSampleType));

		currentFrame++;
	}
	
	ExtAudioFileWriteAsync(effectState->audioFileRef, inNumberFrames, ioData);

	return noErr;
}

#pragma mark direct RIO use

- (void)setUpAUConnectionsWithRenderCallback {
	OSStatus setupErr = noErr;
	
	// describe unit
	AudioComponentDescription audioCompDesc;
	audioCompDesc.componentType			= kAudioUnitType_Output;
	audioCompDesc.componentSubType		= kAudioUnitSubType_RemoteIO;
	audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
	audioCompDesc.componentFlags		= 0;
	audioCompDesc.componentFlagsMask	= 0;
	
	// get rio unit from audio component manager
	AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
	setupErr = AudioComponentInstanceNew(rioComponent, &remoteIOUnit);
	NSAssert (setupErr == noErr, @"Couldn't get Remote I/O unit instance");
	

	// set up the rio unit for playback
	UInt32 oneFlag = 1;
	AudioUnitElement bus0 = 0;
	setupErr = 
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Output,
						  bus0,
						  &oneFlag,
						  sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"Couldn't enable Remote I/O output");
	
	// enable rio input
	AudioUnitElement bus1 = 1;
	setupErr = AudioUnitSetProperty(remoteIOUnit,
									kAudioOutputUnitProperty_EnableIO,
									kAudioUnitScope_Input,
									bus1,
									&oneFlag,
									sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"Couldn't enable Remote I/O input");
	
	// setup an asbd in the iphone canonical format
	AudioStreamBasicDescription myASBD;
	memset (&myASBD, 0, sizeof (myASBD));
	myASBD.mSampleRate = hardwareSampleRate;
	myASBD.mFormatID = kAudioFormatLinearPCM;
	myASBD.mFormatFlags = kAudioFormatFlagsCanonical;
	myASBD.mBytesPerPacket = 4;
	myASBD.mFramesPerPacket = 1;
	myASBD.mBytesPerFrame = 4;
	myASBD.mChannelsPerFrame = 2;
	myASBD.mBitsPerChannel = 16;
	
	// set format for output (bus 0) on rio's input scope
	setupErr =
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Input,
						  bus0,
						  &myASBD,
						  sizeof (myASBD));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for Remote I/O on input scope / bus 0");
	
	// set asbd for mic input
	setupErr =
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Output,
						  bus1,
						  &myASBD,
						  sizeof (myASBD));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for Remote I/O on output scope / bus 1");
	
	// set up callback state object
	effectState.rioUnit = remoteIOUnit;
	
	effectState.asbd = myASBD;
	
	// set callback method
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = CopyInputRenderCallback; // callback function
	callbackStruct.inputProcRefCon = &effectState;
	
	setupErr = 
	AudioUnitSetProperty(remoteIOUnit, 
						 kAudioUnitProperty_SetRenderCallback,
						 kAudioUnitScope_Global,
						 bus0,
						 &callbackStruct,
						 sizeof (callbackStruct));
	NSAssert (setupErr == noErr, @"Couldn't set Remote I/O render callback on bus 0");
	
	setupErr =	AudioUnitInitialize(remoteIOUnit);
	NSAssert (setupErr == noErr, @"Couldn't initialize Remote I/O unit");
}

- (void)setup {
	[self setUpAudioSession];
	[self setUpAUConnectionsWithRenderCallback];
	
	memset(&effectState.dmFilter1.zx, 0, sizeof(effectState.dmFilter1.zx));
	memset(&effectState.dmFilter2.zx, 0, sizeof(effectState.dmFilter2.zx));
    memset(&effectState.currentValues, 0, sizeof(effectState.currentValues));
	
	effectState.ch1Phase = 0.0F;
	effectState.ch2Phase = 0.0F;
    effectState.test1Phase = 0.0F;
    effectState.test2Phase = 0.0F;
	
	effectState.ch1PhaseIncrement = (2 * M_PI * 100.0F) / hardwareSampleRate;
	effectState.ch2PhaseIncrement = (2 * M_PI * 200.0F) / hardwareSampleRate;
	effectState.test1PhaseIncrement = (2 * M_PI * 1.3F) / hardwareSampleRate;
    effectState.test2PhaseIncrement = (2 * M_PI * 2.2F) / hardwareSampleRate;
	
	NSLog(@"-[BioAudio setup] -- filter array setup complete");

	effectState.dmFilter1.taps = b_length;
	effectState.dmFilter2.taps = b_length;
	effectState.sampleCounter = 0;
}

- (void)setupOutputFile
{
	// Setup output file
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *destinationFilePath = [[[NSString alloc] initWithFormat: @"%@/output.caf", documentsDirectory] autorelease];
	CFURLRef destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
	
	NSLog(@"-[setUpAUConnectionsWithRenderCallback] -- output path selected: %@", (NSString *)destinationURL);
	
	AudioStreamBasicDescription myOutASBD = {0};
    myOutASBD.mSampleRate = hardwareSampleRate;
	myOutASBD.mBitsPerChannel = 16;
	myOutASBD.mChannelsPerFrame = 2;
	myOutASBD.mBytesPerFrame = 4;
	myOutASBD.mFramesPerPacket = 1;
	myOutASBD.mBytesPerPacket = 4;
	myOutASBD.mFormatID = kAudioFormatLinearPCM;
	myOutASBD.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
	
	// WHY CAN'T I USE kAudioFileAIFFType?
	OSStatus setupErr = ExtAudioFileCreateWithURL(destinationURL, kAudioFileCAFType, &myOutASBD, NULL, kAudioFileFlags_EraseFile, &effectState.audioFileRef);	
	CFRelease(destinationURL);
	NSAssert(setupErr == noErr, @"Couldn't create file for writing");
	
	setupErr =  ExtAudioFileWriteAsync(effectState.audioFileRef, 0, NULL);
	NSAssert(setupErr == noErr, @"Couldn't initialize write buffers for audio file");
}

- (void)startAudio
{
	NSLog(@"-[BioAudio startAudio]");
	OSStatus startErr = noErr;

	startErr = AudioOutputUnitStart (remoteIOUnit);
	NSAssert (startErr == noErr, @"Couldn't start Remote I/O unit");
	
	[self setupOutputFile];
	
	NSLog (@"-[BioAudio startAudio] -- started Remote I/O unit");
}

- (void)stopAudio
{
	NSLog(@"-[BioAudio stopAudio]");
	OSStatus stopErr = noErr;
	stopErr = AudioOutputUnitStop (remoteIOUnit);
	
	NSAssert (stopErr == noErr, @"Couldn't stop Remote I/O unit");
	
	NSLog (@"-[BioAudio stopAudio] -- stopped Remote I/O unit");
	
	OSStatus writeErr = ExtAudioFileDispose(effectState.audioFileRef);
	NSLog(@"writeErr status: %ld", writeErr);
}

@end