//
//  XMRecordPlay.m
//  XMAudioSynthesis
//
//  Created by mifit on 15/6/25.
//  Copyright (c) 2015年 mi. All rights reserved.
//

#import "XMRecordPlay.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface VVERecordPlay()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,strong) AVAudioPlayer * avPlayer;
@property (nonatomic,strong) NSString *recordedTmpFile;
@end

@implementation VVERecordPlay
- (id)init{
    if (self = [super init]) {
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //Setup the audioSession for playback and record.
        //We could just use record and then switch it to playback leter, but
        //since we are going to do both lets set it up once.
        NSError *errorR;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &errorR];
        //Activate the session
        [audioSession setActive:YES error: &errorR];
#ifndef __IPHONE_7_0
        OSStatus error = AudioSessionInitialize(NULL, NULL, NULL, NULL);
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, NULL, (__bridge void *) self);
        UInt32 inputAvailable = 0;
        UInt32 size = sizeof(inputAvailable);
        AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, NULL, (__bridge void *)self);
        AudioSessionSetActive(true);
#endif
    }
    return self;
}
- (void)beginRecorRate:(float)rate{
    [self beginRecord:nil rate:0.0];
}

- (void)beginRecord:(NSString *)filePath rate:(float)rate{
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    if (rate <= 0) {
        rate = 44110;
    }
    //频率
    [recordSetting setValue:[NSNumber numberWithFloat:rate] forKey:AVSampleRateKey];
    //声道
    [recordSetting setValue:[NSNumber numberWithInt:2]  forKey:AVNumberOfChannelsKey];
    //音频质量,采样质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
    
    NSError *error;
    NSURL *fileURL;
    
    if (filePath == nil) {
        self.recordedTmpFile = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]];
         fileURL = [NSURL fileURLWithPath:self.recordedTmpFile];
    }else{
        fileURL = [NSURL fileURLWithPath:filePath];
        self.recordedTmpFile = filePath;
    }
    
    NSLog(@"Using File called: %@",self.recordedTmpFile);
    self.recorder = [[ AVAudioRecorder alloc] initWithURL:fileURL settings:recordSetting error:&error];
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.
    //Found this in antother example, but Im fuzzy on this still.
    [self.recorder setDelegate:self];
    //We call this to start the recording process and initialize
    //the subsstems so that when we actually say "record" it starts right away.
    [self.recorder prepareToRecord];
    //Start the actual Recording
    [self.recorder record];
}

- (void)endRecord{
    [self.recorder stop];
}

- (BOOL)isRecorded{
    return self.recorder.isRecording;
}

- (void)play{
    [self play:self.recordedTmpFile];
}

- (void)play:(NSString *)filePath{
    NSError *error;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    [self.avPlayer prepareToPlay];
    [self.avPlayer play];
}

- (void)stopPlay{
    [self.avPlayer stop];
}
@end
