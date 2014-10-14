//
//  HomeViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "HomeViewController.h"
#import "KKNavigationController.h"
#import "KKNavigationController+JDSideMenu.h"
#import "UINavigationController+JDSideMenu.h"
#import "PopView.h"
#import "DemoVIew.h"
#import "NotificationCell.h"
#import "AddDongTaiViewController.h"
#import "AddNotificationViewController.h"
#import "NotificationDetailViewController.h"
#import "TrendsCell.h"
#import "InputTableBar.h"
#import "MyButton.h"
#import "DongTaiDetailViewController.h"
#import "SearchClassViewController.h"
#import "CreateClassViewController.h"
#import "DiaryTools.h"
#import "CheckQRCodeViewController.h"

#import "ZBarReaderViewController.h"
#import "ZBarSDK.h"

#import "ClassZoneViewController.h"

#import "ChatViewController.h"

#import "AdHeaderCell.h"

#import "UIImageView+WebCache.h"

#import "TOWebViewController.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  999999
#define RowTag     3333

#define AdScrollViewTag 22222
#define AdPageControlTag   55555

#define ImageHeight  65.5f

#define ImageCountPerRow  4

#define TipViewHeight  300

@interface HomeViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate,
ReturnFunctionDelegate,
NameButtonDel,
ClassZoneDelegate,
NotificationDetailDelegate,
NameButtonDel,
ChatDelegate,
MsgDelegate,
DongTaiDetailAddCommentDelegate,
ZBarReaderDelegate,
headerDelegate>
{
    int page;
    
    
    UIButton *moreButton;
    
    CGFloat commentHeight;
    
    BOOL addOpen;
    UIView *addView;
    MyButton *addNoticeButton;
    MyButton *addDiaryButton;
    MyButton *qrCodeButton;
    NSDictionary *diaryDict;
    NSDictionary *waitTransmitDict;
    NSDictionary *waitCommentDict;
    NSString *waitDiaryID;
    DemoVIew *demoView;
    
    CGFloat tmpheight;
    CGSize inputSize;
    CGFloat faceViewHeight;
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
    
    UIImageView *navImageView;
    
    NSMutableArray *noticeArray;
    NSMutableArray *diariesArray;
    NSMutableArray *groupDiaries;
    OperatDB *db;
    
    EGORefreshTableHeaderView *egoheaderView;
    FooterView *footerView;
    
    BOOL _reloading;
    
    InputTableBar *inputTabBar;
    
    UITapGestureRecognizer *backTgr;
    
    UIButton *addButton;
    
    UIView *tipView;
    UIButton *joinClassButton;
    UIButton *createClassButton;
    UILabel *tipLabel;
    
    UIImageView *line;
    
    UIImageView *tipImageView;
    UIImageView *subImageView;
    UIButton *tipJoinClassButton;
    UIButton *tipCreateClassButton;
    UIImageView *checkTipImageView;
    UIView *buttonView;
    
    NSTimer *adTimer;
    
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    ZBarReaderViewController * reader;
    
    BOOL shoudShowTipView;
    BOOL haveHomeAd;
    BOOL haveClass;
    
    NSMutableArray *adArray;
    
    int headerNewsIndex;
    
    CGFloat HeaderCellHeight;
    
    NSInteger waitCommentSection;
    NSInteger waitCommentIndex;
    
    NSIndexPath *currentIndexPath;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)joinClass
{
    SearchClassViewController *searchclassVC = [[SearchClassViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:searchclassVC animated:YES];
}
-(void)createClass
{
    CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:createClassViewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    page = 0;
    
    commentHeight = 0;
    tmpheight = 0;
    
    db = [[OperatDB alloc]init];
    
    waitDiaryID = @"";
    
    shoudShowTipView = NO;
    haveClass = NO;
    
    self.backButton.hidden = YES;
    self.returnImageView.hidden = YES;
    self.titleLabel.text = @"首页";
//    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*19)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*19, 30);
   // self.titleLabel.hidden = YES;
    
    addOpen = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeData) name:RECEIVENEWNOTICE object:nil];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    backTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backInput)];
    
    noticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    diariesArray = [[NSMutableArray alloc] initWithCapacity:0];
    groupDiaries = [[NSMutableArray alloc] initWithCapacity:0];
    adArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, self.backButton.frame.origin.y, 42, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.showsVerticalScrollIndicator = NO;
    classTableView.backgroundColor = [UIColor clearColor];
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classTableView];
    if ([classTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    egoheaderView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classTableView orientation:EGOPullOrientationDown];
    egoheaderView.delegate = self;
    
    footerView = [[FooterView alloc] initWithScrollView:classTableView];
    footerView.delegate = self;
    
    addView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-147, UI_NAVIGATION_BAR_HEIGHT-10, 129, 135)];
    addView.backgroundColor = [UIColor clearColor];
    
    
    UIImageView *addBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, addView.frame.size.width, addView.frame.size.height)];
    [addBg setImage:[UIImage imageNamed:@"bor_bg"]];
    [addView addSubview:addBg];
    
    
    addNoticeButton = [MyButton buttonWithType:UIButtonTypeCustom];
    addNoticeButton.frame = CGRectMake(4, 54.5, 120, 38);
    addNoticeButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    addNoticeButton.alpha = 0;
    [addNoticeButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [addNoticeButton setBackgroundImage:[UIImage imageNamed:@"release"] forState:UIControlStateNormal];
    [addNoticeButton setBackgroundImage:[UIImage imageNamed:@"release_on"] forState:UIControlStateHighlighted];
    [addView addSubview:addNoticeButton];
    [addNoticeButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
    
    addDiaryButton = [MyButton buttonWithType:UIButtonTypeCustom];
    addDiaryButton.frame = CGRectMake(4, 13, 120, 38);
    addDiaryButton.alpha = 0;
    [addDiaryButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addDiaryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [addView addSubview:addDiaryButton];
    [addDiaryButton setBackgroundImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    [addDiaryButton setBackgroundImage:[UIImage imageNamed:@"publish_on"] forState:UIControlStateHighlighted];
    [addDiaryButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
    
    qrCodeButton = [MyButton buttonWithType:UIButtonTypeCustom];
    qrCodeButton.frame = CGRectMake(4, 93, 120, 38);
    qrCodeButton.alpha = 0;
    [qrCodeButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    qrCodeButton.backgroundColor = [UIColor greenColor];
    [qrCodeButton setBackgroundImage:[UIImage imageNamed:@"qr"] forState:UIControlStateNormal];
    [qrCodeButton setBackgroundImage:[UIImage imageNamed:@"qr_on"] forState:UIControlStateHighlighted];
    [addView addSubview:qrCodeButton];
    [qrCodeButton addTarget:self action:@selector(scanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    addView.alpha = 0;
    addNoticeButton.alpha = 0;
    addDiaryButton.alpha = 0;
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.notOnlyFace = NO;
    inputTabBar.maxTextLength = COMMENT_TEXT_LENGHT;
    [self.bgView addSubview:inputTabBar];
    inputSize = CGSizeMake(250, 30);
    [inputTabBar setLayout];
    
    tipView = [[UIView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+60, SCREEN_WIDTH-20, 300)];
    tipView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:tipView];
    
    tipView.hidden = YES;
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 0, SCREEN_WIDTH-62, 70)];
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 3;
    tipLabel.textColor = COMMENTCOLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"你可以在这里创建班级，也可以通过班号或二维码加入班级";
    [tipView addSubview:tipLabel];
    
    joinClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    joinClassButton.frame = CGRectMake(22, 80, SCREEN_WIDTH-64, 36);
    [joinClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [joinClassButton addTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
    [joinClassButton setTitle:@"加入班级" forState:UIControlStateNormal];
    [tipView addSubview:joinClassButton];
    
    createClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createClassButton.frame = CGRectMake(22, 130, SCREEN_WIDTH-64, 35.5);
    [createClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [createClassButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
    [tipView addSubview:createClassButton];
    
    [self.bgView addSubview:addView];
    
    [self getData];
}

-(void)outTap
{
    
}
-(void)loadIntroduceTip
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (ShowTips == 1)
    {
        [ud removeObjectForKey:@"hometip1"];
        [ud removeObjectForKey:@"hometip2"];
        [ud synchronize];
    }
    
    if (tipImageView)
    {
        return ;
    }
    if (![ud objectForKey:@"hometip1"] && !haveClass)
    {
        self.unReadLabel.hidden = YES;
        
        createClassButton.hidden = YES;
        joinClassButton.hidden = YES;
        tipImageView = [[UIImageView alloc] init];
        tipImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 568);
        if (SYSVERSION >= 7)
        {
            [tipImageView setImage:[UIImage imageNamed:@"hometip1"]];
        }
        else
        {
            [tipImageView setImage:[UIImage imageNamed:@"hometip16"]];
        }
        
        tipImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [self.bgView addSubview:tipImageView];
        
        buttonView = [[UIView alloc] init];
        buttonView.backgroundColor = [UIColor whiteColor];
        buttonView.layer.cornerRadius = 5;
        buttonView.clipsToBounds = YES;
        [tipImageView addSubview:buttonView];
        
        tipJoinClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipJoinClassButton.frame = CGRectMake(5, 5, SCREEN_WIDTH-72, 37);
        [tipJoinClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [tipJoinClassButton setTitle:@"加入班级" forState:UIControlStateNormal];
        [buttonView addSubview:tipJoinClassButton];
        
        tipCreateClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipCreateClassButton.frame = CGRectMake(5, 47, SCREEN_WIDTH-72, 37);
        [tipCreateClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [tipCreateClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
        [buttonView addSubview:tipCreateClassButton];
        
        buttonView.frame = CGRectMake(31, 187.5, SCREEN_WIDTH-62, 89);
        
        subImageView = [[UIImageView alloc] init];
        subImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        subImageView.frame = CGRectMake(0, tipImageView.frame.size.height+tipImageView.frame.origin.y, SCREEN_WIDTH, 200);
        subImageView.hidden = YES;
        [self.bgView addSubview:subImageView];
        
        UITapGestureRecognizer *outTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outTap)];
        tipImageView.userInteractionEnabled = YES;
        [tipImageView addGestureRecognizer:outTap];
        
        checkTipImageView = [[UIImageView alloc] init];
        checkTipImageView.frame = CGRectMake(30, 320, 260, 45);
        checkTipImageView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:checkTipImageView];
        
        UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTip)];
        checkTipImageView.userInteractionEnabled = YES;
        [checkTipImageView addGestureRecognizer:tipTap];
    }
}

-(void)checkTip
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:@"hometip1"])
    {
        if (SYSVERSION >= 7)
        {
            [tipImageView setImage:[UIImage imageNamed:@"hometip2"]];
        }
        else
        {
            [tipImageView setImage:[UIImage imageNamed:@"hometip26"]];
        }
        checkTipImageView.frame = CGRectMake(18, 100, 260, 45);
        tipJoinClassButton.hidden = YES;
        tipCreateClassButton.hidden = YES;
        moreButton.hidden = YES;
        createClassButton.hidden = NO;
        joinClassButton.hidden = NO;
        [buttonView removeFromSuperview];
        UIButton *tipmoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipmoreButton.frame = CGRectMake(0, self.backButton.frame.origin.y+2, 42, NAV_RIGHT_BUTTON_HEIGHT);
        [tipmoreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
        [tipImageView addSubview:tipmoreButton];
        
        tipView.hidden = NO;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hometip1"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if((![ud objectForKey:@"hometip2"]))
    {
        [checkTipImageView removeFromSuperview];
        [tipImageView removeFromSuperview];
        tipView.hidden = NO;
        moreButton.hidden = NO;
        [classTableView reloadData];
        [self viewWillAppear:NO];
    }
}

#pragma mark - updatelasttime
-(void)uploadLastViewTime
{
    
}

#pragma mark - 扫一扫

-(void)scanBtnAction
{
    num = 0;
    upOrdown = NO;
    addOpen = NO;
    [self closeAdd];
    
    reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.readerView.torchMode = 0;
    reader.readerView.frame = CGRectMake( 0, YSTART == 0?20:0, SCREEN_WIDTH, SCREEN_HEIGHT);
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsZBarControls = NO;
    [self setOverlayPickerView];
    reader.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);//扫描的感应框
    ZBarImageScanner * scanner = reader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    [self.navigationController pushViewController:reader animated:YES];
//    [self presentViewController:reader animated:YES completion:^{
//    
//    }];
}

- (void)setOverlayPickerView
{
    //清除原有控件
    
    for (UIView *temp in [reader.view subviews])
    {
        if (temp.frame.size.height == 54)
        {
            [temp removeFromSuperview];
        }
        for (UIButton *button in [temp subviews])
        {
            if ([button isKindOfClass:[UIButton class]])
            {
                [button removeFromSuperview];
            }
        }

        for (UIToolbar *toolbar in [temp subviews])
        {
            
            if ([toolbar isKindOfClass:[UIToolbar class]])
            {
                [toolbar setHidden:YES];
                
                [toolbar removeFromSuperview];
            }
        }
    }
    
    CGFloat height = SCREEN_WIDTH-100;
    
    UIColor *viewColor = [UIColor blackColor];
    
    //最上部view
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_HEIGHT-height)/2-40)];
    
    upView.alpha = 0.3;
    
    upView.backgroundColor = viewColor;
    
    [reader.view addSubview:upView];
    
    //left,up
    UIImageView *upLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_1"]];
    upLeftCorner.frame = CGRectMake(50, (SCREEN_HEIGHT-height)/2-40, 25, 25);
    [reader.view addSubview:upLeftCorner];
    
    //right,up
    UIImageView *upRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_2"]];
    upRightCorner.frame = CGRectMake(SCREEN_WIDTH-50-25, (SCREEN_HEIGHT-height)/2-40, 25, 25);
    [reader.view addSubview:upRightCorner];
    
    
    //左侧的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-height)/2-40, 50, height)];
    
    leftView.alpha = 0.3;
    
    leftView.backgroundColor = viewColor;
    
    [reader.view addSubview:leftView];
    
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, (SCREEN_HEIGHT-height)/2-40, 50, height)];
    
    rightView.alpha = 0.3;
    
    rightView.backgroundColor = viewColor;
    
    [reader.view addSubview:rightView];
    
    //left,down
    UIImageView *downLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_4"]];
    downLeftCorner.frame = CGRectMake(50, (SCREEN_HEIGHT-height)/2+height-25-40, 25, 25);
    [reader.view addSubview:downLeftCorner];
    
    //right,down
    UIImageView *downRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_3"]];
    downRightCorner.frame = CGRectMake(SCREEN_WIDTH-50-25, (SCREEN_HEIGHT-height)/2+height-25-40, 25, 25);
    [reader.view addSubview:downRightCorner];
    
    
    //底部view
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, height+(SCREEN_HEIGHT-height)/2-40, SCREEN_WIDTH, (SCREEN_HEIGHT-height)/2+80)];
    
    downView.alpha = 0.3;
    
    downView.backgroundColor = viewColor;
    
    [reader.view addSubview:downView];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(70, (SCREEN_HEIGHT-height)/2+height+15-40, SCREEN_WIDTH-140, 50)];
    label.text = @"请将班级二维码或群聊二维码置于方框内";
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    [reader.view addSubview:label];
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    image.frame = CGRectMake(20, (SCREEN_HEIGHT-height)/2-40, height, height);
    [reader.view addSubview:image];
    
    
    line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    line.image = [UIImage imageNamed:@"qrline"];
    [image addSubview:line];
    //定时器，设定时间过1.5秒，
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    UIView *_navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          UI_SCREEN_WIDTH,
                                                                          UI_NAVIGATION_BAR_HEIGHT)];
    _navigationBarView.backgroundColor = [UIColor yellowColor];
    [reader.view addSubview:_navigationBarView];
    
    UIImageView * _navigationBarBg = [[UIImageView alloc] init];
    _navigationBarBg.backgroundColor = UIColorFromRGB(0xffffff);
    _navigationBarBg.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_NAVIGATION_BAR_HEIGHT);
    _navigationBarBg.image = [UIImage imageNamed:@"nav_bar_bg"];
    [_navigationBarView addSubview:_navigationBarBg];
    
    UILabel * _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90, YSTART + 6, 180, 36)];
    _titleLabel.font = [UIFont fontWithName:@"Courier" size:19];
    _titleLabel.text = @"扫一扫";
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x666464);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBarView addSubview:_titleLabel];
    
    
    UIImageView *returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, YSTART +13, 11, 18)];
    [returnImageView setImage:[UIImage imageNamed:@"icon_return"]];
    [_navigationBarView addSubview:returnImageView];
    
    UIButton *_backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, YSTART +2, 58 , NAV_RIGHT_BUTTON_HEIGHT)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:UIColorFromRGB(0x727171) forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(unShowSelfViewController) forControlEvents:UIControlEventTouchUpInside];
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _backButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_navigationBarView addSubview:_backButton];
    
    //用于取消操作的button
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.alpha = 0.4;
    cancelButton.backgroundColor = [UIColor blackColor];
    [cancelButton setFrame:CGRectMake((SCREEN_WIDTH-100)/2, label.frame.size.height+label.frame.origin.y+20, 100, 40)];
    cancelButton.layer.cornerRadius = 15;
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelButton.layer.borderWidth = 0.3;
    cancelButton.clipsToBounds = YES;
    [cancelButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
//    [cancelButton setTitle:@"开灯" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cancelButton addTarget:self action:@selector(light)forControlEvents:UIControlEventTouchUpInside];
    [reader.view addSubview:cancelButton];
    
    //用于取消操作的button
    
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    albumButton.alpha = 0.7;
    
    albumButton.backgroundColor = [UIColor blackColor];
    
    [albumButton setFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-40, SCREEN_WIDTH/2, 40)];
    
    [albumButton setTitle:@"相册" forState:UIControlStateNormal];
    
    [albumButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    
    //    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    
//    [reader.view addSubview:albumButton];
    
    [self getData];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)light
{
    if (reader.readerView.torchMode == 0)
    {
        reader.readerView.torchMode = 1;
    }
    else
    {
        reader.readerView.torchMode = 0;
    }
}


