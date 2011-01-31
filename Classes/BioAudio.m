//
//  BioAudio.m
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import "BioAudio.h"
#import <lo/lo.h>

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
	OSStatus setUpAudioSessionErr=
	AudioSessionInitialize (
							NULL, // default run loop
							NULL, // default run loop mode
							// MyInterruptionHandler, // interruption callback
							nil, // interruption callback
							self); // client callback data
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't initialize audio session");
	
	// Set Audio Session to Play and Record
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	setUpAudioSessionErr = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
													sizeof (sessionCategory),
													&sessionCategory);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't set audio session property");
	
	// Check Audio Session sample rate
	UInt32 f64PropertySize = sizeof (Float64);
	setUpAudioSessionErr = AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareSampleRate,
													&f64PropertySize,
													&hardwareSampleRate);
	NSAssert (setUpAudioSessionErr == noErr, @"Couldn't get current hardware sample rate");
	NSLog (@"-[BioAudio setUpAudioSession] -- Current hardware sample rate = %f", hardwareSampleRate);
	
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
	
	/*
	// I thought this would override the audio route...
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	size_t aroSize = sizeof(audioRouteOverride);
	setUpAudioSessionErr = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, aroSize, &audioRouteOverride);
	*/
	/*
	 // listen for changes in mic status
	 setupErr = AudioSessionAddPropertyListener (
	 kAudioSessionProperty_AudioInputAvailable,
	 MyInputAvailableListener,
	 self);
	 NSAssert (setupAudioSessionErr == noErr, @"Couldn't setup audio input available prop listener");
	 */
	
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
	
	
	NSLog(@"CopyInputRenderCallback(), error: %d", renderErr);
	// Step through each sample
	AudioSampleType sample = 0;
	double doubleSample = 0.0F;
	AudioBuffer buf = ioData->mBuffers[0];
	int currentFrame = 0;
	while (currentFrame < inNumberFrames) {		
		// copy sample to buffer -- only concerned with first channel right now
		memcpy(&sample, buf.mData + (currentFrame * 10), sizeof(AudioSampleType));
/*
		// Threshold each sample to +/- 32767
		if (sample > 0) {
			doubleSample = 1.0F;
		} else {
			doubleSample = 0.0F;
		}

		// Lowpass filter
		lpFilter lp1 = effectState->lpFilter1;			
		*lp1.z = sample;
		double accumulator = 0.0F;
		double *py = &accumulator;
		double *ph = lp1.hx; // lp1.hx[0]
		double *pz = lp1.z;  // lp1.z[0]
		
		for (int i = 0; i < lp1.taps; i++) {
			*py += (*ph++ * *pz++);
		}
		
		pz = &lp1.z[lp1.taps-1];
		for (int i = 0; i < (lp1.taps-1); i++) {
			*pz = *(pz - 1);
			pz--;
		}
*/		
/*		
		// Multiply by sine waves each signal by sine wave

		double ch1Signal, ch2Signal;
		
		ch1Signal = sin(effectState->ch1Phase) * *pz;
		ch2Signal = sin(effectState->ch2Phase) * *pz;
		
		effectState->ch1Phase += effectState->ch1PhaseIncrement;
		effectState->ch2Phase += effectState->ch2PhaseIncrement;
		
		if (effectState->ch1Phase >= M_PI * 5.0F) {
			effectState->ch1Phase = effectState->ch1Phase - M_PI * 5.0F;
		}
		
		if (effectState->ch2Phase >= M_PI * 5.0F) {
			effectState->ch2Phase = effectState->ch2Phase - M_PI * 5.0F;
		}
		
		// Original IIR Filter
		demodFilter df1 = effectState->dmFilter1;
		df1.zx[0] = ch1Signal;
		double df1Accum = 0.0F;
		
		for (int i = 0; i < (df1.taps / 2); i++) {
			df1Accum += (df1.hx[i] * df1.zx[i]) + (df1.hy[i] * df1.zy[i]);
		}
		
		for (int j = ((df1.taps / 2) - 1); j >= 1; j--) {
			df1.zx[j] = df1.zx[j-1];
			df1.zy[j] = df1.zy[j-1];
		}
		
		demodFilter df2 = effectState->dmFilter2;
		df2.zx[0] = ch2Signal;
		double df2Accum = 0.0F;
		
		for (int i = 0; i < (df2.taps / 2); i++) {
			df2Accum += (df2.hx[i] * df2.zx[i]) + (df2.hy[i] * df2.zy[i]);
		}
		
		for (int j = ((df2.taps / 2) - 1); j >= 1; j--) {
			df2.zx[j] = df2.zx[j-1];
			df2.zy[j] = df2.zy[j-1];
		}
*/
/*		
		*df1.zx = ch1Signal;
		double dfAccum1 = 0.0F;
		double *pdfAccum1 = &dfAccum1;
		double *phx1 = df1.hx;
		double *phy1 = df1.hy;
		double *pzx1 = df1.zx;
		double *pzy1 = df1.zy;
		
		for (int i = 0; i < df1.taps; i++) {
			*pdfAccum1 += ((*phx1++ * *pzx1++) + (*phy1++ * *pzy1++));
		}

		pzx1 = &df1.zx[(df1.taps/2)-1];
		pzy1 = &df1.zy[(df1.taps/2)-1];
		
		for (int j = ((df1.taps/2)-1); j > 1; j--) {
			*pzx1 = *(pzx1 - 1);
			*pzy1 = *(pzy1 - 1);
			pzx1--;
			pzy1--;
		}
*/
/*
		*df2.zx = ch2Signal;
		double accum2 = 0.0F;
		double *paccum2 = &accum2;
		double *phx2 = df2.hx;
		double *phy2 = df2.hy;
		double *pzx2 = df2.zx;
		double *pzy2 = df2.zy;
		
		for (int i = 0; i < df2.taps; i++) {
			*paccum2 += ((*phx2++ * *pzx2++) + (*phy2++ * *pzy2++));
		}
		
		pzx2 = &df1.zx[df2.taps-1];
		pzy2 = &df1.zy[df2.taps-1];
		for (int i = 0; i < (df2.taps-1); i++) {
			*pzx2 = *(pzx2 - 1);
			*pzy2 = *(pzy2 - 1);
			pzx2--;
			pzy2--;
		}
*/
//		NSLog(@"%4.4f\t\t\t\t\t%4.4f", df1Accum, df2Accum);
//		AudioSampleType ch1Out = (SInt16)(accumulator * 32767.0F);
//		AudioSampleType ch2Out = (SInt16)(df2Accum * 32767.0F);
				
//		lo_send(effectState->outAddress, "", "i", ch1Out);
		
		memcpy(buf.mData + (currentFrame * 10), &sample, sizeof(AudioSampleType));
		memcpy(buf.mData + (currentFrame * 10) + 2, &sample, sizeof(AudioSampleType));

		currentFrame++;
	}	

	return noErr;
}

