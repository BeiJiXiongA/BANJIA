//
//  PersonalSettingViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "PersonalSettingViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "Header.h"
#include "WelcomeViewController.h"
#import "PersonalSettingCell.h"
#import "AuthCell.h"
#import "PersonInfoSettingViewController.h"
#import "AuthViewController.h"
#import "RelatedCell.h"
#import "LogOutCell.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "ChangePhoneViewController.h"
#import "UINavigationController+JDSideMenu.h"
#import "ClassPlusAccountViewController.h"


@interface PersonalSettingViewController ()<UITableViewDataSource,
UITableViewDelegate,
ChatDelegate,
UITextFieldDelegate,
ChangePhoneNum,
UIAlertViewDelegate,
UIActionSheetDelegate>
{
    UITableView *personalSettiongTableView;
    BOOL isAuth;
    NSMutableDictionary *userInfoDict;
    NSArray *tmpArray;
    BOOL authenticated;
    
    NSDictionary *accountDict;
    
    NSString *qqNickName;
    NSString *sinaNickName;
    NSString *rrNickName;
}
@end

@implementation PersonalSettingViewController

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
	// Do any additional setup after loading the view.
    
    isAuth = YES;
    
    qqNickName = @"";
    rrNickName = @"";
    sinaNickName = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon) name:@"changeicon" object:nil];
    
    userInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    self.titleLabel.text = @"个人信息";
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 0.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    self.returnImageView.hidden = YES;
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setTitle:@"设置" forState:UIControlStateNormal];
    [setButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    setButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [setButton addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:setButton];
    
    [self.backButton setHidden:YES];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    personalSettiongTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    personalSettiongTableView.delegate = self;
    personalSettiongTableView.backgroundView = tableViewBg;
    personalSettiongTableView.backgroundColor = [UIColor clearColor];
    personalSettiongTableView.dataSource = self;
    personalSettiongTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:personalSettiongTableView];
    
    [self getAccount];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [shareButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAPP:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:shareButton];
}

-(void)changeIcon
{
    [personalSettiongTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}


#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
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
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
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
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
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
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
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
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
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
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
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
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:ShareContent
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog( @"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}


- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y);
    }completion:^(BOOL finished) {
        }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (iPhone5)
    {
            self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height+150);
    }
    else
    {
            self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height);
    }
}

#pragma mark - chatdelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}

-(BOOL)haveNewMsg
{
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    if ([array count] > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
-(BOOL)haveNewNotice
{
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id],@"type":@"f_apply"} andTableName:@"notice"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}

-(void)settingClick
{
    SettingViewController *setting = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setting animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 10)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
