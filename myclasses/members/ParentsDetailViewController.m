//
//  ParentsDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-3-1.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ParentsDetailViewController.h"
#import "Header.h"
#import "ChatViewController.h"
#import "InfoCell.h"
#import "SettingStateLimitViewController.h"
#import "SettingRelateViewController.h"

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000

@interface ParentsDetailViewController ()<
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
SetRelateDel>
{
    UIView *tmpBgView;
    UIImageView *genderImageView;
    UILabel *nameLabel;
    UIImageView *headerImageView;
    UILabel *jobLabel;
    NSMutableDictionary *dataDict;
    
    UITableView *infoView;
    OperatDB *db;
    
    NSString *userPhone;
}
@end

@implementation ParentsDetailViewController
@synthesize parentID,parentName,title,admin,classID,headerImg,role,memDel;
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
    
    DDLOG(@"parent id=%@",parentName);
    self.titleLabel.text = @"个人信息";
    dataDict  = [[NSMutableDictionary alloc] initWithCapacity:0];
    db = [[OperatDB alloc] init];
    
    int adminNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue];
    if (adminNum == 2)
    {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 32);
        [moreButton setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:moreButton];
        if ([parentID isEqualToString:[Tools user_id]])
        {
            moreButton.hidden = YES;
        }
    }
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.5, UI_NAVIGATION_BAR_HEIGHT+11, 80, 80)];
    headerImageView.layer.cornerRadius = headerImageView.frame.size.width/2;
    headerImageView.clipsToBounds = YES;
    if ([headerImg length]>0)
    {
        [Tools fillImageView:headerImageView withImageFromURL:headerImg andDefault:HEADERBG];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:HEADERBG]];
    }
    [self.bgView addSubview:headerImageView];
    
    UITapGestureRecognizer *tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    headerImageView.userInteractionEnabled = YES;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        if (![parentID isEqualToString:[Tools user_id]])
        {
            [headerImageView addGestureRecognizer:tapTgr];
        }
    }
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.frame.size.width+headerImageView.frame.origin.x+20, UI_NAVIGATION_BAR_HEIGHT+36, [parentName length]*18>100?100:([parentName length]*18), 20)];
    nameLabel.text = parentName;
    nameLabel.textColor = TITLE_COLOR;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:nameLabel];
    
    genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x, headerImageView.frame.origin.y, 15, 15)];
    genderImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:genderImageView];
    
    NSMutableString *titleStr = [[NSMutableString alloc] initWithString:title];
    if ([title rangeOfString:@"."].length > 0)
    {
        [titleStr replaceCharactersInRange:[title rangeOfString:@"."] withString:@"的"];
    }
    
    jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height+nameLabel.frame.origin.y, 70, 30)];
    jobLabel.backgroundColor = [UIColor clearColor];
    jobLabel.font = [UIFont systemFontOfSize:13];
    jobLabel.textColor = [UIColor lightGrayColor];
    jobLabel.text = titleStr;
    [self.bgView addSubview:jobLabel];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, jobLabel.frame.size.height+jobLabel.frame.origin.y+20, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.frame.size.height-headerImageView.frame.origin.y)];
    [bgImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self.bgView addSubview:bgImageView];
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(10, jobLabel.frame.size.height+jobLabel.frame.origin.y+50, SCREEN_WIDTH-15, 160) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.scrollEnabled = NO;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIButton *sendMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendMsgButton setTitle:@"发消息" forState:UIControlStateNormal];
    sendMsgButton.frame = CGRectMake(50, infoView.frame.size.height+infoView.frame.origin.y+5, SCREEN_WIDTH-100, 35);
    [sendMsgButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [sendMsgButton addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addFriendButton setTitle:@"加好友" forState:UIControlStateNormal];
    addFriendButton.frame = CGRectMake(50, sendMsgButton.frame.size.height+sendMsgButton.frame.origin.y+5, SCREEN_WIDTH-100, 35);
    [addFriendButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    [addFriendButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    
    if (![parentID isEqualToString:[Tools user_id]])
    {
        [self.bgView addSubview:sendMsgButton];
        [self.bgView addSubview:addFriendButton];
    }
    
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":parentID} andTableName:FRIENDSTABLE] count] > 0)
    {
        addFriendButton.hidden = YES;
    }
    
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setRelate
-(void)changePareTitle:(NSString *)newTitle
{
    jobLabel.text = newTitle;
    if ([self.memDel respondsToSelector:@selector(updateListWith:)])
    {
        [self.memDel updateListWith:YES];
    }
}

#pragma mark - tableview
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = @"     个人信息";
//    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.textColor = [UIColor whiteColor];
    return headerLabel;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        NSArray *array = [db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
        if (![[[array firstObject] objectForKey:@"phone"] isEqual:[NSNull null]])
        {
            if ([[[array firstObject] objectForKey:@"phone"] length] > 8)
            {
                return 1;
            }
        }
    }
    return [[dataDict allKeys] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *infocell = @"onfocell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
    }
    if (indexPath.row == 0)
    {
        cell.nameLabel.text = @"移动电话";
        if ([[db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
        {
            NSArray *array = [db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
            if (![[[array firstObject] objectForKey:@"phone"] isEqual:[NSNull null]])
            {
                if ([[[array firstObject] objectForKey:@"phone"] length] > 8)
                {
                    userPhone = [[array firstObject]objectForKey:@"phone"];
                }
            }
        }
        if ([dataDict count] > 0)
        {
            userPhone = [dataDict objectForKey:@"phone"];
        }
        cell.contentLabel.text = userPhone;
        [cell.button1 addTarget:self action:@selector(msgToUser) forControlEvents:UIControlEventTouchUpInside];
        [cell.button2 addTarget:self action:@selector(callToUser) forControlEvents:UIControlEventTouchUpInside];
        if ([parentID isEqualToString:[Tools user_id]])
        {
            cell.button2.hidden = YES;
        }
    }
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"line3"];
    bgImageBG.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)callToUser
{
    [Tools dialPhoneNumber:userPhone inView:self.bgView];
}

-(void)msgToUser
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要发短信吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发信息", nil];
    al.tag = MSGBUTTONTAG;
    [al show];

}

-(void)toChat
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.toID = parentID;
    chatViewController.name = parentName;
    chatViewController.imageUrl = headerImg;
    [chatViewController showSelfViewController:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == MSGBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",[dataDict objectForKey:@"phone"]]]];
        }
    }
    else if(alertView.tag == KICKALTAG)
    {
        if (buttonIndex == 1)
        {
            [self excludeUser];
        }
    }
    else
    {
        [self unShowSelfViewController];
    }
}
-(void)excludeUser
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":parentID,
                                                                      @"c_id":classID,
                                                                      @"role":@"parents"
                                                                      } API:KICKUSERFROMCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"kickuser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                if ([db deleteRecordWithDict:@{@"uid":parentID,@"classid":classID,@"role":@"parents"} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"delete parent success!");
                }
                if ([self.memDel respondsToSelector:@selector(updateListWith:)])
                {
                    [self.memDel updateListWith:YES];
                }
                [self unShowSelfViewController];
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


