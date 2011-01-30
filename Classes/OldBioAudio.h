//
//  BioAudio.h
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface BioAudio : NSObject <AVAudioSessionDelegate> {
	OSStatus					status;
	AVAudioSession				*session;
	Float64						sampleRate;
	AudioComponentDescription	rioAUDescription;
	AudioUnit					rioAUInstance;
	AudioStreamBasicDescription	streamDesc;
	AUGraph						myAUGraph;
	AUNode						rioNode;
	double						sinPhase;
}

@property (retain) AVAudioSession				*session;
@property (assign) double						sampleRate;
@property (assign) AudioComponentDescription	rioAUDescription;
@property (assign) AudioUnit					rioAUInstance;
@property (assign) AudioStreamBasicDescription	streamDesc;
@property (assign) AUGraph						myAUGraph;
@property (assign) AUNode						rioNode;

- (void)setup;

@end
