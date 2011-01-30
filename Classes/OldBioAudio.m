//
//  BioAudio.m
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import "BioAudio.h"
#import <stdlib.h>

@interface BioAudio()

- (void)setupAudioSession;
- (void)setupAudio;
- (void)startAudio;

@end

@implementation BioAudio

@synthesize session;
@synthesize sampleRate;
@synthesize rioAUDescription;
@synthesize rioAUInstance;
@synthesize streamDesc;
@synthesize myAUGraph;
@synthesize rioNode;

- (void)setup
{	
	status = noErr;
	
	// Configure audio session.
	[self setupAudioSession];
	
	// Specify Remote I/O Audio Unit	
	// Specify stream format	
	// Create an audio processing graph
	// Setup callback functions and connect to Audio Unit
	[self setupAudio];
	
	// Provide a user interface.
	// Initialize and then start the audio processing graph.
	[self startAudio];
	
	NSLog(@"-[BioAudio setup] -- setup complete");
}

- (void)setupAudioSession
{	
	/* OLD CODE
	 // Set custom error holder for Audio Session setup	
	 NSError *asError = nil;
	 
	 // Initialize singleton Audio Session
	 session = [AVAudioSession sharedInstance];
	 
	 // Set ourself as the delegate
	 session.delegate = self;
	 
	 // Set application sample rate (in Hertz)
	 sampleRate = 44100.0f;
	 
	 // Set preferred sample rate for Audio Session
	 [session setPreferredHardwareSampleRate:sampleRate error:&asError];
	 NSAssert((int *)[asError code] == nil, @"couldn't set preferred sample rate, error code: %d", [asError code]);
	 
	 // Set Audio Session category to allow both playback and recording, and set session as active
	 [session setCategory:AVAudioSessionCategoryPlayAndRecord error: &asError];
	 NSAssert((int *)[asError code] == nil, @"couldn't set audio session category, error code: %d", [asError code]);	
	 [session setActive: YES error:&asError];
	 NSAssert((int *)[asError code] == nil, @"couldn't set audio session as active, error code: %d", [asError code]);
	 */
	
	/*************************************************************************/
	/***  Need to also add interruption handlers and route change handlers ***/
	/*************************************************************************/
	
	/* OLD CODE	
	 // Double-check the sample rate that we negotiated for our Audio Session
	 sampleRate = [session currentHardwareSampleRate];
	 NSAssert(sampleRate == 44100.0f, @"couldn't negotiate 44.1kHz sample rate");
	 */	
	
	OSStatus setupAudioSessionErr = AudioSessionInitialize(NULL,	// Default run loop
														   NULL,	// Default run loop mode									
														   NULL,	// No interruption handler declared
														   NULL);	// This would be data we pass to the interrupt handler, if declared
	NSAssert(setupAudioSessionErr == noErr, @"Couldn't initialize audio session");
	
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord; // Activate PlayAndRecord category (default is play only)
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
							sizeof(sessionCategory),
							&sessionCategory);
	NSAssert (setupAudioSessionErr == noErr, @"Couldn't set audio session property");
	
	sampleRate = 44100.0f;
	size_t f64PropertySize = sizeof(Float64);
	OSStatus setupErr = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
												&f64PropertySize,
												&sampleRate);
	NSAssert(setupErr == noErr, @"Couldn't get current hardware sample rate");
	NSLog(@"current hardware sample rate = %f", sampleRate);
	
	setupErr = AudioSessionSetActive(true);
	NSAssert (setupAudioSessionErr == noErr, @"Couldn't set audio session active");
	
	//	NSLog(@"-[BioAudio setupAudioSession] -- audio session setup complete (sample rate: %f)", sampleRate);
}

