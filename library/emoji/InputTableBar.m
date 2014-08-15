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
#define DEFAULTTEXTHEIGHT  32.5

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
recordButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
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
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, INPUTBUTTONT,inputWidth, DEFAULTTEXTHEIGHT)];
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
        soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        soundButton.frame = CGRectMake(5, INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
        soundButton.backgroundColor = [UIColor clearColor];
        [soundButton setImage:[UIImage imageNamed:@"icon_sound"] forState:UIControlStateNormal];
        [soundButton addTarget:self action:@selector(soundButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        [inputBgView addSubview:soundButton];
        
        
        
        inputWidth = SCREEN_WIDTH-90;
        
        inputTextView.frame = CGRectMake(5, INPUTBUTTONT, inputWidth, DEFAULTTEXTHEIGHT);
        
        recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        recordButton.frame = CGRectMake(45, INPUTBUTTONT, inputWidth, DEFAULTTEXTHEIGHT);
        [recordButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [recordButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
        [recordButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btnbg"] andInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
        [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
        [recordButton setTitle:@"松开播放" forState:UIControlStateHighlighted];
        recordButton.hidden = YES;
        [recordButton addTarget:self action:@selector(recordButtonDown) forControlEvents:UIControlEventTouchDown];
//        [recordButton addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpOutside];
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
    
    faceArray = @[@"smile",
                    @"blush",
                    @"smiley",
                    @"relaxed",
                    @"smirk",
                    @"heart_eyes",
                    @"kissing_heart",
                    @"kissing_closed_eyes",
                    @"flushed",
                    @"relieved",
                    @"grin",
                    @"stuck_out_tongue_winking_eye",
                    @"stuck_out_tongue_closed_eyes",
                    @"worried",
                    @"confused",
                    @"wink",
                    @"sweat",
                    @"pensive",
                    @"disappointed",
                    @"confounded",
                    @"disappointed_relieved",
                    @"fearful",
                    @"cold_sweat",
                    @"cry",
                    @"sob",
                    @"joy",
                    @"astonished",
                    @"scream",
                    @"angry",
                    @"rage",
                    @"sleepy",
                    @"mask",
                    @"no_mouth",
                    @"alien",
                    @"smiling_imp",
                    @"innocent",
                    @"heart",
                    @"broken_heart",
                    @"cupid",
                    @"two_hearts",
                    @"sparkling_heart",
                    @"sparkles",
                    @"star",
                    @"zzz",
                    @"dash",
                    @"sweat_drops",
                    @"musical_note",
                    @"fire",
                    @"hankey",
                    @"shit",
                    @"thumbsup",
                    @"thumbsdown",
                    @"ok_hand",
                    @"punch",
                    @"facepunch",
                    @"fist",
                    @"wave",
                    @"hand",
                    @"point_up",
                    @"pray",
                    @"clap",
                    @"muscle",
                    @"walking",
                    @"runner",
                    @"couple",
                    @"family",
                    @"bow",
                    @"couplekiss",
                    @"couple_with_heart",
                    @"massage",
                    @"boy",
                    @"girl",
                    @"woman",
                    @"man",
                    @"baby",
                    @"older_woman",
                    @"older_man",
                    @"person_with_blond_hair",
                    @"man_with_gua_pi_mao",
                    @"man_with_turban",
                    @"construction_worker",
                    @"cop",
                    @"angel",
                    @"princess",
                    @"smile_cat",
                    @"kiss",
                ];
    
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
            DDLOG(@"%d--%@",i,[faceArray objectAtIndex:i-(i+1)/(colum*3)]);
            NSString *faceName = [NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",[faceArray objectAtIndex:i]]];
            
            UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick:)];
            UILabel *faceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+SCREEN_WIDTH*(count/(row*colum)) +faceWidth*((count%(row*colum))%colum),5+ faceHeight*((i%(row*colum))/colum), faceWidth-5, faceHeight-5)];
            faceLabel.tag = i;
            faceLabel.text = faceName;
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
    delFaceButton.frame = CGRectMake(5+SCREEN_WIDTH*(104/(row*colum)) +faceWidth*((104%(row*colum))%colum)+3,5+ faceHeight*((104%(row*colum))/colum)+8, 30, 25);
    delFaceButton.userInteractionEnabled = YES;
    [delFaceButton addGestureRecognizer:longPress];
    [delFaceButton addTarget:self action:@selector(delCharacter) forControlEvents:UIControlEventTouchUpInside];
    [faceScrollView addSubview:delFaceButton];
    
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

-(void)delCharacter
{
    if ([inputTextView.text length] > 0)
    {
        inputTextView.text = [[inputTextView.text substringToIndex:[inputTextView.text length]-1] emojizedString];
        CGSize size = inputTextView.contentSize;
        inputTextViewSize = size;
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
        {
            [self.returnFunDel changeInputViewSize:size];
        }
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
            faceScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, faceView.frame.size.height-30);
            faceScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*page, FaceViewHeight-77);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height-35, 140, 30);
            pageControl.hidden = NO;
            [inputButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"face"];
            }
        }];
    }
    else
    {
        //切换到键盘
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-8, SCREEN_WIDTH, inputTextViewSize.height);
            faceView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height+faceView.frame.origin.y-pageControlHei, 140, 0);
            pageControl.hidden = YES;
            [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
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
        }];
    }
    else
    {
        //切换到键盘
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-10, SCREEN_WIDTH, inputTextViewSize.height);
            moreView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            [moreButton setImage:[UIImage imageNamed:@"moreinchat"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
    }
    
    more = !more;
}


