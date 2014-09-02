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
    
    int gf;
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
    
    gf = 0;
    
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
    setButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [setButton addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:setButton];
    
    [self.backButton setHidden:YES];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, self.backButton.frame.origin.y, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    personalSettiongTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    personalSettiongTableView.delegate = self;
    personalSettiongTableView.backgroundView = tableViewBg;
    personalSettiongTableView.backgroundColor = [UIColor whiteColor];
    personalSettiongTableView.dataSource = self;
    personalSettiongTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([personalSettiongTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [personalSettiongTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.bgView addSubview:personalSettiongTableView];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAPP:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:shareButton];
    
    [self getData];
}

-(void)getData
{
    [self getAccount];
    [self getUserInfo];
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
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
    return 3;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 10)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2)
    {
        return 25;
    }
    else if(section == 0)
    {
        return 20;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 4;
    }
    else if (section == 2)
    {
        return 2;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 90;
    }
    else if(indexPath.section == 1)
    {
        return 60;
    }
    else if (indexPath.section == 2)
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
            cell.nameLabel.frame = CGRectMake(90, 20, 18*[[Tools user_name] length], 20);
            cell.nameLabel.text = [Tools user_name];
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textColor = TITLE_COLOR;
            
            cell.objectsLabel.frame = CGRectMake(90, 45, 100, 20);
            cell.objectsLabel.textColor = TITLE_COLOR;
            cell.objectsLabel.text = [NSString stringWithFormat:@"积分:%d",gf];
        
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.frame = CGRectMake(15, 15, 60, 60);
            
            
            
            [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
            
            cell.authenticationSign.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+5, cell.nameLabel.frame.origin.y-10, 20, 20);
            
            if ([accountDict objectForKey:@"t_checked"])
            {
                [cell.authenticationSign setImage:[UIImage imageNamed:@"auth"]];
            }
            
            cell.arrowImageView.hidden = NO;
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 37.5, 10, 15)];
            [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            static NSString *authcell = @"section0";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.nameLabel.frame = CGRectMake(60, 15, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            
            cell.headerImageView.frame = CGRectMake(10, 10, 40, 40);
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            [cell.headerImageView setImage:[UIImage imageNamed:@"icon_bj"]];
            
            if ([Tools phone_num])
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"班家账号"];
            }
            else
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"绑定手机"];
                cell.textLabel.textColor = TITLE_COLOR;
            }
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-150, 15, 134, 30);
            cell.objectsLabel.text = [Tools phone_num];
            cell.objectsLabel.font = [UIFont systemFontOfSize:18];
            cell.objectsLabel.textColor = TITLE_COLOR;
            
            cell.arrowImageView.hidden = NO;
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 22.5, 10, 15)];
            [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
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
            cell.relateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            cell.relateButton.frame = CGRectMake(SCREEN_WIDTH-80, 17, 60, 26);
            cell.nametf.frame = CGRectMake(60, 15, 170, 30);
            cell.relateButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [cell.relateButton setTitle:@"" forState:UIControlStateNormal];
            [cell.relateButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
            cell.nametf.frame = CGRectMake(SCREEN_WIDTH-150, 17, 120, 26);
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            
            if (indexPath.row == 1)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"QQ账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"QQ账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"未关联" forState:UIControlStateNormal];
                }
                lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
                [cell.iconImageView setImage:[UIImage imageNamed:@"QQicon"]];
            }
            else if(indexPath.row == 2)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"新浪账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"新浪账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"未关联" forState:UIControlStateNormal];
                }
                lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
                [cell.iconImageView setImage:[UIImage imageNamed:@"sinaicon"]];
            }
            else if(indexPath.row == 3)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"人人账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"人人账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"未关联" forState:UIControlStateNormal];
                }
                
                [cell.iconImageView setImage:[UIImage imageNamed:@"icon_rr"]];
            }
            cell.nametf.tag = indexPath.row+333;
            cell.nametf.font = [UIFont systemFontOfSize:16];
            cell.nametf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            cell.nametf.enabled = NO;
            cell.contentLabel.frame = CGRectMake(cell.iconImageView.frame.size.width+cell.iconImageView.frame.origin.x+10, cell.iconImageView.frame.origin.y+4, 150, 30);
            cell.contentLabel.font = [UIFont systemFontOfSize:18];
            cell.nametf.returnKeyType = UIReturnKeyDone;
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.accessoryView.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }
    else if(indexPath.section == 2)
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
                cell.nameLabel.text = @"您尚未进行教师认证";
                cell.nameLabel.frame = CGRectMake(20, 13, 200, 20);
                if (!([Tools phone_num] && [[Tools phone_num] length] > 0))
                {
                    cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-120, 13, 110, 20);
                    cell.objectsLabel.text = @"请绑定手机号";
                    cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                }
                else if ([accountDict objectForKey:@"t_checked"])
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
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.contentView.backgroundColor = [UIColor whiteColor];
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
            cell.textLabel.text = @" 个人设置";
            cell.textLabel.textColor = TITLE_COLOR;
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        PersonInfoSettingViewController *personInfoSettiongViewController = [[PersonInfoSettingViewController alloc] init];
        [self.navigationController pushViewController:personInfoSettiongViewController animated:YES];
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
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
            if (indexPath.row == 1)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            else if(indexPath.row == 2)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            else if(indexPath.row == 3)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            if (!([Tools phone_num] && [[Tools phone_num] length] > 0))
            {
                [Tools showAlertView:@"请先绑定手机号" delegateViewController:nil];
                return ;
            }
            
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
        case 1:
            loginID = ShareTypeQQSpace;
            
            break;
        case 2:
            loginID = ShareTypeSinaWeibo;
            
            break;
        case 3:
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
    NSString *acctype = @"";
    if (buttonIndex == 1)
    {
        switch (alertView.tag-1000)
        {
            case 1:
            {
                loginID = ShareTypeQQSpace;
                acctype = @"qq";
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:QQNICKNAME];
                break;
            }
            case 2:
            {
                loginID = ShareTypeSinaWeibo;
                acctype = @"sw";
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINANICKNAME];
                break;
            }
            case 3:
            {
                loginID = ShareTypeRenren;
                acctype = @"rr";
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:RRNICKNAME];
                break;
            }
            default:
                break;
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [ShareSDK cancelAuthWithType:loginID];
        [self unBindAccount:acctype];
    }
}