static OSStatus playbackCallback(void						*inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp		*inTimeStamp,
								 UInt32						inBusNumber,
								 UInt32						inNumberFrames,
								 AudioBufferList			*ioData)
{
	BioAudio *THIS = (BioAudio *)inRefCon;
	//	AudioBufferList *myPtr = ioData;
	OSStatus err = noErr;
	err = AudioUnitRender(THIS->rioAUInstance, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	
	//	UInt32 numBuffers = ioData->mNumberBuffers;
	
	//	int x;
	//	if (err) NSLog(@"render error");
	
	//	AudioSampleType *sample = (AudioSampleType *)ioData->mBuffers[0].mData;
	//	bzero(bufferList, sizeof(AudioBufferList));
	//	bufferList->mNumberBuffers = 1;
	//	bufferList->mBuffers[0].mNumberChannels = 1;
	//	bufferList->mBuffers[0].mDataByteSize = 4096;
	NSLog(@"Rendering, err: %d", err);
	
	//	if(err != 0) NSLog(@"AudioUnitRender status is %d", err);
	
	
	//	NSLog(@"playbackCallback() -- inTimeStamp: %f, inBusNumber: %d, inNumberFrames: %d", inTimeStamp->mSampleTime, inBusNumber, inNumberFrames);
	
	/*
	 
	 OSStatus renderStatus = AudioUnitRender(THIS->rioAUInstance, 
	 ioActionFlags, 
	 inTimeStamp, 
	 inBusNumber, 
	 inNumberFrames, 
	 bufferList);
	 */	
	//	NSLog(@"rendering -- render status: %d", renderStatus);
	//	NSLog(@"rendering -- bufferList->mNumberBuffers: %d", bufferList->mNumberBuffers);
	//	NSLog(@"rendering -- bufferList->mBuffers[0].mNumberChannels: %d", bufferList->mBuffers[0].mNumberChannels);
	
	//	UInt32 *frameBuffer = ioData->mBuffers[0].mData;
	
	//	 for (int i = 0; i < inNumberFrames; i++) {
	// double toStore = (((double)random() / (pow(2.0, 31.0) - 1) - 0.5) * 0.8);
	//	NSLog(@"calculated toStore: %f", toStore);
	// ioData->mBuffers[0].mData[i] = 0;
	//	NSLog(@"pSamp: %f", *pSamp);
	//	 }
	
	//	NSLog(@"size: %f", sizeof(ioData));
	//	free(bufferList);
	return noErr;
}

OSStatus CopyInputRenderCallback (
								  void *							inRefCon,
								  AudioUnitRenderActionFlags *	ioActionFlags,
								  const AudioTimeStamp *			inTimeStamp,
								  UInt32							inBusNumber,
								  UInt32							inNumberFrames,
								  AudioBufferList *				ioData) {
	
	BioAudio *bioAudio = (BioAudio *)inRefCon;
	AudioUnit rioUnit = bioAudio->rioAUInstance;
	OSStatus renderErr = noErr;
	UInt32 bus1 = 1;
	// just copy samples
	renderErr = AudioUnitRender(rioUnit,
								ioActionFlags,
								inTimeStamp,
								bus1,
								inNumberFrames,
								ioData);
	
	NSLog(@"rendering");
	
	return noErr;
}

- (void)setupAudio
{	
	
	// Create a description first in order to find library for Remote I/O Audio Unit and populate fields accordingly
	
	// Populate Audio Unit Description
	// AudioComponentDescription rioAUDescription;
	
	rioAUDescription.componentType			= kAudioUnitType_Output;
	rioAUDescription.componentSubType		= kAudioUnitSubType_RemoteIO;
	rioAUDescription.componentManufacturer	= kAudioUnitManufacturer_Apple;
	rioAUDescription.componentFlags			= 0;
	rioAUDescription.componentFlagsMask		= 0;
	
	//	int bytesPerSample = sizeof(AudioUnitSampleType);
	
	memset(&streamDesc, 0, sizeof(streamDesc));
	
	streamDesc.mSampleRate			= sampleRate;
	streamDesc.mFormatID			= kAudioFormatLinearPCM;
	//	streamDesc.mFormatFlags			= kAudioFormatFlagsAudioUnitCanonical;
	//	streamDesc.mFormatFlags			= kAudioFormatFlagsCanonical;
	//	streamDesc.mChannelsPerFrame	= 1;
	//	streamDesc.mFramesPerPacket		= 1;
	//	streamDesc.mBitsPerChannel		= 8 * bytesPerSample;
	//	streamDesc.mBytesPerPacket		= bytesPerSample;
	//	streamDesc.mBytesPerFrame		= bytesPerSample;	
	streamDesc.mChannelsPerFrame	= 2;
	streamDesc.mFramesPerPacket		= 1;
	streamDesc.mBitsPerChannel		= 16;
	streamDesc.mBytesPerPacket		= 4;
	streamDesc.mBytesPerFrame		= 4;
	
	// get rio unit from audio component manager
	AudioComponent rioComponent = AudioComponentFindNext(NULL, &rioAUDescription);
	OSStatus setupErr = AudioComponentInstanceNew(rioComponent, &rioAUInstance);
	NSAssert (setupErr == noErr, @"Couldn't get RIO unit instance");
	
	// set up the rio unit for playback
	UInt32 oneFlag = 1;
	AudioUnitElement bus0 = 0;
	setupErr = 
	AudioUnitSetProperty (rioAUInstance,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Output,
						  bus0,
						  &oneFlag,
						  sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"Couldn't enable RIO output");
	
	// enable rio input
	AudioUnitElement bus1 = 1;
	setupErr = AudioUnitSetProperty(rioAUInstance,
									kAudioOutputUnitProperty_EnableIO,
									kAudioUnitScope_Input,
									bus1,
									&oneFlag,
									sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"couldn't enable RIO input");
	
	/*
	 // set format for output (bus 0) on rio's input scope
	 */
	setupErr =
	AudioUnitSetProperty (rioAUInstance,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Input,
						  bus0,
						  &streamDesc,
						  sizeof(streamDesc));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for RIO on input scope / bus 0");
	
	
	// set asbd for mic input
	setupErr =
	AudioUnitSetProperty (rioAUInstance,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Output,
						  bus1,
						  &streamDesc,
						  sizeof(streamDesc));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for RIO on output scope / bus 1");
	
	// set callback method
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = CopyInputRenderCallback; // callback function
	callbackStruct.inputProcRefCon = self;
	
	setupErr = 
	AudioUnitSetProperty(rioAUInstance, 
						 kAudioUnitProperty_SetRenderCallback,
						 kAudioUnitScope_Global,
						 bus0,
						 &callbackStruct,
						 sizeof (callbackStruct));
	NSAssert (setupErr == noErr, @"Couldn't set RIO render callback on bus 0");
	
	
	setupErr =	AudioUnitInitialize(rioAUInstance);
	NSAssert (setupErr == noErr, @"Couldn't initialize RIO unit");
	
	/* Old Code	
	 status = NewAUGraph(&myAUGraph);
	 NSAssert(status == noErr, @"couldn't create a new AU graph");
	 
	 status = AUGraphAddNode(myAUGraph, &rioAUDescription, &rioNode);
	 NSAssert(status == noErr, @"couldn't add graph node to AU graph");
	 
	 status = AUGraphOpen(myAUGraph);
	 NSAssert(status == noErr, @"couldn't open AU graph");
	 
	 status = AUGraphNodeInfo(myAUGraph, rioNode, NULL, &rioAUInstance);
	 NSAssert(status == noErr, @"couldn't set AU graph node info");
	 
	 status = AUGraphConnectNodeInput(myAUGraph, rioNode, 1, rioNode, 0);
	 NSAssert(status == noErr, @"couldn't connect IO node output to IO node input");
	 
	 status = AudioUnitSetProperty(rioAUInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &streamDesc, sizeof(streamDesc));
	 NSAssert(status == noErr, @"couldn't set IO audio unit's output stream format");
	 
	 status = AudioUnitSetProperty(rioAUInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamDesc, sizeof(streamDesc));
	 NSAssert(status == noErr, @"couldn't set IO audio unit's input stream format");
	 
	 UInt32 enableInput = 1;
	 
	 status = AudioUnitSetProperty(rioAUInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableInput, sizeof(enableInput));
	 NSAssert(status == noErr, @"couldn't enable input on the IO audio unit");
	 
	 UInt32 enableInPlaceProc = 1;
	 status = AudioUnitSetProperty(rioAUInstance, kAudioUnitProperty_InPlaceProcessing, kAudioUnitScope_Global, 0, &enableInPlaceProc, sizeof(enableInPlaceProc));
	 
	 UInt32 shouldAllocBuffer = 1;
	 status = AudioUnitSetProperty(rioAUInstance, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, 0, &shouldAllocBuffer, sizeof(shouldAllocBuffer));	
	 
	 // Set output callback	
	 AURenderCallbackStruct callbackStruct;
	 callbackStruct.inputProc = playbackCallback;
	 callbackStruct.inputProcRefCon = self;
	 
	 status = AudioUnitSetProperty(rioAUInstance, 
	 kAudioUnitProperty_SetRenderCallback, 
	 kAudioUnitScope_Global,
	 0,
	 &callbackStruct, 
	 sizeof(callbackStruct));
	 
	 NSAssert(status == noErr, @"couldn't attach callback function");
	 */	
	
	
	NSLog(@"-[BioAudio setupAudio] -- audio setup complete");
}

- (void)startAudio
{
	/* Old Code
	 status = AUGraphInitialize(myAUGraph);
	 NSAssert(status == noErr, @"couldn't initialise AU graph");
	 
	 status = AUGraphStart(myAUGraph);
	 NSAssert(status == noErr, @"couldn't start AU graph");
	 NSLog(@"-[BioAudio startAudio] -- graph initalised and started");
	 */
}

- (void)dealloc
{
	// THIS NEEDS TO MOVE //
	AUGraphStop(myAUGraph);
	
	[session release];
	[super dealloc];
}
@end