-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == SCREEN_WIDTH-120) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}


//取消button方法

- (void) imagePickerController: (UIImagePickerController*) picker
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    DDLOG(@"%@",symbol.data);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *resultStr = symbol.data;
    [timer invalidate];
    if ([resultStr rangeOfString:@";"].length > 0)
    {
        [self searchClass:[resultStr substringFromIndex:[resultStr rangeOfString:@";"].location+1]];
    }
    else if([resultStr rangeOfString:@"?"].length > 0 &&
            [resultStr rangeOfString:@"="].length > 0)
    {
        NSRange range1 = [resultStr rangeOfString:@"?"];
        NSRange range2 = [resultStr rangeOfString:@"="];
        if (range1.length > 0 && range2.length > 0)
        {
            NSString *key = [resultStr substringWithRange:NSMakeRange(range1.location+1, range2.location-range1.location-1)];
            NSString *value = [resultStr substringWithRange:NSMakeRange(range2.location+1, [resultStr length]-range2.location-1)];
            DDLOG(@"key = %@  value = %@",key,value);
            if([key isEqualToString:@"groupid"])
            {
                [self joinGroupChat:value];
            }
            else if([key isEqualToString:@"classid"])
            {
                [self searchClass:value];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:NO];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:symbol.data]];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:NO];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:symbol.data]];
    }
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)joinGroupChat:(NSString *)groupID
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID,
                                                                      } API:JOINGROUPCHAR];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                ChatViewController *chatVC = [[ChatViewController alloc] init];
                chatVC.toID = groupID;
                chatVC.isGroup = YES;
                [self.navigationController pushViewController:chatVC animated:YES];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)searchClass:(NSString *)searchContent
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":@"",
                                                                      @"number":[NSString stringWithFormat:@"%d",[searchContent integerValue]]
                                                                      } API:SEARCHCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                    {
                        NSString *classID = [[responseDict objectForKey:@"data"] objectForKey:@"_id"];
                        NSString *className = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                        
                        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"classid":classID} andTableName:MYCLASSTABLE] count]> 0)
                        {
                            [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
                            return ;
                        }
                        
                        NSString *schoolName;
                        if (![[[responseDict objectForKey:@"data"] objectForKey:@"school"] isEqual:[NSNull null]])
                        {
                            schoolName = [[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
                        }
                        else
                        {
                            schoolName = @"未指定学校";
                        }
                        
                        ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
                        classZone.isApply = YES;
                        [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
                        [[NSUserDefaults standardUserDefaults] setObject:className forKey:@"classname"];
                        [[NSUserDefaults standardUserDefaults] setObject:schoolName forKey:@"schoolname"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.navigationController pushViewController:classZone animated:YES];
                    }
                    
                    else
                    {
                        [Tools showTips:@"未找到任何班级" toView:self.bgView];
                    }
                }
                else
                {
                    [Tools showTips:@"未找到任何班级" toView:self.bgView];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

#pragma mark - 视图周期


-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVENEWNOTICE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    inputTabBar.returnFunDel = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    inputTabBar.returnFunDel = nil;
    [self backInput];
    [adTimer invalidate];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [adTimer fire];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    inputTabBar.returnFunDel = self;
    [self backInput];
    
    
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}

#pragma mark - 代理

-(BOOL)haveNewMsg
{
    NSArray *msgArray = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:CHATTABLE]; //[msgArray count] > 0 ||
    NSArray *friendsArray  =[db findSetWithDictionary:@{@"checked":@"0",@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
    if ([friendsArray count] > 0 || [msgArray count] > 0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue]>0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:UCFRIENDSUM] integerValue] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [self viewWillAppear:NO];
}

-(void)dealNewMsg:(NSDictionary *)dict
{
    [self viewWillAppear:NO];
}
-(BOOL)haveNewNotice
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id],@"type":@"f_apply"} andTableName:@"notice"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 获得网络数据