-(void)unBindAccount:(NSString *)accountType
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"a_type":accountType,
                                                                      } API:UNBINDACCOUNT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"bind responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"成功解绑" toView:self.bgView];
                [personalSettiongTableView reloadData];
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
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:sinaNickName forKey:SINANICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"qq"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:qqNickName forKey:QQNICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"rr"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:rrNickName forKey:RRNICKNAME];
                    [ud synchronize];
                }
                [personalSettiongTableView reloadData];
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
                
                if (![[accountDict objectForKey:@"qq"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"qq"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"qq"] forKey:QQNICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"rr"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"rr"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"rr"] forKey:RRNICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"sw"] isEqual:[NSNull null]] && [[accountDict objectForKey:@"sw"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"sw"] forKey:SINANICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"phone"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"phone"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"phone"] forKey:PHONENUM];
                    [ud synchronize];
                }
                [personalSettiongTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error.description);
        }];
        [request startAsynchronous];
    }
}

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":[Tools user_id]
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue] == 1)
            {
                gf = [[[responseDict objectForKey:@"data"] objectForKey:@"jf"] integerValue];
                [personalSettiongTableView reloadData];
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
                                                  url:ShareUrl
                                          description:ShareContent
                                            mediaType:SSPublishContentMediaTypeApp];
    
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
                                     [DealJiFen dealJiFenWithID:QQBASE64];
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
                                                  url:ShareUrl
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
                                     [DealJiFen dealJiFenWithID:SWBASE64];
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
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:ShareContent
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:QQBASE64];
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
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
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
                                     [DealJiFen dealJiFenWithID:QQBASE64];
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
                                                  url:ShareUrl
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
                                     [DealJiFen dealJiFenWithID:WXBASE64];
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
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
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
                                     [DealJiFen dealJiFenWithID:WXBASE64];
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

@end
