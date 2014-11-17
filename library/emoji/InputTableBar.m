//
//  InputTableBar.m
//  FaceDemo
//
//  Created by TeekerZW on 3/26/14.
//
//

#import "InputTableBar.h"
#import "Header.h"
#define FaceViewTag  1000
#define INPUTBUTTONH 35
#define INPUTBUTTONT 2.5
#define DEFAULTTEXTHEIGHT  33

@implementation InputTableBar
@synthesize inputTextView,
inputBgView,
face,
more,
sound,
returnFunDel,
sendString,
soundButton,
moreButton,
notOnlyFace,
recordButton,
originWav,
recorderVC,
player,
hideSoundButton,
maxTextLength,
voiceView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        recorderVC = [[ChatVoiceRecorderVC alloc] init];
        recorderVC.vrbDelegate = self;
        recorderVC.recordDel = self;
        
        player = [[AVAudioPlayer alloc]init];
    }
    return self;
}

-(void)setLayout
{
    sendString = [[NSMutableString alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    face = YES;
    more = YES;
    sound = NO;
    
    pageControlHei = 80;
    
    
    fileNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    inputTextViewSize = CGSizeMake(250, DEFAULTTEXTHEIGHT);
    
    inputBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    inputBgView.backgroundColor = RGB(214, 214, 214, 1);
    inputBgView.layer.anchorPoint = CGPointMake(0.5, 1);
    [self addSubview:inputBgView];
    
    //        soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //        soundButton.frame = CGRectMake(10, 5, 40, 30);
    //
    //        soundButton.backgroundColor = [UIColor greenColor];
    //        [inputBgView addSubview:soundButton];
    
    inputWidth = SCREEN_WIDTH-50;
    left = 5;
    
    inputTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(left, INPUTBUTTONT,inputWidth, DEFAULTTEXTHEIGHT) placeHolder:@"请输入内容"];
    inputTextView .backgroundColor = [UIColor whiteColor];
    inputTextView.returnKeyType = UIReturnKeySend;
    inputTextView.autoresizingMask = YES;
    inputTextView.delegate = self;
    inputTextView.layer.cornerRadius = 5;
    inputTextView.clipsToBounds = YES;
    inputTextView.showsVerticalScrollIndicator = NO;
    inputTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    inputTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputTextView.font = [UIFont systemFontOfSize:16];
    [inputBgView addSubview:inputTextView];
    
    
    inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputButton.frame = CGRectMake(SCREEN_WIDTH-40, INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
    inputButton.backgroundColor = [UIColor clearColor];
    [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    [inputButton addTarget:self action:@selector(changeInputType) forControlEvents:UIControlEventTouchUpInside];
    [inputBgView addSubview:inputButton];
    
    if (notOnlyFace)
    {
        inputWidth = SCREEN_WIDTH-140;
        left = 45;
        soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        soundButton.frame = CGRectMake(5, INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
        soundButton.backgroundColor = [UIColor clearColor];
        [soundButton setImage:[UIImage imageNamed:@"icon_sound"] forState:UIControlStateNormal];
        [soundButton addTarget:self action:@selector(soundButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:soundButton];
        
        if (hideSoundButton)
        {
            inputWidth = SCREEN_WIDTH - 100;
            left = 10;
            soundButton.hidden = YES;
        }
        
        inputTextView.frame = CGRectMake(left, INPUTBUTTONT, inputWidth, DEFAULTTEXTHEIGHT);
        
        recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        recordButton.frame = CGRectMake(left, INPUTBUTTONT, inputWidth, DEFAULTTEXTHEIGHT);
        [recordButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        recordButton.layer.cornerRadius = 5;
        recordButton.clipsToBounds = YES;
//        [recordButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btnbg"] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
//        [recordButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"recordBtn"] forState:UIControlStateNormal];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.2;
        recordButton.userInteractionEnabled = YES;
        [recordButton addGestureRecognizer:longPress];
        recordButton.hidden = YES;
        [inputBgView addSubview:recordButton];

        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake( SCREEN_WIDTH - 40, INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
        [moreButton setImage:[UIImage imageNamed:@"moreinchat"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:moreButton];
        
        inputButton.frame = CGRectMake(SCREEN_WIDTH-80, INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
    }
    
    faceView = [[UIView alloc] init];
    faceView.frame = CGRectMake(0, FaceViewHeight+38, SCREEN_WIDTH, 0);
    faceView.backgroundColor = [UIColor whiteColor];
    [self addSubview:faceView];
    
    faceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    faceScrollView.backgroundColor = [UIColor whiteColor];
    faceScrollView.pagingEnabled = YES;
    faceScrollView.tag = FaceViewTag;
    faceScrollView.bounces = NO;
    faceScrollView.delegate = self;
    [faceView addSubview:faceScrollView];
    
    emoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emoButton.frame = CGRectMake(-10, FaceViewHeight-10, 110, 49);
    emoButton.layer.cornerRadius = 3;
    emoButton.clipsToBounds = YES;
    [emoButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [emoButton setTitle:@"Emoji" forState:UIControlStateNormal];
    emoButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:emoButton];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    sendButton.layer.cornerRadius = 3;
    sendButton.backgroundColor = [UIColor whiteColor];
    sendButton.layer.borderColor = TITLE_COLOR.CGColor;
    sendButton.layer.borderWidth = 0.5;
    sendButton.layer.cornerRadius = 2;
    sendButton.clipsToBounds = YES;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [sendButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    sendButton.frame = CGRectMake(SCREEN_WIDTH-70, FaceViewHeight+5, 60, 30);
    [sendButton addTarget:self action:@selector(sendFace) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];

    
    moreView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FaceViewHeight+40, SCREEN_WIDTH, 0)];
    moreView.backgroundColor = [UIColor whiteColor];
    [self addSubview:moreView];
    
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    albumButton.backgroundColor = [UIColor whiteColor];
    albumButton.frame = CGRectMake(10, 10, 60, 60);
    albumButton.tag = AlbumTag;
    [albumButton setImage:[UIImage imageNamed:@"icon_album"] forState:UIControlStateNormal];
    [albumButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:albumButton];
    
    UILabel *albumLabel = [[UILabel alloc] init];
    albumLabel.frame = CGRectMake(albumButton.frame.origin.x, albumButton.frame.size.height+albumButton.frame.origin.y, albumButton.frame.size.width, 20);
    albumLabel.font = [UIFont systemFontOfSize:12];
    albumLabel.text = @"相册";
    albumLabel.textAlignment = NSTextAlignmentCenter;
    albumLabel.textColor = COMMENTCOLOR;
    [moreView addSubview:albumLabel];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.backgroundColor = [UIColor whiteColor];
    photoButton.frame = CGRectMake(80, 10, 60, 60);
    photoButton.tag = TakePhotoTag;
    [photoButton setImage:[UIImage imageNamed:@"icon_take_pic"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:photoButton];
    
    UILabel *photoLabel = [[UILabel alloc] init];
    photoLabel.frame = CGRectMake(photoButton.frame.origin.x, photoButton.frame.size.height+photoButton.frame.origin.y, photoButton.frame.size.width, 20);
    photoLabel.font = [UIFont systemFontOfSize:12];
    photoLabel.text = @"拍照";
    photoLabel.textAlignment = NSTextAlignmentCenter;
    photoLabel.textColor = COMMENTCOLOR;
    [moreView addSubview:photoLabel];
    
    faceDict = [NSString emojiAliases];
    
    NSInteger row = 3;
    NSInteger colum = 7;
    NSInteger i=0;
    NSInteger count=0;
    CGFloat faceWidth = SCREEN_WIDTH/colum;
    CGFloat faceHeight = faceWidth;
    
    faceArray =@[@"哈哈",
                 @"高兴",
                 @"微笑",
//                 @"可爱",
                 @"假笑",
                 @"爱你",
                 @"飞吻",
                 @"亲吻",
                 @"脸红",
                 @"浅笑",
                 @"大笑",
                 @"鬼脸",
                 @"闭眼",
                 @"担心",
                 @"困惑",
                 @"眨眼",
                 @"流汗",
                 @"悲伤",
                 @"难过",
                 @"糊涂",
                 @"失望",
                 @"可怕",
                 @"冷汗",
                 @"哭",
                 @"大哭",
                 @"欢乐",
                 @"吃惊",
                 @"恐惧",
                 @"生气",
                 @"愤怒",
                 @"睡觉",
                 @"口罩",
                 @"闭嘴",
                 @"外星人",
                 @"恶魔",
                 @"天真",
                 @"心",
                 @"心碎",
                 @"丘比特",
                 @"心心相印",
                 @"喜爱",
                 @"闪烁",
                 @"星星",
                 @"休息",
                 @"快跑",
                 @"汗水",
                 @"音符",
                 @"火",
                 @"便便",
                 @"大便",
                 @"大拇指",
                 @"鄙视",
                 @"ok",
                 @"拳头",
                 @"拳击",
//                 @"握拳",
                 @"挥手",
//                 @"击掌",
//                 @"上面",
                 @"祈祷",
                 @"鼓掌",
                 @"强壮",
                 @"行人",
                 @"跑步",
                 @"情侣",
                 @"家庭",
                 @"鞠躬",
                 @"相爱",
                 @"夫妻",
                 @"按摩",
                 @"男孩",
                 @"女孩",
                 @"女人",
                 @"男人",
                 @"小孩",
                 @"老奶奶",
                 @"老爷爷",
                 @"金发碧眼",
                 @"瓜皮帽",
                 @"包头巾",
                 @"建筑工人",
                 @"警察",
                 @"天使",
                 @"公主",
                 @"猫",
                 @"红唇",
                 ];
    
//    NSString *emoPath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
//    NSDictionary *emoDict = [[NSDictionary alloc] initWithContentsOfFile:emoPath];
    for (;i<[faceArray count];)
    {
        if ((i+1)%(colum * row) == 0)
        {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(delCharacter)];

            UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            delFaceButton.backgroundColor = [UIColor whiteColor];
            [delFaceButton setBackgroundImage:[UIImage imageNamed:@"facedel"] forState:UIControlStateNormal];
            delFaceButton.frame = CGRectMake(5+SCREEN_WIDTH*(count/(row*colum)) +faceWidth*((count%(row*colum))%colum)+3,5+ faceHeight*((i%(row*colum))/colum)+8, 30, 25);
            [delFaceButton addTarget:self action:@selector(delCharacter) forControlEvents:UIControlEventTouchUpInside];
            delFaceButton.userInteractionEnabled = YES;
            [delFaceButton addGestureRecognizer:longPress];
            [faceScrollView addSubview:delFaceButton];
        }
        else
        {
            NSString *faceName = [NSString stringWithFormat:@":%@:",[faceArray objectAtIndex:i]];
            
            UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick:)];
            UILabel *faceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+SCREEN_WIDTH*(count/(row*colum)) +faceWidth*((count%(row*colum))%colum),5+ faceHeight*((i%(row*colum))/colum), faceWidth-5, faceHeight-5)];
            faceLabel.tag = i;
            faceLabel.text = [NSString emojizedStringWithString:faceName];
            faceLabel.textAlignment = NSTextAlignmentCenter;
            if (SYSVERSION < 7.0)
            {
                faceLabel.font = [UIFont systemFontOfSize:40];
            }
            else
            {
                faceLabel.font = [UIFont systemFontOfSize:30];
            }
            faceLabel.backgroundColor = [UIColor clearColor];
            faceLabel.userInteractionEnabled = YES;
            [faceLabel addGestureRecognizer:faceTap];
            [faceScrollView addSubview:faceLabel];
        }
       
        count++;
        i++;
    }
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(delCharacter)];

    UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    delFaceButton.backgroundColor = [UIColor whiteColor];
    [delFaceButton setBackgroundImage:[UIImage imageNamed:@"facedel"] forState:UIControlStateNormal];
    delFaceButton.frame = CGRectMake(5+SCREEN_WIDTH*(104/(row*colum)) + faceWidth*((104%(row*colum)) % colum)+3,
                                     5+ faceHeight*((104%(row*colum))/colum)+8,
                                     30, 25);
    delFaceButton.userInteractionEnabled = YES;
    [delFaceButton addGestureRecognizer:longPress];
    [delFaceButton addTarget:self action:@selector(delCharacter) forControlEvents:UIControlEventTouchUpInside];
    [faceScrollView addSubview:delFaceButton];
    
//    faceScrollView.backgroundColor = [UIColor yellowColor];
    
    page = count%(row*colum)>0?(count/(row*colum)+1):(count/(row*colum));
    
    faceScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*page, FaceViewHeight-77);
    faceScrollView.showsHorizontalScrollIndicator = NO;
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height-35, 140, row*faceWidth)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = page;
    pageControl.hidden = YES;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [faceView addSubview:pageControl];
    
    
    self.backgroundColor = TITLE_COLOR;
}

#pragma mark - 录音

-(void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:STARTRECORD object:nil];
        [recordButton setTitle:@"录音开始" forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"touchDown"] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [self showVoiceView];
        
        self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
        //开始录音
        [recorderVC beginRecordByFileName:self.originWav];
    }
    else if (longPress.state == UIGestureRecognizerStateEnded ||
             longPress.state == UIGestureRecognizerStateCancelled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:STOPRECORD object:nil];
        [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"recordBtn"] forState:UIControlStateNormal];
        [recorderVC.recorder stop];
        [self hideVoiceView];
    }
}

