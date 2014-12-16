//
//  VoiceView.h
//  BANJIA
//
//  Created by TeekerZW on 14/12/16.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    RecordStateBegin = 0,
    RecordStateRecording,
    RecordStateWillCancel,
    RecordStateGoOnRecord,
    RecordStateCancel
}RecordState;

@interface VoiceView : UIView
{
    NSArray *metersImageArray;
}


@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *metricsImageView;

@property (nonatomic) RecordState recordState;

-(void)willCancelSendSound;
-(void)goOnRecordSound;

@end