OSStatus OutputRenderCallback (void *							inRefCon,
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
	
	/*
	// Step through each sample
	AudioSampleType sample = 0;
	double doubleSample = 0.0F;
	AudioBuffer buf = ioData->mBuffers[0];
	int currentFrame = 0;
	while (currentFrame < inNumberFrames) {		
		// copy sample to buffer -- only concerned with first channel right now
		memcpy(&sample, buf.mData + (currentFrame * 10), sizeof(AudioSampleType));
		
		
		//		memcpy(buf.mData + (currentFrame * 10), &ch1Out, sizeof(AudioSampleType));
		//		memcpy(buf.mData + (currentFrame * 10) + 2, &ch1Out, sizeof(AudioSampleType));
		
		currentFrame++;
	}	
	*/
//	NSLog(@"OutputRenderCallback(), error: %d", renderErr);
	
	return noErr;
}

#pragma mark direct RIO use

- (void) setUpAUConnectionsWithRenderCallback {
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
	myASBD.mBytesPerPacket = 10;
	myASBD.mFramesPerPacket = 1;
	myASBD.mBytesPerFrame = 10;
	myASBD.mChannelsPerFrame = 5;
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
						 bus1,
						 &callbackStruct,
						 sizeof (callbackStruct));
	NSAssert (setupErr == noErr, @"Couldn't set Remote I/O render callback on bus 0");

	/*
	// set callback method
	AURenderCallbackStruct outputCallbackStruct;
	outputCallbackStruct.inputProc = OutputRenderCallback; // callback function
	outputCallbackStruct.inputProcRefCon = &effectState;
	
	setupErr = 
	AudioUnitSetProperty(remoteIOUnit, 
						 kAudioUnitProperty_SetRenderCallback,
						 kAudioUnitScope_Global,
						 bus0,
						 &outputCallbackStruct,
						 sizeof (outputCallbackStruct));
	NSAssert (setupErr == noErr, @"Couldn't set Remote I/O render callback on bus 0");
	*/
	
	setupErr =	AudioUnitInitialize(remoteIOUnit);
	NSAssert (setupErr == noErr, @"Couldn't initialize Remote I/O unit");
	
}