-(void)updateVoiceLength:(int)voiceLength
{
    DDLOG(@"voice length %d",voiceLength);
    if (voiceLength < 60)
    {
        voiceView.text = [NSString stringWithFormat:@"%d/60",voiceLength];
        voiceView.textColor = [UIColor whiteColor];
    }
    else
    {
        voiceView.text = @"开始发送";
        voiceView.textColor = [UIColor redColor];
    }
}

-(void)showVoiceView
{
    UIViewController *topVC = [self appRootViewController];
    voiceView = [[UILabel alloc] init];
    voiceView.frame = CGRectMake(CENTER_POINT.x-70, CENTER_POINT.y-50, 140, 100);
    voiceView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    voiceView.layer.cornerRadius = 5;
    voiceView.clipsToBounds = YES;
    voiceView.font = [UIFont systemFontOfSize:35];
    voiceView.textColor = [UIColor whiteColor];
    voiceView.textAlignment = NSTextAlignmentCenter;
    [topVC.view addSubview:voiceView];
    [self updateVoiceLength:0];
}

-(void)hideVoiceView
{
    [voiceView removeFromSuperview];
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

-(void)delCharacter
{
    if ([inputTextView.text length] > 0)
    {
        inputTextView.text = [[[inputTextView.text emojizedString] substringToIndex:[[inputTextView.text emojizedString] length]-1] emojizedString];
        CGSize size = inputTextView.contentSize;
        inputTextViewSize = size;
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
        {
            [self.returnFunDel changeInputViewSize:size];
        }
    }
    if (self.inputTextView.text.length == 0)
    {
        self.inputTextView.textView.hidden = NO;
    }
    else
    {
        self.inputTextView.textView.hidden = YES;
    }
}

-(void)sendFace
{
    inputTextViewSize = CGSizeMake(250, DEFAULTTEXTHEIGHT);
    [self inputChange];
    if ([self.returnFunDel respondsToSelector:@selector(myReturnFunction)])
    {
        [self.returnFunDel myReturnFunction];
    }
    [inputTextView setText:nil];
    [sendString  setString:@""];
    [self backKeyBoard];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == FaceViewTag)
    {
        pageControl.currentPage = scrollView.contentOffset.x/SCREEN_WIDTH;
    }
}

