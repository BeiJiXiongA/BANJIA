//
//  RecordTools.m
//  BANJIA
//
//  Created by TeekerZW on 7/18/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "RecordTools.h"

@implementation RecordTools
@synthesize recorder;

static RecordTools *sharedRecordTools;
+ (RecordTools *)defaultRecordTools
{
    @synchronized (self)
    {
        if (sharedRecordTools == nil)
        {
            sharedRecordTools = [[RecordTools alloc] init];
        }
    }
    return sharedRecordTools;
}

-(void)record
{
    [recorder stop];
    
    secs = 0;
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:44100.0f],AVSampleRateKey,[NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,[NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,[NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey, nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    tmpFile = [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",@"tmp",@"caf"]]];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:tmpFile settings:setting error:nil];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    [recorder record];
    
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag)
    {
        if ([self.recordDel respondsToSelector:@selector(recordFinished:andSecs:)])
        {
            [self.recordDel recordFinished:tmpFile andSecs:secs];
            
            
        }
        
        [[PlayerTools defaultPlayerTools] palySound:tmpFile];
        secs = 0;
    }
}

-(void)timeUpdate
{
    secs++;
}

@end