-(void)getData
{
    if ([Tools NetworkReachable])
    {
        [self getHomeAdCache];
        [self getHomeCache];
        [self getHomeAd];
        [self getHomeData];
        
    }
    else
    {
        [self getHomeAdCache];
        [self getHomeCache];
    }
}

-(void)getHomeData
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if (page == 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token]};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"page":[NSString stringWithFormat:@"%d",page]};
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:HOMEDATA];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"home responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                haveClass = YES;
                if (page == 0)
                {
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOMEDATA,[Tools user_id]];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    [noticeArray removeAllObjects];
                    [diariesArray removeAllObjects];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue] == 0 &&
                    ([diariesArray count] > 0 || [noticeArray count] > 0))
                {
                    page = -1;
                }

                [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
                [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
                
                
                if ([noticeArray count] == 0 && [diariesArray count] == 0)
                {
                    tipLabel.text = @"你所在班级还没有人发布过空间和班级通知";
                    [joinClassButton setTitle:@"发表空间" forState:UIControlStateNormal];
                    [joinClassButton removeTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
                    [joinClassButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton setTitle:@"发布通知" forState:UIControlStateNormal];
                    [createClassButton removeTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
                    
                    tipView.hidden = NO;
                    if ([adArray count] > 0)
                    {
                        tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
                    }
                }
                else
                {
                    [tipView removeFromSuperview];
                }
                [self groupByTime:diariesArray];
                addButton.hidden = NO;
            }
            else
            {
                [noticeArray removeAllObjects];
                [diariesArray removeAllObjects];
                [groupDiaries removeAllObjects];
                
                if ([[[[responseDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_CLASS"])
                {
                    [joinClassButton setTitle:@"加入班级" forState:UIControlStateNormal];
                    [joinClassButton removeTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
                    [joinClassButton addTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
                    [createClassButton removeTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];

                    [classTableView reloadData];
                    
                    addButton.hidden = YES;
                    
                    [self loadIntroduceTip];
                    tipView.hidden = NO;
                    if ([adArray count] > 0)
                    {
                        tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
                    }
                    return ;
                }
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            _reloading = NO;
            [egoheaderView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            if (page > 0)
            {
                if (footerView)
                {
                    [footerView removeFromSuperview];
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                else
                {
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            }

        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }

}
-(void)getHomeAd
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:HOME_AD];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"home ad responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"ad"] isKindOfClass:[NSArray class]])
                {
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOME_AD,[Tools user_id]];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    [adArray removeAllObjects];
                    [adArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"ad"]];
                    HeaderCellHeight = SCREEN_WIDTH * [[[responseDict objectForKey:@"data"] objectForKey:@"scale"] floatValue];
                    if(adTimer)
                    {
                        [adTimer invalidate];
                    }
                    if ([adArray count] > 1)
                    {
                        adTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(switchAd) userInfo:nil repeats:YES];
                    }
                    [classTableView reloadData];
                    if ([adArray count] > 0)
                    {
                        tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
                    }

                }
            }
            else
            {
//                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}

-(void)getHomeAdCache
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOME_AD,[Tools user_id]];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        [adArray removeAllObjects];
        [adArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"ad"]];
        HeaderCellHeight = SCREEN_WIDTH * [[[responseDict objectForKey:@"data"] objectForKey:@"scale"] floatValue];
        if(adTimer)
        {
            [adTimer invalidate];
        }
        if ([adArray count] > 1)
        {
            adTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(switchAd) userInfo:nil repeats:YES];
        }
        [classTableView reloadData];
        if ([adArray count] > 0)
        {
            tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
        }
    }
}

-(void)getHomeCache
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOMEDATA,[Tools user_id]];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
            [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
            
            if ([noticeArray count] == 0 && [diariesArray count] == 0)
            {
                tipLabel.text = @"你所在班级还没有人发布过空间和班级通知";
                [joinClassButton setTitle:@"发表空间" forState:UIControlStateNormal];
                [joinClassButton removeTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
                [joinClassButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
                [createClassButton setTitle:@"发布通知" forState:UIControlStateNormal];
                [createClassButton removeTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
                [createClassButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
                tipView.hidden = NO;
                if ([adArray count] > 0)
                {
                    tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
                }
            }
            if ([diariesArray count] > 0)
            {
                [self groupByTime:diariesArray];
            }
        }
        else
        {
            [noticeArray removeAllObjects];
            [diariesArray removeAllObjects];
            [groupDiaries removeAllObjects];
            
            if ([[[[responseDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_CLASS"])
            {
                if (![Tools NetworkReachable])
                {
                    [joinClassButton setTitle:@"加入班级" forState:UIControlStateNormal];
                    [joinClassButton removeTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
                    [joinClassButton addTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
                    [createClassButton removeTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
                    [createClassButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
                    [classTableView reloadData];
                    
                    if (![Tools NetworkReachable])
                    {
                        [self loadIntroduceTip];
                        tipView.hidden = NO;
                        if ([adArray count] > 0)
                        {
                            tipView.frame = CGRectMake(10, HeaderCellHeight+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 300);
                        }
                    }
                }
                return ;
            }
            [Tools dealRequestError:responseDict fromViewController:nil];
            
            
        }
        
        _reloading = NO;
        [egoheaderView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
        [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
        if (page > 0)
        {
            if (footerView)
            {
                [footerView removeFromSuperview];
                footerView = [[FooterView alloc] initWithScrollView:classTableView];
                footerView.delegate = self;
            }
            else
            {
                footerView = [[FooterView alloc] initWithScrollView:classTableView];
                footerView.delegate = self;
            }
            _reloading = NO;
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
        }
    }
}
#pragma mark - getNetdata
-(void)getDiaryDetail:(NSString *)dongtaiId inSection:(NSInteger)section  index:(NSInteger)index
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId
                                                                      } API:GETDIARY_DETAIL];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diary detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithDictionary:[groupDiaries objectAtIndex:section]];
                NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:[groupDict objectForKey:@"diaries"]];
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:[responseDict objectForKey:@"data"]];
                NSDictionary *oldDiaryDict = [tmpArray objectAtIndex:index];
                [tmpDict setObject:[oldDiaryDict objectForKey:@"c_id"] forKey:@"c_id"];
                [tmpDict setObject:[oldDiaryDict objectForKey:@"c_name"] forKey:@"c_name"];
                [tmpArray replaceObjectAtIndex:index withObject:tmpDict];
                [groupDict setObject:tmpArray forKey:@"diaries"];
                [groupDiaries replaceObjectAtIndex:section withObject:groupDict];
                [classTableView reloadData];
                
                waitCommentIndex = 0;
                waitCommentSection = 0;
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

#pragma mark - 评论日志
-(void)myReturnFunction
{
    DDLOG(@"comment content in home %@",inputTabBar.inputTextView.text);
    if ([[inputTabBar analyString:inputTabBar.inputTextView.text] length] <= 0)
    {
        [Tools showAlertView:@"请输入评论内容！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[waitCommentDict objectForKey:@"_id"],
                                                                      @"c_id":[waitCommentDict objectForKey:@"c_id"],
                                                                      @"content":[inputTabBar analyString:inputTabBar.inputTextView.text]
                                                                      } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getDiaryDetail:[waitCommentDict objectForKey:@"_id"] inSection:waitCommentSection index:waitCommentIndex];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }

    
    inputSize = CGSizeMake(250, 30);
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
    }];
}


#pragma mark - 下拉刷新
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = 0;
    [self getHomeData];
    [self getHomeAd];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    if (page == -1)
    {
        [Tools showAlertView:@"没有更多数据了" delegateViewController:nil];
        return ;
    }
    page ++;
    [self getHomeData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [egoheaderView egoRefreshScrollViewDidScroll:classTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classTableView];
    }
    [self backInput];
    [inputTabBar backKeyBoard];
}
-(void)backInput
{
    [classTableView removeGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, inputSize.height+10);
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [egoheaderView egoRefreshScrollViewDidEndDragging:classTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classTableView];
}


-(void)addNotice
{
    AddNotificationViewController *addnotification = [[AddNotificationViewController alloc] init];
    addnotification.fromClass = NO;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addnotification animated:YES];
}
-(void)addDongtai
{
    AddDongTaiViewController *addDongtaiViewController = [[AddDongTaiViewController alloc] init];
    addDongtaiViewController.fromCLass = NO;
    addDongtaiViewController.classZoneDelegate = self;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addDongtaiViewController animated:YES];
}

-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        page = 0;
        [self getHomeData];
    }
}


#pragma mark - 首页列表
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [noticeArray count] + [groupDiaries count] + 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(shoudShowTipView)
    {
        return 0;
    }
    else if(section == 0)
    {
        return 0;
    }
    else if(section -1 == [noticeArray count] && [noticeArray count] > 0)
    {
        return 32;
    }
    else
    {
        return 32;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
    headerLabel.textColor = COMMENTCOLOR;
    if ((section-1 < [noticeArray count]) && section > 0 && [noticeArray count] > 0)
    {
        NSDictionary *noticeDict = [noticeArray objectAtIndex:section-1];
        headerLabel.text = [NSString stringWithFormat:@"    %@未读通知",[noticeDict objectForKey:@"name"]];
        headerLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
        headerLabel.font = [UIFont systemFontOfSize:15.5];
    }
    else if ((section-1 == [noticeArray count]) && [groupDiaries count] > 0)
    {

        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = @"    班级空间";
        headerLabel.font = [UIFont boldSystemFontOfSize:15];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32);
    }
    else if(section-1 > [noticeArray count])
    {
        
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(34.75, 0, 1.5, 32)];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [headerView addSubview:verticalLineView];
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(28, 7.5, 15, 15)];
        dotView.layer.cornerRadius = 7.5;
        dotView.clipsToBounds = YES;
        dotView.layer.borderColor = [UIColor whiteColor].CGColor;
        dotView.layer.borderWidth = 1.5;
        dotView.backgroundColor = RGB(64, 196, 110, 1);
        [headerView addSubview:dotView];
        NSDictionary *groupDict = [groupDiaries objectAtIndex:section-[noticeArray count]-2];
        headerLabel.text = [groupDict objectForKey:@"date"];
        headerLabel.font = [UIFont systemFontOfSize:15];
        headerLabel.frame = CGRectMake(50, 0, SCREEN_WIDTH, 32);
        
    }
    [headerView addSubview:headerLabel];
    if (shoudShowTipView)
    {
        return nil;
    }
    else if (section == 0)
    {
        return nil;
    }
    else
        return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section > 0 && (section-1 < [noticeArray count]) && [noticeArray count] > 0)
    {
        NSArray *tmpArray = [[noticeArray objectAtIndex:section-1] objectForKey:@"news"];
        return [tmpArray count];
    }
    else if (section-1 > [noticeArray count] && [groupDiaries count] > 0)
    {
        NSDictionary *groupDict = [groupDiaries objectAtIndex:section-[noticeArray count]-2];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        return [tmpArray count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if ([adArray count] > 0 &&
            [[NSUserDefaults standardUserDefaults] objectForKey:@"showad"] &&
            [[[NSUserDefaults standardUserDefaults] objectForKey:@"showad"] intValue] == 1)
        {
            return HeaderCellHeight;
        }
        else
            return 0;
    }
    else if (indexPath.section-1 < [noticeArray count] && [noticeArray count]> 0)
    {
        NSArray *tmpArray = [[noticeArray objectAtIndex:indexPath.section-1] objectForKey:@"news"];
        if (indexPath.row == [tmpArray count]-1)
        {
            return 88+4;
        }
        return 88;
    }
    else if(indexPath.section > 0 && [groupDiaries count] > 0)
    {
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-2];
        
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];
    }
    return 0;
}

