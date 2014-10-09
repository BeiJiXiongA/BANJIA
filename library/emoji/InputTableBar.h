//
//  InputTableBar.h
//  FaceDemo
//
//  Created by TeekerZW on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "NSString+Emojize.h"
#import "Header.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "MCSoundBoard.h"

@protocol ReturnFunctionDelegate;

@interface InputTableBar : UIView<UIScrollViewDelegate,UITextViewDelegate,VoiceRecorderBaseVCDelegate,RecordDelegate>
{
    UIButton *inputButton;
    UIButton *addButton;
    CGFloat inputLength;
    CGFloat left;
    
    UIView *faceView;
    UIScrollView *faceScrollView;
    NSMutableArray *fileNameArray;
    UIPageControl *pageControl;
    NSDictionary *faceDict;
    
    UIView *moreView;
    
    CGFloat keyBoardHeight;
    
    CGSize inputTextViewSize;
    
    NSArray *faceArray;
    
    CGFloat inputWidth;
    CGFloat pageControlHei;
    int page;
    
    UIButton *emoButton;
    UIButton *sendButton;
}
@property (nonatomic, strong) NSString *originWav;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIView *inputBgView;
@property (nonatomic, assign) BOOL face;
@property (nonatomic, assign) BOOL more;
@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL notOnlyFace;
@property (nonatomic ,assign) BOOL hideSoundButton;
@property (nonatomic, strong) UIButton *soundButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, assign) id<ReturnFunctionDelegate> returnFunDel;
@property (nonatomic, strong) NSMutableString *sendString;

@property (nonatomic, strong) ChatVoiceRecorderVC *recorderVC;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) NSInteger maxTextLength;

-(NSMutableString *)analyString:(NSString *)inputString;

-(void)backKeyBoard;

-(void)setLayout;
//-(void)layOutWithKeyBoardHeight:(CGFloat)keyBoardHeight;
@end

@protocol ReturnFunctionDelegate <NSObject>

-(void)myReturnFunction;
-(void)showKeyBoard:(CGFloat)keyBoardHeight;
-(void)changeInputType:(NSString *)changeType;

-(void)changeInputViewSize:(CGSize)size;
@optional
-(void)selectPic:(int)selectPicTag;
-(void)recordFinished:(NSString *)filePath andFileName:(NSString *)fileName voiceLength:(int)length;

-(void)showTips:(NSString *)tipString;

@end