-(void)faceClick:(UITapGestureRecognizer *)tgr
{
    
    if ((tgr.view.tag+1)%28 != 0)
    {
        NSString *text = [inputTextView text];
        NSString *imageFileName = [[faceArray objectAtIndex:tgr.view.tag] emojizedString];
        [sendString insertString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]] atIndex:[sendString length]];
        NSString *text2 = @"";
        text2 = [text stringByAppendingString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]]];
        inputTextView.text = text2;
        CGSize size = inputTextView.contentSize;
        inputTextViewSize = size;
        
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
        {
            [self.returnFunDel changeInputViewSize:size];
        }
    }
}

-(void)soundButtonClick
{
    if (sound)
    {
        [soundButton setImage:[UIImage imageNamed:@"icon_sound"] forState:UIControlStateNormal];
        recordButton.hidden = YES;
        inputTextView.hidden = NO;
    }
    else
    {
        //显示录音键
        [soundButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        recordButton.hidden = NO;
        inputTextView.hidden = YES;
    }
    sound = !sound;
}

-(void)recordButtonDown
{
    [[RecordTools defaultRecordTools].recorder stop];
    [[RecordTools defaultRecordTools] record];
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
        inputTextViewSize = CGSizeMake(250, DEFAULTTEXTHEIGHT);
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(myReturnFunction)])
        {
            [self.returnFunDel myReturnFunction];
        }
        [textView setText:nil];
        [sendString  setString:@""];
        return NO;
    }
    [sendString insertString:text atIndex:[sendString length]];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize size = textView.contentSize;
    inputTextViewSize = size;
    [self inputChange];
    
    DDLOG(@"length %d",[textView.text length]);
    if ([textView.text length] > 200)
    {
        [Tools showAlertView:@"字数不能超过200" delegateViewController:nil];
        return ;
    }
    
    if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
    {
        [self.returnFunDel changeInputViewSize:size];
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
            inputTextView.frame = CGRectMake( 5, INPUTBUTTONT, inputWidth , inputTextViewSize.height+2.5);
            
            
        }
        else
        {
            inputButton.frame = CGRectMake(SCREEN_WIDTH-40, inputTextViewSize.height-DEFAULTTEXTHEIGHT+INPUTBUTTONT, INPUTBUTTONH, INPUTBUTTONH);
            inputBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, inputTextViewSize.height+10);
            inputTextView.frame = CGRectMake( 5, INPUTBUTTONT, inputWidth , inputTextViewSize.height);
        }
        faceView.frame = CGRectMake(0, inputTextViewSize.height+8, SCREEN_WIDTH, FaceViewHeight-40);
        emoButton.frame = CGRectMake(0, faceView.frame.size.height+inputTextViewSize.height, 110, 49);
        sendButton.frame = CGRectMake(SCREEN_WIDTH-70, faceView.frame.size.height+8+inputTextViewSize.height+8, 60, 30);
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

@end