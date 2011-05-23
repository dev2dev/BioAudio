//
//  BioAudio.h
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
// #import <lo/lo.h>

#define DEMOD_X_TAPS 84

typedef struct {
	double zx[DEMOD_X_TAPS];
	int taps;
} demodFilter;

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
	demodFilter dmFilter1;
	demodFilter dmFilter2;
	double ch1PhaseIncrement;
	double ch2PhaseIncrement;
	double ch1Phase;
	double ch2Phase;
    double test1PhaseIncrement;
    double test2PhaseIncrement;
    double test1Phase;
    double test2Phase;
//	lo_address outAddress;
	ExtAudioFileRef audioFileRef;
	int sampleCounter;
} EffectState;

@interface BioAudio : NSObject {	
	AUGraph auGraph;
	AudioUnit	remoteIOUnit;
	Float64 hardwareSampleRate;
	EffectState effectState;
}

@property (nonatomic) AudioUnit	remoteIOUnit;

- (void)setup;
- (void)startAudio;
- (void)stopAudio;

@end