#pragma mark - 广告开关

-(void)switchAd
{
    if ([adArray count] > 1)
    {
        [UIView animateWithDuration:0.2 animations:^{
            if (((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset.x == (SCREEN_WIDTH * ([adArray count]-1)))
            {
                ((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset = CGPointZero;
            }
            else
            {
                CGPoint currentOffset = ((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset;
                ((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset = CGPointMake(currentOffset.x+SCREEN_WIDTH, 0);
            }
            ((UIPageControl *)[classTableView viewWithTag:AdPageControlTag]).currentPage = ((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset.x/SCREEN_WIDTH;
        }];
    }
}

-(void)closeAd
{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"showad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [adTimer invalidate];
    [classTableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        ADHeaderCell *cell = [[ADHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"adheadercell"];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"showad"] intValue] == 0 || [adArray count] == 0)
        {
            return cell;
        }
        
        cell.headerDel = self;
        cell.headerScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH,HeaderCellHeight);
        
        cell.headerScrollView.backgroundColor = [UIColor grayColor];
        cell.headerScrollView.pagingEnabled = YES;
        cell.headerScrollView.bounces = NO;
        cell.headerScrollView.showsHorizontalScrollIndicator = NO;
        cell.headerScrollView.tag = AdScrollViewTag;
        cell.headerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*[adArray count], HeaderCellHeight);
        cell.headerScrollView.hidden = NO;
        
        for (int i=0; i<[adArray count]; i++)
        {
            NSDictionary *dict = [adArray objectAtIndex:i];
            UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*i, 0, SCREEN_WIDTH, HeaderCellHeight)];
            
//            [headImageView setImageWithURL:[dict objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"3100"]];
            
            [Tools fillImageView:headImageView withImageFromURL:[dict objectForKey:@"img"] imageWidth:SCREEN_WIDTH andDefault:@"3100"];
            
            UITapGestureRecognizer *headerTapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageClick)];
            headImageView.userInteractionEnabled = YES;
            [headImageView addGestureRecognizer:headerTapTgr];
            [cell.headerScrollView addSubview:headImageView];
        }
        
        cell.closeAd.frame = CGRectMake(SCREEN_WIDTH-40, 0, 40, 40);
        [cell.closeAd addTarget:self action:@selector(closeAd) forControlEvents:UIControlEventTouchUpInside];
//        cell.closeAd.layer.cornerRadius = 10;
        [cell.closeAd setImage:[UIImage imageNamed:@"ad_pause_close"] forState:UIControlStateNormal];
        cell.closeAd.backgroundColor = [UIColor clearColor];
        cell.closeAd.clipsToBounds = YES;
        cell.closeAd.hidden = NO;
        
        cell.headerPageControl.frame = CGRectMake(0, cell.headerScrollView.frame.size.height-30, SCREEN_WIDTH, 30);
        cell.headerPageControl.numberOfPages = [adArray count];
        cell.headerPageControl.tag = AdPageControlTag;
        cell.headerPageControl.backgroundColor = [UIColor clearColor];
        cell.headerPageControl.currentPageIndicatorTintColor = [UIColor redColor];
        cell.headerPageControl.pageIndicatorTintColor = TITLE_COLOR;
        if([adArray count] > 0)
        {
            cell.headerPageControl.hidden = NO;
        }
        
        return cell;
    }
    else if (indexPath.section-1 < [noticeArray count] && [noticeArray count] > 0)
    {
        static NSString *notiCell = @"homenotiCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
        if (cell == nil)
        {
            cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
        }
        
        NSDictionary *noticeDict = [noticeArray objectAtIndex:indexPath.section-1];
        NSArray *tmpArray = [noticeDict objectForKey:@"news"];
        
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
        NSString *byName = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        CGFloat he = 0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
        
        NSString *noticeContent = [dict objectForKey:@"content"];
        CGSize size = [Tools getSizeWithString:noticeContent andWidth:SCREEN_WIDTH-80 andFont:[UIFont systemFontOfSize:16]];
        
        CGFloat height = size.height>40?40:size.height;
        
        [cell.bgImageView setImage:[UIImage imageNamed:@"noticeBg"]];
        cell.bgImageView.layer.cornerRadius = 10;
        cell.bgImageView.clipsToBounds = YES;
        cell.bgImageView.frame = CGRectMake(8, 4, SCREEN_WIDTH-16, 80);
        
        NSRange range = [noticeContent rangeOfString:@"$!#"];
        if (range.length > 0)
        {
            noticeContent = [noticeContent substringFromIndex:range.location+range.length];
        }
        cell.contentLabel.text = noticeContent;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.contentLabel.font = [UIFont systemFontOfSize:16];
        cell.contentLabel.textColor = CONTENTCOLOR;
        cell.contentLabel.contentMode = UIViewContentModeTop;
        cell.contentLabel.frame = CGRectMake(40, 15, SCREEN_WIDTH-62, height);
        
       
        
        cell.statusLabel.textColor = COMMENTCOLOR;
        cell.statusLabel.frame = CGRectMake(SCREEN_WIDTH-150, 60.5, 130, 15);
        
        cell.timeLabel.frame = CGRectMake(40, 58, 240, 20);
        cell.timeLabel.font = [UIFont systemFontOfSize:12];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@发布于%@",byName,[Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]]];
        cell.timeLabel.textColor = COMMENTCOLOR;
        
         cell.iconImageView.frame = CGRectMake(20, 17, 12, 12);
//        [cell.iconImageView setImage:[UIImage imageNamed:@"unreadicon"]];
        cell.iconImageView.layer.cornerRadius = 6;
        cell.iconImageView.clipsToBounds = YES;
        cell.iconImageView.backgroundColor = RGB(228, 76, 76, 1);
        cell.iconImageView.layer.borderColor = RGB(227, 63, 64, 1).CGColor;
        cell.iconImageView.layer.borderWidth = 1;
        
        cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if(indexPath.section > 0 && [groupDiaries count] > 0)
    {
        static NSString *topImageView = @"hometrendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        cell.showAllComments = NO;
        cell.nameButtonDel = self;
        
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-2];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        cell.diaryDetailDict = dict;
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        NSString *role = [[dict objectForKey:@"by"] objectForKey:@"role"];
        
        
        NSString *nameStr;
        if (role)
        {
            if ([role isEqualToString:@"teachers"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"老师"];
            }
            else if([role isEqualToString:@"parents"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"家长"];
            }
            else if([role isEqualToString:@"students"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"学生"];
            }
            else
            {
                nameStr = name;
            }
        }
        else
        {
            nameStr = name;
        }
        
        
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.locationLabel.hidden = NO;
        cell.praiseButton.hidden = NO;
        cell.commentButton.hidden = NO;
        cell.transmitButton.hidden = NO;
        cell.contentTextField.hidden = YES;
        
        cell.headerImageView.tag = SectionTag * indexPath.section + indexPath.row;
        cell.headerImageView.frame = CGRectMake(12, 12, 31, 31);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageViewClicked:)];
        cell.headerImageView.userInteractionEnabled = YES;
        [cell.headerImageView addGestureRecognizer:tap];
        
        cell.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
        
        cell.nameLabel.frame = CGRectMake(50, cell.headerImageView.frame.origin.y-6, [nameStr length]*18>170?170:([nameStr length]*18), 25);
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = DongTaiNameColor;
        
        NSString *timeStr = [Tools showTimeOfToday:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        NSString *c_name = [dict objectForKey:@"c_name"];
        cell.timeLabel.text = c_name;
        cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH-200-25, 2, 200, 35);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.numberOfLines = 2;
        cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.timeLabel.textColor = COMMENTCOLOR;
        
        cell.headerImageView.backgroundColor = [UIColor clearColor];
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] imageWidth:62 andDefault:HEADERICON];
        
        cell.locationLabel.frame = CGRectMake(50, cell.headerImageView.frame.origin.y+cell.headerImageView.frame.size.height-LOCATIONLABELHEI+3, SCREEN_WIDTH-90, LOCATIONLABELHEI);
        if ([[dict objectForKey:@"detail"] objectForKey:@"add"] &&
            [[[dict objectForKey:@"detail"] objectForKey:@"add"] length] > 0)
        {
            cell.locationLabel.text = [NSString stringWithFormat:@"于%@在%@",timeStr,[[dict objectForKey:@"detail"] objectForKey:@"add"]];
        }
        else
        {
            cell.locationLabel.text = [NSString stringWithFormat:@"%@",timeStr];
        }
        
        cell.locationLabel.numberOfLines = 1;
        cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        
        cell.contentLabel.hidden = YES;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        
        int cha = [noticeArray count]+1;
        
        for(UIView *v in cell.imagesView.subviews)
        {
            if ([v isKindOfClass:[UIImageView class]])
            {
                [v removeFromSuperview];
            }
        }
        if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0)
        {
            //有文字
            NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
            
            CGSize contentSize = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-DongTaiHorizantolSpace*2-16 andFont:DONGTAI_CONTENT_FONT];
            
            if (contentSize.height > 45)
            {
                cell.contentLabel.frame = CGRectMake(11, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y + DongTaiSpace, SCREEN_WIDTH-DongTaiHorizantolSpace*2-16, 45);
            }
            else
            {
                cell.contentLabel.frame = CGRectMake(11, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y + DongTaiSpace, SCREEN_WIDTH-DongTaiHorizantolSpace*2-16, contentSize.height+10);
            }
            
            UITapGestureRecognizer *contentLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
            cell.contentLabel.userInteractionEnabled = YES;
            [cell.contentLabel addGestureRecognizer:contentLabelTap];
            cell.contentLabel.font = [UIFont systemFontOfSize:15];
            cell.contentLabel.hidden = NO;
            cell.contentLabel.tag = SectionTag * indexPath.section + indexPath.row;
            cell.contentLabel.textColor = CONTENTCOLOR;
            
            if ([content length] > 40)
            {
                cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[content substringToIndex:37]];
            }
            else
            {
                cell.contentLabel.text = content;
            }
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(6, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y, 0, 0);
        }
        
        CGFloat imageViewHeight = ImageHeight;
        CGFloat imageViewWidth = ImageHeight;
        NSArray *tmpArray1 = [[dict objectForKey:@"detail"] objectForKey:@"img"];
        if ([tmpArray1 count] > 0)
        {
            //有图片
            
            NSArray *imgsArray = [[dict objectForKey:@"detail"] objectForKey:@"img"];
            NSInteger imageCount = [imgsArray count];
            NSInteger row = 0;
            if (imageCount % ImageCountPerRow > 0)
            {
                row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
            }
            else
            {
                row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
            }
            if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0)
            {
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.contentLabel.frame.size.height + cell.contentLabel.frame.origin.y+DongTaiSpace,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
            }
            else
            {
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.headerImageView.frame.size.height + cell.headerImageView.frame.origin.y+DongTaiSpace,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
            }
            
            
            for (int i=0; i<[imgsArray count]; ++i)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
                imageView.userInteractionEnabled = YES;
                imageView.tag = (indexPath.section-[noticeArray count]-2)*SectionTag+indexPath.row*RowTag+i+333;
                
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] imageWidth:100.0f andDefault:@"3100"];
                [cell.imagesView addSubview:imageView];
            }
        }
        else
        {
            cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
        }
        
        CGFloat cellHeight = 0 ;
        
        if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0 &&
            [tmpArray1 count] == 0)
        {
            cellHeight = cell.contentLabel.frame.size.height + cell.contentLabel.frame.origin.y + DongTaiSpace;
        }
        else
        {
             cellHeight = cell.imagesView.frame.size.height + cell.imagesView.frame.origin.y + DongTaiSpace;
        }
        
        //评论,赞，转发
        CGFloat buttonHeight = 37;
        CGFloat iconH = 18;
        CGFloat iconTop = 9;
        
        
        cell.transmitButton.frame = CGRectMake(0, cellHeight, (SCREEN_WIDTH-DongTaiHorizantolSpace*2)/3, buttonHeight);
        [cell.transmitButton setTitle:@"      转发" forState:UIControlStateNormal];
        cell.transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        cell.transmitButton.tag = (indexPath.section-cha-1)*SectionTag+indexPath.row;
        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitButton.iconImageView.frame = CGRectMake(24, iconTop+1, iconH, iconH);
        cell.transmitButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"      %d",[[dict objectForKey:@"likes_num"] intValue]] forState:UIControlStateNormal];
        }
        else
        {
            [cell.praiseButton setTitle:@"     赞" forState:UIControlStateNormal];
        }
        if ([self havePraisedThisDiary:dict])
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"praised"];
            cell.praiseButton.iconImageView.frame = CGRectMake(34, iconTop+1, iconH, iconH);
        }
        else
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"icon_heart"];
            cell.praiseButton.iconImageView.frame = CGRectMake(33, iconTop+1, iconH, iconH);
        }
        
        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = (indexPath.section-cha-1)*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-DongTaiHorizantolSpace*2)/3, cellHeight, (SCREEN_WIDTH-DongTaiHorizantolSpace*2)/3, buttonHeight);
        cell.praiseButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            [cell.commentButton setTitle:[NSString stringWithFormat:@"      %d",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(31, iconTop, iconH, iconH);
        }
        else
        {
            [cell.commentButton setTitle:@"     评论" forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-DongTaiHorizantolSpace*2)/3*2, cellHeight, (SCREEN_WIDTH-DongTaiHorizantolSpace*2)/3, buttonHeight);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        cell.commentButton.tag = (indexPath.section-cha-1)*SectionTag+indexPath.row;
        cell.diaryIndexPath = [NSIndexPath indexPathForRow:cell.commentButton.tag%SectionTag inSection:cell.commentButton.tag/SectionTag];
        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.geduan1.hidden = NO;
        cell.geduan2.hidden = NO;
        
        cell.geduan1.frame = CGRectMake(cell.transmitButton.frame.size.width+cell.transmitButton.frame.origin.x, cell.transmitButton.frame.origin.y+9.5, 1, 18);
        cell.geduan2.frame = CGRectMake(cell.praiseButton.frame.size.width+cell.praiseButton.frame.origin.x, cell.praiseButton.frame.origin.y+9.5, 1, 18);
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0 || [dict objectForKey:@"likes_num"] > 0)
        {
            NSArray *comArray = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            if ([comArray count] > 0)
            {
                cell.commentsArray = comArray;
            }
            else
            {
                cell.commentsArray = nil;
            }
            NSArray *praiseArray = [[dict objectForKey:@"detail"] objectForKey:@"likes"];
            if ([praiseArray count] > 0)
            {
                cell.praiseArray = praiseArray;
            }
            else
            {
                cell.praiseArray = nil;
            }
            [cell.commentsTableView reloadData];
            cell.commentsTableView.frame = CGRectMake(0, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y, SCREEN_WIDTH, cell.commentsTableView.contentSize.height);
            cell.bgView.frame = CGRectMake(DongTaiHorizantolSpace, 0, SCREEN_WIDTH-DongTaiHorizantolSpace*2,
                                           cell.commentsTableView.frame.size.height+
                                           cell.commentsTableView.frame.origin.y);
        }
        else
        {
            cell.commentsArray = nil;
            cell.praiseArray = nil;
            [cell.commentsTableView reloadData];
            cell.bgView.frame = CGRectMake(DongTaiHorizantolSpace, 0, SCREEN_WIDTH-DongTaiHorizantolSpace*2,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
        }
        
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
        cell.verticalLineView.frame = CGRectMake(34.75, 0, 1.5, cellFrame.size.height);
        
        return cell;
    }
    return nil;
}

