//
//  BioAudio.h
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VVOSC.h"

#define LOWPASS_TAPS 18
#define DEMOD_X_TAPS 6
#define DEMOD_Y_TAPS 6

typedef struct {
	double hx[LOWPASS_TAPS];
	double z[LOWPASS_TAPS];
	int taps;
	int state;
} lpFilter;

typedef struct {
	double hx[DEMOD_X_TAPS];
	double hy[DEMOD_Y_TAPS];
	double zx[DEMOD_X_TAPS];
	double zy[DEMOD_Y_TAPS];
	int taps;
	int state;
} demodFilter;

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
	float frequency;
	float gain;
	lpFilter lpFilter1;
	demodFilter dmFilter1;
	demodFilter dmFilter2;
	double ch1PhaseIncrement;
	double ch2PhaseIncrement;
	double ch1Phase;
	double ch2Phase;
} EffectState;

@interface BioAudio : NSObject {	
	AUGraph auGraph;
	AudioUnit	remoteIOUnit;
	Float64 hardwareSampleRate;
	EffectState effectState;
	OSCManager *oscMgr;
}

@property (nonatomic) AudioUnit	remoteIOUnit;
@property (retain) OSCManager *oscMgr;

- (void)setup;
- (void)setGain:(float)gain;
- (void)setFreq:(float)freq;

@end