- (NSString *)getParentPath:(NSString *)aPath
{
    return [aPath stringByDeletingLastPathComponent];
}

- (NSArray *)getContentsOfDirectoryAtPath:(NSString *)aDirString

{
    NSFileManager *tempFileManager = [NSFileManager defaultManager];
    return [tempFileManager contentsOfDirectoryAtPath:aDirString
                                                error:nil];
}

-(void)changeInputType
{
    more = YES;
    [moreButton setImage:[UIImage imageNamed:@"moreinchat"] forState:UIControlStateNormal];
    if (face)
    {
        //切换到表情
        [inputTextView resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0, SCREEN_HEIGHT-FaceViewHeight-inputTextViewSize.height-8, SCREEN_WIDTH, FaceViewHeight+inputTextViewSize.height);
            moreView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            faceView.frame = CGRectMake(0, inputTextViewSize.height+8, SCREEN_WIDTH, FaceViewHeight-40);
            emoButton.frame = CGRectMake(0, faceView.frame.size.height+inputTextViewSize.height, 110, 49);
            sendButton.frame = CGRectMake(SCREEN_WIDTH-70, faceView.frame.size.height+8+inputTextViewSize.height+8, 60, 30);
            faceScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, faceView.frame.size.height-27);
            faceScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*page, FaceViewHeight-77);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height-35, 140, 30);
            pageControl.hidden = NO;
            recordButton.hidden = YES;
            inputTextView.hidden = NO;
            [soundButton setImage:[UIImage imageNamed:@"icon_sound"] forState:UIControlStateNormal];
            [inputButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"face"];
            }
            if ([self.returnFunDel respondsToSelector:@selector(showKeyBoard:)])
            {
                [self.returnFunDel showKeyBoard:FaceViewHeight];
            }
        }];
    }
    else
    {
        //切换到键盘
        [self changeToKeyBoardFrom:@"face"];
    }
    face = !face;
}