#pragma mark - 点击幻灯片
-(void)headerImageClick
{
    NSDictionary *dict = [adArray objectAtIndex:((UIScrollView *)[classTableView viewWithTag:AdScrollViewTag]).contentOffset.x/SCREEN_WIDTH];
    NSURL *url = [NSURL URLWithString:[dict objectForKey:@"href"]];
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}
-(void)getHeaderIndex:(ADHeaderCell *)cell andIndex:(int)headerIndex
{
    headerNewsIndex = headerIndex;
}

-(void)headerImageViewClicked:(UITapGestureRecognizer *)tap
{
    int section = ((tap.view.tag)/SectionTag-1)-[noticeArray count];
    int row = (tap.view.tag)%SectionTag;
    NSDictionary *groupDict = [groupDiaries objectAtIndex:section-1];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:row];
    PersonDetailViewController *personDetail = [[PersonDetailViewController alloc] init];
    personDetail.personID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
    personDetail.personName = [[dict objectForKey:@"by"] objectForKey:@"name"];
    personDetail.headerImg = [[dict objectForKey:@"by"] objectForKey:@"img_icon"];
    [self.navigationController pushViewController:personDetail animated:YES];
}

-(void)toDetail:(UITapGestureRecognizer *)tap
{
    int section = ((tap.view.tag)/SectionTag-1)-[noticeArray count];
    int row = (tap.view.tag)%SectionTag;
    NSDictionary *groupDict = [groupDiaries objectAtIndex:section-1];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:row];
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"c_id"] forKey:@"classid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //        dongtaiDetailViewController.addComDel = self;
    [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

-(BOOL)havePraisedThisDiary:(NSDictionary *)diaryDict1
{
    NSArray *praiseArray = [[diaryDict1 objectForKey:@"detail"] objectForKey:@"likes"];
    for (int i = 0; i < [praiseArray count]; i++)
    {
        NSDictionary *dict = [praiseArray objectAtIndex:i];
        if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            return YES;
        }
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0 && indexPath.section-1 < [noticeArray count])
    {
        NSDictionary *classNoticeDict = [noticeArray objectAtIndex:indexPath.section-1];
        [[NSUserDefaults standardUserDefaults] setObject:[classNoticeDict objectForKey:@"_id"] forKey:@"classid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary *dict = [[[noticeArray objectAtIndex:indexPath.section-1] objectForKey:@"news"] objectAtIndex:indexPath.row];
        NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
        notificationDetailViewController.noticeDict = dict;
        notificationDetailViewController.c_read = @"1";
        notificationDetailViewController.readnotificationDetaildel = self;
        notificationDetailViewController.isnew = YES;
        notificationDetailViewController.fromClass = NO;
        [self.navigationController pushViewController:notificationDetailViewController animated:YES];
        currentIndexPath = indexPath;
    }
    else
    {
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-2];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
        dongtaiDetailViewController.fromclass = NO;
        dongtaiDetailViewController.addComDel = self;
        
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"c_id"] forKey:@"classid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        dongtaiDetailViewController.addComDel = self;
        [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
    }
}