-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":parentID
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showAlertView:@"请求已申请，请等待对方答复！" delegateViewController:self];
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

-(void)moreClick
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"踢出班级",@"设置发言权限",@"设置家长学生关系", nil];
    [self showView:[NSMutableArray arrayWithArray:array]];
}

-(void)showView:(NSMutableArray *)tmpArray
{
    tmpBgView = [[UIView alloc] init];
    tmpBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    tmpBgView.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
    [self.bgView addSubview:tmpBgView];
    
    tmpBgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *taps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPhone)];
    [tmpBgView addGestureRecognizer:taps];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPhone) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 4000;
    [cancelButton setBackgroundColor:[UIColor darkGrayColor]];
    [tmpBgView addSubview:cancelButton];
    
    for (int i=0; i < [tmpArray count]; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[tmpArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag = 4000+i+1;
        [button addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor whiteColor];
        [tmpBgView addSubview:button];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        tmpBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        for(int i=0;i<[tmpArray count]+1;++i)
        {
            [tmpBgView viewWithTag:4000+i].frame = CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT - (i+1)*40-30, 200, 30);
        }
    }];
}
-(void)cancelPhone
{
    for (UIView *v in tmpBgView.subviews)
    {
        [v removeFromSuperview];
    }
    [tmpBgView removeFromSuperview];
}
-(void)phoneClick:(UIButton *)button
{
    DDLOG(@"%d",button.tag-4000-1);
    if (button.tag-4000-1 == 2)
    {
        //设置关系
        SettingRelateViewController *settingRelate = [[SettingRelateViewController alloc] init];
        settingRelate.parentName = parentName;
        settingRelate.title = title;
        settingRelate.parentID = parentID;
        settingRelate.admin = admin;
        settingRelate.setRelate = self;
        settingRelate.classID = classID;
        [settingRelate showSelfViewController:self];
    }
    else if(button.tag-4000-1 == 1)
    {
        //设置发言权限
        SettingStateLimitViewController *settingLimit = [[SettingStateLimitViewController alloc] init];
        settingLimit.userid = parentID;
        settingLimit.name = parentName;
        settingLimit.classID = classID;
        settingLimit.role = role;
        [settingLimit showSelfViewController:self];
        
    }
    else if(button.tag-4000-1 == 0)
    {
        //踢出班级
        NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",parentName];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = KICKALTAG;
        [al show];
    }
    [self cancelPhone];
}

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":parentID,
                                                                      @"c_id":classID
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                 NSDictionary *dict = [responseDict objectForKey:@"data"];
                if (![dict isEqual:[NSNull null]])
                {
                    
                    if ([dict objectForKey:@"phone"])
                    {
                        [dataDict setObject:[dict objectForKey:@"phone"] forKey:@"phone"];
                    }
                    
                    if ([[dict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        [genderImageView setImage:[UIImage imageNamed:@"male"]];
                    }
                    else if ([[dict objectForKey:@"sex"] intValue] == 0)
                    {
                        //
                        [genderImageView setImage:[UIImage imageNamed:@"female"]];
                    }
                    if ([[dataDict objectForKey:@"phone"] length] > 0)
                    {
                        [db updeteKey:@"phone" toValue:[dataDict objectForKey:@"phone"] withParaDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
                    }
                    if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                    {
                        if ([[dict objectForKey:@"img_icon"] length] > 10)
                        {
                            [Tools fillImageView:headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
                        }
                        else
                        {
                            [headerImageView setImage:[UIImage imageNamed:HEADERBG]];
                        }
                    }
                    
                    [infoView reloadData];
                }
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


@end
