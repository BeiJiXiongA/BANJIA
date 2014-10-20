//
//  ChatVoiceRecorderVC.h
//  Jeans
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "VoiceRecorderBaseVC.h"


#define kRecorderViewRect       CGRectMake(80, 120, 160, 160)
//#define kCancelOriginY          (kRecorderViewRect.origin.y + kRecorderViewRect.size.height + 180)
#define kCancelOriginY          ([[UIScreen mainScreen]bounds].size.height-70)

@protocol RecordDelegate;

@interface ChatVoiceRecorderVC : VoiceRecorderBaseVC
@property (retain, nonatomic)   AVAudioRecorder     *recorder;
@property (nonatomic, strong) id<RecordDelegate> recordDel;

//开始录音
- (void)beginRecordByFileName:(NSString*)_fileName;

@end

@protocol RecordDelegate <NSObject>

-(void)recordFinished:(NSString *)filePath andFileName:(NSString *)fileName voiceLength:(int)length;

-(void)updateVoiceLength:(int)voiceLength;

@end
