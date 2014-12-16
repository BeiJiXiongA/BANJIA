//
//  VoiceView.m
//  BANJIA
//
//  Created by TeekerZW on 14/12/16.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "VoiceView.h"

@implementation VoiceView

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        
        metersImageArray = @[[UIImage imageNamed:@"RecordingSignal001"],
                             [UIImage imageNamed:@"RecordingSignal002"],
                             [UIImage imageNamed:@"RecordingSignal003"],
                             [UIImage imageNamed:@"RecordingSignal004"],
                             [UIImage imageNamed:@"RecordingSignal005"],
                             [UIImage imageNamed:@"RecordingSignal006"],
                             [UIImage imageNamed:@"RecordingSignal007"],
                             [UIImage imageNamed:@"RecordingSignal008"],
                             ];
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        UIImage *indicatorImage = [UIImage imageNamed:@"RecordingBkg"];
        self.indicatorImageView = [[UIImageView alloc] init];
        self.indicatorImageView.frame = CGRectMake(50, 20, indicatorImage.size.width, indicatorImage.size.height);
        self.indicatorImageView.backgroundColor = [UIColor clearColor];
        [self.indicatorImageView setImage:indicatorImage];
        [self addSubview:self.indicatorImageView];
        
        
        UIImage *metrics1 = [UIImage imageNamed:@"RecordingSignal001"];
        self.metricsImageView = [[UIImageView alloc] init];
        self.metricsImageView.frame = CGRectMake(50+indicatorImage.size.width+10, 20+26, metrics1.size.width, metrics1.size.height);
        self.metricsImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.metricsImageView];
        [self.metricsImageView setAnimationDuration:2.5];
        [self.metricsImageView setAnimationImages:metersImageArray];
        [self.metricsImageView setAnimationRepeatCount:0];
        [self.metricsImageView startAnimating];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.frame = CGRectMake(frame.size.width-50, self.indicatorImageView.frame.size.height+self.indicatorImageView.frame.origin.y-35 , 40, 30);
        self.timeLabel.font = [UIFont systemFontOfSize:15];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLabel];
        
        self.tipLabel = [[UILabel alloc] init];
        self.tipLabel.frame = CGRectMake(10, frame.size.height-35, frame.size.width-20, 25);
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.textColor = [UIColor lightGrayColor];
        self.tipLabel.layer.cornerRadius = 8;
        self.tipLabel.clipsToBounds = YES;
        self.tipLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.tipLabel];
    }
    return self;
}

-(void)willCancelSendSound
{
    self.tipLabel.text = @"松开手指，取消发送";
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.backgroundColor = RGB(143, 48, 46, 1);
    
    UIImage *cancelImage = [UIImage imageNamed:@"RecordCancel"];
    self.indicatorImageView.frame = CGRectMake((self.frame.size.width-cancelImage.size.width)/2, self.indicatorImageView.frame.origin.y, cancelImage.size.width, cancelImage.size.height);
    self.metricsImageView.hidden = YES;
    [self.indicatorImageView setImage:cancelImage];
        
}
-(void)goOnRecordSound
{
    self.tipLabel.textColor = [UIColor lightGrayColor];
    self.tipLabel.text = @"手指上划，取消发送";
    self.tipLabel.backgroundColor = [UIColor clearColor];
    
    UIImage *indicatorImage = [UIImage imageNamed:@"RecordingBkg"];
    self.indicatorImageView.frame = CGRectMake(50, 20, indicatorImage.size.width, indicatorImage.size.height);
    [self.indicatorImageView setImage:indicatorImage];
    self.metricsImageView.hidden = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
