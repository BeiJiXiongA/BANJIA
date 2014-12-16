//
//  ChatVoiceRecorderVC.m
//  Jeans
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "ChatVoiceRecorderVC.h"
#import "UIView+Animation.h"
#import "ChatRecorderView.h"

@interface ChatVoiceRecorderVC ()<AVAudioRecorderDelegate>{
    CGFloat                 curCount;           //当前计数,初始为0
    ChatRecorderView        *recorderView;      //录音界面
    CGPoint                 curTouchPoint;      //触摸点
    BOOL                    canNotSend;         //不能发送
    NSTimer                 *timer;
}



@end

@implementation ChatVoiceRecorderVC
@synthesize recorder,recordDel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [recorder release];
    [recorderView release];
    [super dealloc];
}

#pragma mark - 开始录音
- (void)beginRecordByFileName:(NSString*)_fileName;{

    //设置文件名和录音路径
    self.recordFileName = _fileName;
    self.recordFilePath = [VoiceRecorderBaseVC getPathByFileName:recordFileName ofType:@"wav"];

    //初始化录音
    self.recorder = [[[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:recordFilePath]
                                                settings:[VoiceRecorderBaseVC getAudioRecorderSettingDict]
                                                   error:nil]autorelease];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    
    [recorder prepareToRecord];
    
    //还原计数
    curCount = 0;
    //还原发送
    canNotSend = NO;
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [recorder record];
    
    //启动计时器
    [self startTimer];
    
//    //显示录音界面
//    [self initRecordView];
//    [UIView showView:recorderView
//         animateType:AnimateTypeOfPopping
//           finalRect:kRecorderViewRect
//          completion:^(BOOL finish){
//        if (finish){
//            //注册nScreenTouch事件
//            [self addScreenTouchObserver];
//        }
//    }];
//    //设置遮罩背景不可触摸
//    [UIView setTopMaskViewCanTouch:NO];
}
#pragma mark - 初始化录音界面
- (void)initRecordView{
    if (recorderView == nil)
//        recorderView = (ChatRecorderView*)[[[[NSBundle mainBundle]loadNibNamed:@"ChatRecorderView" owner:self options:nil]lastObject]retain];
    //还原界面显示
    [recorderView restoreDisplay];
}
#pragma mark - 启动定时器
- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

#pragma mark - 停止定时器
- (void)stopTimer{
    if (timer && timer.isValid)
    {
        [timer invalidate];
        timer = nil;
    }
}
#pragma mark - 更新音频峰值
- (void)updateMeters
{
    if (recorder.isRecording)
    {
        //更新峰值
//        [recorder updateMeters];
//        [recorderView updateMetersByAvgPower:[recorder averagePowerForChannel:0]];
//        NSLog(@"峰值:%f",[recorder averagePowerForChannel:0]);
//        
//        //倒计时
//        if (curCount >= maxRecordTime - 10 && curCount < maxRecordTime) {
//            //剩下10秒
//            recorderView.countDownLabel.text = [NSString stringWithFormat:@"录音剩下:%d秒",(int)(maxRecordTime-curCount)];
//        }else if (curCount >= maxRecordTime){
//            //时间到
//            [self touchEnded:curTouchPoint];
//        }
        
        curCount += 1;
        
        if (curCount == MAX_SOUND_LENGTH)
        {
            [recorder stop];
        }
        if ([self.recordDel respondsToSelector:@selector(updateVoiceLength:)])
        {
            [self.recordDel updateVoiceLength:curCount];
        }
    }
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
    [self stopTimer];
    if ([self.recordDel respondsToSelector:@selector(recordFinished:andFileName:voiceLength:)])
    {
        NSLog(@"录音停止%.1f",curCount);
        [self.recordDel recordFinished:self.recordFilePath andFileName:self.recordFileName voiceLength:curCount];
    }
    curCount = 0;
}

- (void)cancelRecord
{
    [self stopTimer];
    if ([self.recordDel respondsToSelector:@selector(cancelRecordWithPath:andFileName:)] && curCount >= 1)
    {
        NSLog(@"录音停止%.1f",curCount);
        [self.recordDel cancelRecordWithPath:recordFilePath andFileName:recordFileName];
    }
    curCount = 0;
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始");
    [self stopTimer];
    curCount = 0;
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
    [self stopTimer];
    curCount = 0;
}

@end