-(void)readNotificationDetail:(NSDictionary *)noticeDict deleted:(BOOL)deleted
{
    page = 0;
    [self getHomeData];
//    NSMutableDictionary *tmpNoticeDict = [noticeArray objectAtIndex:currentIndexPath.section-1];
//    NSMutableArray *tmpArray = [tmpNoticeDict objectForKey:@"news"];
//    [tmpArray removeObjectAtIndex:currentIndexPath.row];
//    [tmpNoticeDict setObject:tmpArray  forKey:@"news"];
//    [noticeArray replaceObjectAtIndex:currentIndexPath.section-1 withObject:tmpNoticeDict];
//    [classTableView reloadData];
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if ([inputTabBar.inputTextView isFirstResponder])
    {
        [self backInput];
        [inputTabBar backKeyBoard];
    }
    
    NSDictionary *groupDict = [groupDiaries objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [[dict objectForKey:@"detail"] objectForKey:@"img"];
    NSMutableArray *smallImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *imageUrl in imgs)
    {
        NSString *smallUrlStr = [NSString stringWithFormat:@"%@100w",imageUrl];
        [smallImageArray addObject:smallUrlStr];
    }
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<[imgs count]; i++)
    {
//        NSString *url = [imgs[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSString *url = [NSString stringWithFormat:@"%@%@",IMAGEURL,imgs[i]];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.srcImageView = (UIImageView *)tap.view;
        [photos addObject:photo];
    }
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = photos;
    photoBroser.currentPhotoIndex = (tap.view.tag-333)%SectionTag%RowTag;
    [photoBroser show];
}

