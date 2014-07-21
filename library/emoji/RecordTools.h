//
//  RecordTools.h
//  BANJIA
//
//  Created by TeekerZW on 7/18/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class RecordTools;

@protocol RecordDelegate;

@interface RecordTools : NSObject<AVAudioRecorderDelegate>
{
    NSURL *tmpFile;
    BOOL recording;
    AVAudioPlayer *audioPlayer;
    AVAudioSession *audioSession;
    NSTimer *timer;
    
    NSTimeInterval secs;
}

+ (RecordTools *)defaultRecordTools;

@property (nonatomic, assign) id<RecordDelegate> recordDel;
@property (nonatomic, strong) AVAudioRecorder *recorder;

-(void)record;
@end

@protocol RecordDelegate <NSObject>

-(void)recordFinished:(NSURL *)soundURL andSecs:(NSTimeInterval)secs;

@end