-(void)moreButtonClick
{
    face = YES;
    pageControl.hidden = YES;
    [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    if (more)
    {
        //切换到more
        [inputTextView resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0, SCREEN_HEIGHT-FaceViewHeight-inputTextViewSize.height-8, SCREEN_WIDTH, FaceViewHeight+inputTextViewSize.height);
            faceView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+8, SCREEN_WIDTH, 0);
            moreView.frame = CGRectMake(0, inputTextViewSize.height+8, SCREEN_WIDTH, FaceViewHeight);
            [moreButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"face"];
            }
            if ([self.returnFunDel respondsToSelector:@selector(showKeyBoard:)])
            {
                [self.returnFunDel showKeyBoard:FaceViewHeight];
            }
        }];
    }
    else
    {
        //切换到键盘
        [self changeToKeyBoardFrom:@"more"];
    }
    
    more = !more;
}

-(void)changeToKeyBoardFrom:(NSString *)fromeType
{
    if ([fromeType isEqualToString:@"face"])
    {
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-8, SCREEN_WIDTH, inputTextViewSize.height);
            faceView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height+faceView.frame.origin.y-pageControlHei, 140, 0);
            pageControl.hidden = YES;
            recordButton.hidden = YES;
            inputTextView.hidden = NO;
            [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
    }
    else if([fromeType isEqualToString:@"more"])
    {
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-10, SCREEN_WIDTH, inputTextViewSize.height);
            moreView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            [moreButton setImage:[UIImage imageNamed:@"moreinchat"] forState:UIControlStateNormal];
            recordButton.hidden = YES;
            inputTextView.hidden = NO;
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
    }
    else if([fromeType isEqualToString:@"sound"])
    {
        //显示键盘
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-10, SCREEN_WIDTH, inputTextViewSize.height);
            [soundButton setImage:[UIImage imageNamed:@"icon_sound"] forState:UIControlStateNormal];
            recordButton.hidden = YES;
            inputTextView.hidden = NO;
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
    }
}