#pragma mark - 赞

-(void)praiseDiary:(UIButton *)button
{
    [self backInput];
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%SectionTag];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[dict objectForKey:@"_id"],
                                                                      @"c_id":[dict objectForKey:@"c_id"],
                                                                      } API:LIKE_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getDiaryDetail:[dict objectForKey:@"_id"] inSection:button.tag/SectionTag index:button.tag%SectionTag];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}

-(void)addComment:(BOOL)add
{
    if (add)
    {
        [self getHomeData];
    }
}

#pragma mark - 评论按钮评论日志
-(void)commentDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    waitCommentDict = [tmpArray objectAtIndex:button.tag%SectionTag];
    waitCommentSection = button.tag/SectionTag;
    waitCommentIndex = button.tag%SectionTag;
    [inputTabBar.inputTextView becomeFirstResponder];
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [classTableView addGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        tmpheight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + tmpheight);
    }
    else if([changeType isEqualToString:@"key"])
    {
        tmpheight = inputSize.height;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + tmpheight);
    }
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+tmpheight);
    }];
}


-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [groupDiaries removeAllObjects];
    for (int i=index; i<[array count]; i++)
    {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([dict isEqual:[NSNull null]])
        {
            continue ;
        }
        CGFloat sec = [[[dict objectForKey:@"created"] objectForKey:@"sec"] floatValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        timeStr = [dateFormatter stringFromDate:datetimeDate];
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [groupDict setObject:timeStr forKey:@"date"];
        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
        [array2 addObject:dict];
        
        for (int j=i+1; j<[array count]; j++)
        {
            NSDictionary *dict2 = [array objectAtIndex:j];
            if ([dict2 isEqual:[NSNull null]])
            {
                continue;
            }
            CGFloat sec2 = [[[dict2 objectForKey:@"created"] objectForKey:@"sec"] floatValue];
            NSDate *datetimeDate2 = [NSDate dateWithTimeIntervalSince1970:sec2];
            NSString * timeStr2 = [dateFormatter stringFromDate:datetimeDate2];
            if ([timeStr2 isEqualToString:timeStr])
            {
                [array2 addObject:dict2];
            }
            else
            {
                index = j;
                break;
            }
        }
        if ([array2 count] > 0)
        {
            if (![self haveThisTime:timeStr])
            {
                [groupDict setObject:array2 forKey:@"diaries"];
                [groupDiaries addObject:groupDict];
            }
        }
    }

    [classTableView reloadData];
    
//    [ImageTools convertViewToImage:classTableView inViewController:self];
    
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[groupDiaries count]; i++)
    {
        NSDictionary *dict = [groupDiaries objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(void)addButtonClick
{
    if (addOpen)
    {
        //close
        [self closeAdd];
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }
    else
    {
        //open
        [self openAdd];
        self.navigationController.sideMenuController.panGestureEnabled = NO;
        self.navigationController.sideMenuController.tapGestureEnabled = NO;
    }
    addOpen = !addOpen;
}

-(void)openAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.alpha = 1;
        addNoticeButton.alpha = 1;
        addDiaryButton.alpha = 1;
        qrCodeButton.alpha = 1;
        classTableView.userInteractionEnabled = NO;
    }];
    
}

