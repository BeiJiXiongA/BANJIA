//
//  PlayerTools.h
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayerTools;

@interface PlayerTools : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
    AVAudioSession *audioSession;
}

+ (PlayerTools *)defaultPlayerTools;

-(void)palySound:(NSURL *)soundUrl;

@end