-(void)faceClick:(UITapGestureRecognizer *)tgr
{
    
    if ((tgr.view.tag+1)%21 != 0)
    {
        NSString *text = [inputTextView text];
        NSString *imageFileName = [[faceArray objectAtIndex:tgr.view.tag] emojizedString];
        [sendString insertString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]] atIndex:[sendString length]];
        NSString *text2 = @"";
        text2 = [text stringByAppendingString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]]];
        inputTextView.text = text2;
        CGSize size = inputTextView.contentSize;
        inputTextViewSize = size;
        DDLOG(@"%@++++%@",[NSString stringWithFormat:@":%@:",imageFileName],[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]]);
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
        {
            [self.returnFunDel changeInputViewSize:size];
        }
    }
    if (self.inputTextView.text.length == 0)
    {
        self.inputTextView.textView.hidden = NO;
    }
    else
    {
        self.inputTextView.textView.hidden = YES;
    }
}

-(void)soundButtonClick
{
    if (sound)
    {
        [self changeToKeyBoardFrom:@"sound"];
    }
    else
    {
        //显示录音键
        inputTextViewSize = CGSizeMake(250, DEFAULTTEXTHEIGHT);
        [self inputChange];
        [soundButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        recordButton.hidden = NO;
        inputTextView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
    }
    sound = !sound;
}
-(void)selectImage:(UIButton *)button
{
    if ([self.returnFunDel respondsToSelector:@selector(selectPic:)])
    {
        [self.returnFunDel selectPic:button.tag];
    }
}

//-(void)layOutWithKeyBoardHeight:(CGFloat)keyBoardHeight
//{
//    inputBgView.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, keyBoardHeight+40);
//    faceView.frame = CGRectMake(0, 40, SCREEN_WIDTH, keyBoardHeight);
//}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT-keyBoardHeight-inputTextViewSize.height-8, SCREEN_WIDTH, FaceViewHeight+inputTextViewSize.height+10);
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        if ([self.returnFunDel respondsToSelector:@selector(showKeyBoard:)])
        {
            [self.returnFunDel showKeyBoard:keyBoardHeight];
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    }completion:^(BOOL finished) {
        
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if (textView.text.length > maxTextLength)
        {
            [Tools showAlertView:[NSString stringWithFormat:@"字数不能超过%d",maxTextLength] delegateViewController:nil];
        }
        else
        {
            inputTextViewSize = CGSizeMake(inputWidth, DEFAULTTEXTHEIGHT);
            [self inputChange];
            if ([self.returnFunDel respondsToSelector:@selector(myReturnFunction)])
            {
                [self.returnFunDel myReturnFunction];
            }
            [textView setText:nil];
            [sendString  setString:@""];
        }
        return NO;
    }
    [sendString insertString:text atIndex:[sendString length]];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        self.inputTextView.textView.hidden = NO;
    }
    else
    {
        self.inputTextView.textView.hidden = YES;
    }
    CGSize size = textView.contentSize;
    if(size.height >= 93)
    {
        size = CGSizeMake(inputWidth, 93);
    }
    else if(size.height < DEFAULTTEXTHEIGHT)
    {
        size = CGSizeMake(inputWidth, DEFAULTTEXTHEIGHT);
    }
    inputTextViewSize = size;
    [self inputChange];
    
    if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
    {
        [self.returnFunDel changeInputViewSize:inputTextViewSize];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    moreView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
    faceView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
    face = YES;
    more = YES;
}