//        headerLabel.text = @"我的社交账号";
    if (section == 1)
    {
        headerLabel.backgroundColor = [UIColor clearColor];
    }
    else
    {
        headerLabel.backgroundColor = [UIColor clearColor];
    }
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 28;
    }
    else if(section == 2)
    {
        return 21;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else if (section == 1)
    {
        return 2;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return 125;
        }
        else
        {
            return 47;
        }
    }
    else if (indexPath.section == 1)
    {
        if (isAuth)
        {
            if (indexPath.row == 0)
            {
                return 0;
            }
        }
        return 47;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *firstCell = @"firstCell";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstCell];
            }
            cell.nameLabel.frame = CGRectMake(110, 40, 18*[[Tools user_name] length], 30);
            cell.nameLabel.text = [Tools user_name];
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.headerImageView.layer.borderWidth = 2;
            cell.headerImageView.layer.cornerRadius = 41;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.frame = CGRectMake(22, 20, 82, 82);
            [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERBG];
            
            cell.authenticationSign.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+5, cell.nameLabel.frame.origin.y-10, 20, 20);
            
            if ([accountDict objectForKey:@"t_checked"])
            {
                [cell.authenticationSign setImage:[UIImage imageNamed:@"auth"]];
            }
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 53, 10, 20)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(indexPath.row == 1)
        {
            static NSString *authcell = @"section0";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.headerImageView.hidden = YES;
            if (indexPath.row == 1)
            {
                cell.nameLabel.frame = CGRectMake(20, 13, 100, 20);
                cell.nameLabel.textColor = [UIColor blackColor];
                if ([Tools phone_num])
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"班家账号"];
                }
                else
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"绑定手机"];
                    cell.textLabel.textColor = TITLE_COLOR;
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
                    [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 10, 10, 20)];
                }
                
                cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-150, 13, 124, 20);
                cell.objectsLabel.text = [Tools phone_num];
                cell.objectsLabel.font = [UIFont systemFontOfSize:16];
            }
            
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            static NSString *relateCell = @"relateCell";
            RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
            if (cell == nil)
            {
                cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
            }
            cell.relateButton.tag = indexPath.row+1000;
            cell.relateButton.frame = CGRectMake(SCREEN_WIDTH-100, 8.5, 80, 26);
            cell.nametf.frame = CGRectMake(60, 11, 170, 20);
            if (indexPath.row == 2)
            {
                if ([ShareSDK hasAuthorizedWithType:ShareTypeQQSpace])
                {
                    cell.nametf.text = [[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME];
                    [cell.relateButton setTitle:@"解除" forState:UIControlStateNormal];
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    cell.nametf.text = @"";
                    [cell.relateButton setTitle:@"关联" forState:UIControlStateNormal];
                }
                [cell.iconImageView setImage:[UIImage imageNamed:@"QQicon"]];
            }
            else if(indexPath.row == 3)
            {
                if ([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo])
                {
                    cell.nametf.text = [[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME];
                    [cell.relateButton setTitle:@"解除" forState:UIControlStateNormal];
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    cell.nametf.text = @"";
                    [cell.relateButton setTitle:@"关联" forState:UIControlStateNormal];
                }
                [cell.iconImageView setImage:[UIImage imageNamed:@"sinaicon"]];
            }
            else if(indexPath.row == 4)
            {
                if ([ShareSDK hasAuthorizedWithType:ShareTypeRenren])
                {
                    cell.nametf.text = [[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME];
                    [cell.relateButton setTitle:@"解除" forState:UIControlStateNormal];
                     [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    cell.nametf.text = @"";
                    [cell.relateButton setTitle:@"关联" forState:UIControlStateNormal];
                }
                [cell.iconImageView setImage:[UIImage imageNamed:@"renrenicon"]];
            }
            cell.nametf.tag = indexPath.row+333;
            cell.nametf.textColor = [UIColor blackColor];
            cell.nametf.font = [UIFont systemFontOfSize:16];
            cell.nametf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            cell.nametf.enabled = NO;
            
            cell.nametf.returnKeyType = UIReturnKeyDone;
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            static NSString *authcell = @"section0";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.headerImageView.hidden = YES;
            
            if (!isAuth)
            {
                cell.nameLabel.hidden = NO;
                cell.nameLabel.textColor = RGB(254, 136, 0, 1);
                cell.nameLabel.text = @"您尚未进行教师认证";
                cell.nameLabel.frame = CGRectMake(20, 13, 200, 20);
                
                if ([accountDict objectForKey:@"t_checked"])
                {
                    if ([[accountDict objectForKey:@"t_checked"] integerValue] == 0)
                    {
                        cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-100, 13, 80, 20);
                        cell.objectsLabel.text = @"审核被拒绝";
                        cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                    }
                }
                else if ([accountDict objectForKey:@"img_tcard"])
                {
                    if ([[accountDict objectForKey:@"img_tcard"] length] > 10)
                    {
                        cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-100, 13, 80, 20);
                        cell.objectsLabel.text = @"正在审核";
                        cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                    }
                }
            }
            else
                cell.nameLabel.hidden = YES;
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
        else if (indexPath.row == 1)
        {
            static NSString *authcell = @"section2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.textLabel.text = @"设置";
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 10, 10, 20)];
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            PersonInfoSettingViewController *personInfoSettiongViewController = [[PersonInfoSettingViewController alloc] init];
            [self.navigationController pushViewController:personInfoSettiongViewController animated:YES];
        }
        else if(indexPath.row == 1)
        {
            if (![Tools phone_num])
            {
                ChangePhoneViewController *changePhoneNumVC = [[ChangePhoneViewController alloc] init];
                changePhoneNumVC.changePhoneDel = self;
                [self.navigationController pushViewController:changePhoneNumVC animated:YES];
            }
            else
            {
                ClassPlusAccountViewController *classPlusViewController = [[ClassPlusAccountViewController alloc] init];
                [self.navigationController pushViewController:classPlusViewController animated:YES];
            }
        }
        else
        {
            [self bindThirdAccountWithIndex:indexPath.row];
        }
    }
    
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            AuthViewController *authViewController = [[AuthViewController alloc] init];
            if ([accountDict objectForKey:@"img_id"])
            {
                authViewController.img_id = [accountDict objectForKey:@"img_id"];
            }
            else
            {
                authViewController.img_id = @"";
            }
            if ([accountDict objectForKey:@"img_tcard"])
            {
                authViewController.img_tcard = [accountDict objectForKey:@"img_tcard"];
            }
            else
            {
                authViewController.img_tcard = @"";
            }
            [self.navigationController pushViewController:authViewController animated:YES];
        }
        else if (indexPath.row == 1)
        {
            [self settingClick];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - loginAccount
static int loginID;
- (void)clickedThirdLoginButton:(UIButton *)button
{
    [self bindThirdAccountWithIndex:button.tag-1000];
}

-(void)bindThirdAccountWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 2:
            loginID = ShareTypeQQSpace;
            
            break;
        case 3:
            loginID = ShareTypeSinaWeibo;
            
            break;
        case 4:
            loginID = ShareTypeRenren;
            break;
            
        default:
            break;
    }
    
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
    
    [ShareSDK getUserInfoWithType:loginID
                      authOptions:authOptions
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error)
     {
         if (result)
         {
             DDLOG(@"success=%@==%@",[userInfo uid],[userInfo nickname]);
             if (loginID == ShareTypeSinaWeibo)
             {
                 //sina
                 sinaNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"sw" andName:sinaNickName];
                 
             }
             else if(loginID == ShareTypeQQSpace)
             {
                 //qq
                 qqNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"qq" andName:qqNickName];
                 
             }
             else if(loginID == ShareTypeRenren)
             {
                 //ren ren
                 rrNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"rr" andName:rrNickName];
                 
             }
         }
         else
         {
             DDLOG(@"faile==%@",[error errorDescription]);
         }
         
         //                               [ShareSDK cancelAuthWithType:loginID];
     }];
    //                           [ShareSDK cancelAuthWithType:loginID];
}

