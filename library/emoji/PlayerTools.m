//
//  PlayerTools.m
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "PlayerTools.h"

@implementation PlayerTools

static PlayerTools *playerTools;

+ (PlayerTools *)defaultPlayerTools
{
    @synchronized (self)
    {
        if (playerTools == nil)
        {
            playerTools = [[PlayerTools alloc] init];
        }
    }
    return playerTools;
}

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(void)palySound:(NSURL *)soundUrl
{
    [audioPlayer stop];
    
    DDLOG(@"sound url %@",[soundUrl absoluteString]);

    NSError *setCategoryError = nil;
    audioSession = [AVAudioSession sharedInstance];
    if ([audioSession isOtherAudioPlaying]) { // mix sound effects with music already playing
        [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&setCategoryError];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
    }
    
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    audioPlayer.volume = 0.5;
    audioPlayer.delegate = self;
    if (error)
    {
        NSLog(@"error %@",[error description]);
        return;
    }
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        NSLog(@"play success");
    }
    else
    {
        NSLog(@"play fail");
    }
}

@end
