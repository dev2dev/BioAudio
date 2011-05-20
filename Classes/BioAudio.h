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

#define LOWPASS_TAPS 18
#define DEMOD_X_TAPS 6
#define DEMOD_Y_TAPS 6

typedef struct {
	double hx[LOWPASS_TAPS];
	double zx[LOWPASS_TAPS];
	int taps;
} lpFilter;

typedef struct {
	double hx[DEMOD_X_TAPS];
	double hy[DEMOD_Y_TAPS];
	double zx[DEMOD_X_TAPS];
	double zy[DEMOD_Y_TAPS];
	int taps;
} demodFilter;

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
	lpFilter lpFilter1;
	demodFilter dmFilter1;
	demodFilter dmFilter2;
	double ch1PhaseIncrement;
	double ch2PhaseIncrement;
	double ch1Phase;
	double ch2Phase;
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