-(void)closeAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addNoticeButton.alpha = 0;
        addDiaryButton.alpha = 0;
        addView.alpha = 0;
        qrCodeButton.alpha = 0;
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
        classTableView.userInteractionEnabled = YES;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        if(!CGRectContainsPoint(addView.frame, [t locationInView:addView]))
        {
            if (addOpen)
            {
                addOpen = NO;
                [self closeAdd];
            }
        }
    }
}


-(void)moreOpen
{
    [self backInput];
    if (![[self.navigationController sideMenuController] isMenuVisible])
    {
        [[self.navigationController sideMenuController] showMenuAnimated:YES];
    }
    else
    {
        [[self.navigationController sideMenuController] hideMenuAnimated:YES];
    }
}

-(void)transmitDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    diaryDict = [array objectAtIndex:button.tag%SectionTag];
    waitTransmitDict = [[array objectAtIndex:button.tag%SectionTag] objectForKey:@"detail"];
    [self shareAPP:nil];
}
//-(void)nameButtonClick:(NSDictionary *)dict
//{
//    DDLOG(@"person dict %@",dict);
//    PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
//    personDetailVC.personName = [[dict objectForKey:@"by"] objectForKey:@"name"];
//    personDetailVC.personID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
//    [self.sideMenuController hideMenuAnimated:YES];
//    [self.navigationController pushViewController:personDetailVC animated:YES];
//}

-(void)nameButtonClick:(NSDictionary *)dict
{
    
    DDLOG(@"home %@",dict);
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"c_id"] forKey:@"classid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //        dongtaiDetailViewController.addComDel = self;
    [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

#pragma mark - 点击评论，评论日志

-(void)cellCommentDiary:(NSDictionary *)dict andIndexPath:(NSIndexPath *)indexPath
{
    waitCommentIndex = indexPath.row;
    waitCommentSection = indexPath.section;
    waitCommentDict = dict;
    [inputTabBar.inputTextView becomeFirstResponder];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [self backInput];
}

#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    [self backInput];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"waittransdict %@",waitTransmitDict);
    waitDiaryID = [diaryDict objectForKey:@"_id"];
    switch (buttonIndex)
    {
        case 0:
            [self shareToSinaWeiboClickHandler:nil];
            break;
        case 1:
            [self shareToQQSpaceClickHandler:nil];
            break;
        case 2:
            [self shareToTencentWeiboClickHandler:nil];
            break;
        case 3:
            [self shareToQQFriendClickHandler:nil];
            break;
        case 4:
            [self shareToWeixinTimelineClickHandler:nil];
            break;
        case 5:
            [self shareToRenRenClickHandler:nil];
            break;
        default:
            break;
    }
}

/**
 *	@brief	分享到QQ空间
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQSpaceClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@@150w",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:ShareContent
                                                image:(imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath])
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQSpace
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToSinaWeiboClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@@80w",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    //创建分享内容[ShareSDK imageWithUrl:imagePath]
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:ShareContent
                                                image:(imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath])
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到腾讯微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToTencentWeiboClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:ShareContent
                                                image:(imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath])
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeTencentWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@") , [error errorCode], [error errorDescription]);
                                 }
                             }];
}
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@@80w",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    //创建分享内容
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                       defaultContent:@""
                                                image:(imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath])
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQ
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享给微信朋友圈
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToWeixinTimelineClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@@150w",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    DDLOG(@"image path %@",imagePath);
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:[NSString stringWithFormat:@"%@-%@",content,ShareContent]
                                                  url:HOST_URL
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到人人网
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToRenRenClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        NSArray *tmpArray = [waitTransmitDict objectForKey:@"img"];
        if ([tmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:(imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath])
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?[NSString stringWithFormat:@"%@-%@",content,ShareContent]:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //    //创建弹出菜单容器
    //    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeRenren
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:waitDiaryID];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog( @"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
//        [MMProgressHUD showWithTitle:@"Title" status:@"Custom Animated Image" images:nil];
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MMProgressHUD dismissWithSuccess:@"success!"];
//        });
//
//    });

@end