- (void)setup {
	[self setUpAudioSession];
	[self setUpAUConnectionsWithRenderCallback];
	
	effectState.outAddress = lo_address_new_with_proto(LO_UDP, "192.168.1.64", "7400");
	
	memset(&effectState.lpFilter1.hx, 0, sizeof(effectState.lpFilter1.hx));
	memset(&effectState.lpFilter1.z, 0, sizeof(effectState.lpFilter1.z));
	memset(&effectState.dmFilter1.hx, 0, sizeof(effectState.dmFilter1.hx));
	memset(&effectState.dmFilter1.hy, 0, sizeof(effectState.dmFilter1.hy));
	memset(&effectState.dmFilter1.zx, 0, sizeof(effectState.dmFilter1.zx));
	memset(&effectState.dmFilter1.zy, 0, sizeof(effectState.dmFilter1.zy));
	memset(&effectState.dmFilter2.hx, 0, sizeof(effectState.dmFilter2.hx));
	memset(&effectState.dmFilter2.hy, 0, sizeof(effectState.dmFilter2.hy));
	memset(&effectState.dmFilter2.zx, 0, sizeof(effectState.dmFilter2.zx));
	memset(&effectState.dmFilter2.zy, 0, sizeof(effectState.dmFilter2.zy));
	
	effectState.ch1Phase = 0.0F;
	effectState.ch2Phase = 0.0F;
	
	effectState.ch1PhaseIncrement = M_PI * 100.0F / 44100.0F;
	effectState.ch2PhaseIncrement = M_PI * 200.0F / 44100.0F;
	
	double lpCoefficients[LOWPASS_TAPS] = {0.0028548015164474388,
										   0.008339098493990775,
										   0.018367090858364413,
										   0.033362668606975288,
										   0.052699519977760734,
										   0.074392863200141129,
										   0.095346036856686883,
										   0.11199999847179988,
										   0.12123645840583636,
										   0.12123645840583636,
										   0.11199999847179988,
										   0.095346036856686883,
										   0.074392863200141129,
										   0.052699519977760734,
										   0.033362668606975288,
										   0.018367090858364413,
										   0.008339098493990775,
										   0.0028548015164474388};
	
	double demodXCoefficients[DEMOD_X_TAPS] = {0.00000000000001147700223897546,
											   0.000000000000057385011194877299,
											   0.0000000000001147700223897546,
											   0.0000000000001147700223897546,
											   0.000000000000057385011194877299,
											   0.00000000000001147700223897546};
	
	double demodYCoefficients[DEMOD_Y_TAPS] = {1.0,
											   -4.9894446826387089,
											   9.9578344164698258,
											   -9.9368349720987279,
											   4.9579454257081013,
											   -0.98950018744012291};
	
	for (int i = 0; i < LOWPASS_TAPS; i++) {
		effectState.lpFilter1.hx[i] = lpCoefficients[i];
	}
	
	for (int i = 0; i < DEMOD_X_TAPS; i++) {
		effectState.dmFilter1.hx[i] = demodXCoefficients[i];
		effectState.dmFilter2.hx[i] = demodXCoefficients[i];
	}
	
	for (int i = 0; i < DEMOD_Y_TAPS; i++) {
		effectState.dmFilter1.hy[i] = demodYCoefficients[i];
		effectState.dmFilter2.hy[i] = demodYCoefficients[i];
	}
	
	NSLog(@"-[BioAudio setup] -- filter array setup complete");

	effectState.lpFilter1.state = 0;
	effectState.lpFilter1.taps = LOWPASS_TAPS;
	effectState.dmFilter1.state = 0;
	effectState.dmFilter1.taps = DEMOD_X_TAPS + DEMOD_Y_TAPS;
	effectState.dmFilter2.state = 0;
	effectState.dmFilter2.taps = DEMOD_X_TAPS + DEMOD_Y_TAPS;
}

- (void)startAudio
{
	NSLog(@"-[BioAudio startAudio]");
	OSStatus startErr = noErr;
	startErr = AudioOutputUnitStart (remoteIOUnit);
	
	NSAssert (startErr == noErr, @"Couldn't start Remote I/O unit");
	
	NSLog (@"-[BioAudio startAudio] -- started Remote I/O unit");
}

- (void)stopAudio
{
	NSLog(@"-[BioAudio stopAudio]");
	OSStatus stopErr = noErr;
	stopErr = AudioOutputUnitStop (remoteIOUnit);
	
	NSAssert (stopErr == noErr, @"Couldn't stop Remote I/O unit");
	
	NSLog (@"-[BioAudio stopAudio] -- stopped Remote I/O unit");
}

@end