-(void)inputChange
{
    [UIView animateWithDuration:0.2 animations:^{
        if (notOnlyFace)
        {
            inputButton.frame = CGRectMake(SCREEN_WIDTH-80, inputTextViewSize.height-DEFAULTTEXTHEIGHT+INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
            moreButton.frame = CGRectMake( SCREEN_WIDTH-40, inputTextViewSize.height-DEFAULTTEXTHEIGHT+INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
            soundButton.frame = CGRectMake( 5, inputTextViewSize.height-DEFAULTTEXTHEIGHT+INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
            inputBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, inputTextViewSize.height+10);
            inputTextView.frame = CGRectMake( left, INPUTBUTTONT, inputWidth , inputTextViewSize.height+2.5);
        }
        else
        {
            inputButton.frame = CGRectMake(SCREEN_WIDTH-40, inputTextViewSize.height-DEFAULTTEXTHEIGHT+INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
            inputBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, inputTextViewSize.height+10);
            inputTextView.frame = CGRectMake(left, INPUTBUTTONT, inputWidth , inputTextViewSize.height);
        }
        faceView.frame = CGRectMake(0, inputTextViewSize.height+8, SCREEN_WIDTH, FaceViewHeight-40);
        emoButton.frame = CGRectMake(0, faceView.frame.size.height+inputTextViewSize.height, 110, 49);
        sendButton.frame = CGRectMake(SCREEN_WIDTH-70, faceView.frame.size.height+8+inputTextViewSize.height+8, 60, 30);
        inputTextView.text = inputTextView.text;
    }];
}

-(void)backKeyBoard
{
    [UIView animateWithDuration:0.2 animations:^{
        [inputTextView resignFirstResponder];
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"moreinchat"] forState:UIControlStateNormal];
        face = YES;
        more = YES;
    }];
}

-(NSString *)findEmoStrWithStr:(NSString *)text
{
    NSDictionary *emojiDict = [NSString emojiAliases];
    for(NSString *key in emojiDict)
    {
        if ([text isEqualToString:[emojiDict objectForKey:key]])
        {
            return key;
        }
    }
    return @"";
}

-(NSMutableString *)analyString:(NSString *)inputString
{
    NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:inputString];
    NSDictionary *emojiDict = [NSString emojiAliases];
    for(NSString *key in emojiDict)
    {
        NSString *emoEncodeStr = [emojiDict objectForKey:key];
        if ([tmpStr rangeOfString:emoEncodeStr].length > 0)
        {
            [tmpStr replaceCharactersInRange:[tmpStr rangeOfString:emoEncodeStr] withString:key];
        }
    }
    return tmpStr;
}
-(void)recordFinished:(NSString *)filePath andFileName:(NSString *)fileName voiceLength:(int)length
{
    
    if ([self.returnFunDel respondsToSelector:@selector(recordFinished:andFileName:voiceLength:)] && length >= 1)
    {
        [self.returnFunDel recordFinished:filePath andFileName:fileName voiceLength:length];
    }
    else if(length < 1)
    {
        if ([self.returnFunDel respondsToSelector:@selector(showTips:)])
        {
            [self.returnFunDel showTips:@"录音时间不能少于1秒"];
        }
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:nil])
        {
            DDLOG(@"delete <s sound!");
        }
    }
//    if(length >= MAX_SOUND_LENGTH)
//    {
//        if ([self.returnFunDel respondsToSelector:@selector(showTips:)])
//        {
//            [self.returnFunDel showTips:[NSString stringWithFormat:@"录音时间不能多于%d秒",MAX_SOUND_LENGTH]];
//        }
//    }
}

-(void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString *)_fileName
{
    
}

@end