-(void)cancelAccount:(UIButton *)button
{
    
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要解除绑定吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解除", nil];
    al.tag = button.tag;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        switch (alertView.tag-1000)
        {
            case 0:
            {
                loginID = ShareTypeQQSpace;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:QQNICKNAME];
                break;
            }
            case 1:
            {
                loginID = ShareTypeSinaWeibo;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINANICKNAME];
                break;
            }
            case 2:
            {
                loginID = ShareTypeRenren;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:RRNICKNAME];
                break;
            }
            default:
                break;
        }
        [ShareSDK cancelAuthWithType:loginID];
        [personalSettiongTableView reloadData];
    }
}

-(void)relateAccount:(NSString *)account accountType:(NSString *)accountType andName:(NSString *)name
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"a_id":account,
                                                                      @"a_type":accountType,
                                                                      @"n_name":name
                                                                      } API:BINDACCOUNT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"bind responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"成功绑定" toView:self.bgView];
                if ([accountType isEqualToString:@"sw"])
                {
                    ((UITextField *)[personalSettiongTableView viewWithTag:334]).text = sinaNickName;
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:sinaNickName forKey:SINANICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"qq"])
                {
                    ((UITextField *)[personalSettiongTableView viewWithTag:333]).text = qqNickName;
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    DDLOG(@"udnickname==%@",qqNickName);
                    [ud setObject:qqNickName forKey:QQNICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"rr"])
                {
                    ((UITextField *)[personalSettiongTableView viewWithTag:335]).text = rrNickName;
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:rrNickName forKey:RRNICKNAME];
                    [ud synchronize];
                }
                [personalSettiongTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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

}

#pragma mark - changePhoneNum
-(void)changePhoneNum:(BOOL)changed
{
    if (changed)
    {
        [personalSettiongTableView reloadData];
    }
}

-(void)moreOpen
{
    if (![[self.navigationController sideMenuController] isMenuVisible])
    {
        [[self.navigationController sideMenuController] showMenuAnimated:YES];
    }
    else
    {
        [[self.navigationController sideMenuController] hideMenuAnimated:YES];
    }
}

#pragma mark - getUserInfo
-(void)getAccount
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:GETACCOUNTLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"accountlist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                accountDict = [responseDict objectForKey:@"data"];
                if ([accountDict objectForKey:@"t_checked"])
                {
                    if ([[accountDict objectForKey:@"t_checked"] integerValue] == 1)
                    {
                        isAuth = YES;
                    }
                    else
                    {
                        isAuth = NO;
                    }
                }
                else
                {
                    isAuth = NO;
                }
                [personalSettiongTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
@end
