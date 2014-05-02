//
//  StudentDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "StudentDetailViewController.h"
#import "Header.h"
#import "SetStuObjectViewController.h"
#import "ChatViewController.h"
#import "InviteStuPareViewController.h"
#import "SettingStateLimitViewController.h"
#import "InfoCell.h"
#import "ParentsDetailViewController.h"

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000
#define SETADMINTAG  5000
#define INFOTABLEVIEWTAG  3333
#define PARENTTABLEVIEWTAG  4444

@interface StudentDetailViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *tmpBgView;
    UIImageView *genderImageView;
    UILabel *nameLabel;
    UIImageView *headerImageView;
    UILabel *titleLabel;
    
    NSMutableDictionary *dataDict;
    UITableView *infoView;
    UIImageView *bgImageView;
    
    NSMutableArray *pArray;
    UITableView *parentsTableView;
    
    NSString *phoneNum;
}
@end

@implementation StudentDetailViewController
@synthesize classID,studentName,studentID,title,admin,headerImg,role,memDel;
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
    
    DDLOG(@"student id=%@,classid = %@",studentID,classID);
    self.titleLabel.text = @"个人信息";
    dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    pArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    OperatDB *dataBase = [[OperatDB alloc] init];
    NSArray *parentsArray = [dataBase findSetWithDictionary:@{@"re_id":studentID} andTableName:@"userinfo"];
    DDLOG(@"parents===%@",parentsArray);
    
    for(int i=0;i<[parentsArray count];i++)
    {
        NSDictionary *dict = [parentsArray objectAtIndex:i];
        [self getUserInfoWithID:[dict objectForKey:@"uid"] andClassID:classID];
    }
    
    
    int adminNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue];
    if (adminNum == 2)
    {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 32);
        [moreButton setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:moreButton];
    }
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.5, UI_NAVIGATION_BAR_HEIGHT+11, 80, 80)];
    headerImageView.backgroundColor = [UIColor greenColor];
    headerImageView.layer.cornerRadius = headerImageView.frame.size.width/2;
    headerImageView.clipsToBounds = YES;
    if ([headerImg length]>0)
    {
        [Tools fillImageView:headerImageView withImageFromURL:headerImg andDefault:HEADERDEFAULT];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:HEADERDEFAULT]];
    }
    [self.bgView addSubview:headerImageView];
    
    UITapGestureRecognizer *tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:tapTgr];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.frame.size.width+headerImageView.frame.origin.x+20, UI_NAVIGATION_BAR_HEIGHT+36, [studentName length]*18>100?100:([studentName length]*18), 20)];
    nameLabel.text = studentName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:nameLabel];
    
    genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x, headerImageView.frame.origin.y, 15, 15)];
    genderImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:genderImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height+nameLabel.frame.origin.y, 150, 30)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self.bgView addSubview:titleLabel];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height+titleLabel.frame.origin.y+20, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.frame.size.height-headerImageView.frame.origin.y)];
    [bgImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self.bgView addSubview:bgImageView];
    
    parentsTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, headerImageView.frame.size.height+headerImageView.frame.origin.y+10, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    parentsTableView.delegate = self;
    parentsTableView.dataSource = self;
    parentsTableView.tag = PARENTTABLEVIEWTAG;
    parentsTableView.backgroundColor = [UIColor clearColor];
    parentsTableView.scrollEnabled = NO;
    [self.bgView addSubview:parentsTableView];
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(10, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+50, SCREEN_WIDTH-15, 160) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
//    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.tag = INFOTABLEVIEWTAG;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *sendMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendMsgButton setTitle:@"发消息" forState:UIControlStateNormal];
    sendMsgButton.frame = CGRectMake(50, SCREEN_HEIGHT-115, SCREEN_WIDTH-100, 40);
    [sendMsgButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [sendMsgButton addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addFriendButton setTitle:@"加好友" forState:UIControlStateNormal];
    addFriendButton.frame = CGRectMake(50, SCREEN_HEIGHT-60, SCREEN_WIDTH-100, 35);
    [addFriendButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    [addFriendButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    
    if (![studentID isEqualToString:[Tools user_id]])
    {
        [self.bgView addSubview:addFriendButton];
        [self.bgView addSubview:sendMsgButton];
    }
    
    [self getUserInfoWithID:studentID andClassID:classID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":studentID
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


#pragma mark - tableview
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        return 30;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = @"     个人信息";
        //    headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.textColor = [UIColor whiteColor];
        return headerLabel;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        return 60;
    }
    else if(tableView.tag == PARENTTABLEVIEWTAG)
    {
        return 50;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        return [[dataDict allKeys] count];
    }
    else if(tableView.tag == PARENTTABLEVIEWTAG)
    {
        if ([pArray count] > 0)
        {
            parentsTableView.frame = CGRectMake(0, headerImageView.frame.size.height+headerImageView.frame.origin.y+20, SCREEN_WIDTH, [pArray count]*50);
            infoView.frame = CGRectMake(10, parentsTableView.frame.origin.y+parentsTableView.frame.size.height+40, SCREEN_WIDTH-15, 160);
            bgImageView.frame = CGRectMake(0, parentsTableView.frame.size.height+parentsTableView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.frame.size.height-headerImageView.frame.origin.y-20);
        }
        return [pArray count];
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        static NSString *infocell = @"infocell";
        InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
        if (cell == nil)
        {
            cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
        }
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = @"移动电话";
            cell.contentLabel.text = [dataDict objectForKey:@"phone"];
            //        [cell.button1 addTarget:self action:@selector(msgToUser) forControlEvents:UIControlEventTouchUpInside];
            [cell.button2 addTarget:self action:@selector(callToUser) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(tableView.tag == PARENTTABLEVIEWTAG)
    {
        static NSString *parentcell = @"parentcell";
        InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:parentcell];
        if (cell == nil)
        {
            cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentcell];
        }
        NSDictionary *dict = [pArray objectAtIndex:indexPath.row];
        if ([dict objectForKey:@"img_icon"])
        {
            DDLOG(@"parent dict %d",[[dict objectForKey:@"img_icon"] length]);
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERDEFAULT];
        }
        else
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERDEFAULT]];
        }
        
        cell.headerImageView.frame = CGRectMake(11, 5, 40, 40);
        
        cell.headerImageView.layer.cornerRadius = 20;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.nameBgView.frame = CGRectMake(66, 1, SCREEN_WIDTH-66, 48);
        cell.nameBgView.backgroundColor = LIGHT_BLUE_COLOR;
        
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-90, 10, 30, 30);
        cell.button2.tag = indexPath.row+100;
        [cell.button2 addTarget:self action:@selector(callToParents:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *name = [dict objectForKey:@"r_name"];
        cell.nameLabel.frame = CGRectMake(83, 15, [name length]*20>80?80:[name length]*20, 20);
        cell.nameLabel.text = name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == PARENTTABLEVIEWTAG)
    {
        NSDictionary *dict = [pArray objectAtIndex:indexPath.row];
        
        ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
        parentDetail.parentID = [dict objectForKey:@"_id"];
        parentDetail.parentName = [dict objectForKey:@"name"];
        parentDetail.title = [dict objectForKey:@"title"];
        parentDetail.headerImg = [dict objectForKey:@"img_icon"];
        parentDetail.admin = NO;
        parentDetail.classID = classID;
        parentDetail.role = [dict objectForKey:@"role"];
        [parentDetail showSelfViewController:self];

    }
}

-(void)callToParents:(UIButton *)button
{
    NSDictionary *dict = [pArray objectAtIndex:button.tag - 100];
    DDLOG(@"===%@",[dict objectForKey:@"phone"]);
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要拨打这个电话吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    al.tag = CALLBUTTONTAG;
    phoneNum = [dict objectForKey:@"phone"];
    [al show];
}

-(void)callToUser
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要拨打这个电话吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    al.tag = CALLBUTTONTAG;
    phoneNum = [dataDict objectForKey:@"phone"];
    [al show];
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
    chatViewController.toID = studentID;
    chatViewController.name = studentName;
    chatViewController.imageUrl = headerImg;
    [chatViewController showSelfViewController:self];
}

-(void)infoButtonClick:(UIButton *)button
{
    if (button.tag == INFOLABELTAG)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打",@"发信息", nil];
        al.tag = button.tag;
        [al show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CALLBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            DDLOG(@"===%@",phoneNum);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
        }
        
    }
    else if(alertView.tag == MSGBUTTONTAG)
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
    else if(alertView.tag == SETADMINTAG)
    {
        if (buttonIndex == 1)
        {
            [self appointToAdmin];
        }
    }
}

-(void)moreClick
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] > 0)
    {
        NSArray *array = [[NSArray alloc] initWithObjects:@"踢出班级",@"设置发言权限",@"解除任命",@"任命班干部",@"邀请家长",@"任命为普通管理员", nil];
        [self showView:[NSMutableArray arrayWithArray:array]];
    }
    else
    {
        [Tools showAlertView:@"您没有权限" delegateViewController:nil];
    }
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
    if (button.tag-4000-1 == 5)
    {
        //任命为普通管理员
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定要任命%@为管理员吗？",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = SETADMINTAG;
        [al show];
    }
    else if (button.tag-4000-1 == 4)
    {
        //邀请家长
        InviteStuPareViewController *invite = [[InviteStuPareViewController alloc] init];
        invite.classID = classID;
        invite.name = studentName;
        invite.userid = studentID;
        [invite showSelfViewController:self];
    }
    else if(button.tag-4000-1 == 3)
    {
        //任命班干部
        SetStuObjectViewController *setStuViewController = [[SetStuObjectViewController alloc] init];
        setStuViewController.classID = classID;
        setStuViewController.userid = studentID;
        setStuViewController.name = studentName;
        [setStuViewController showSelfViewController:self];
        if ([self.memDel respondsToSelector:@selector(updateListWith:)])
        {
            [self.memDel updateListWith:YES];
        }
    }
    else if(button.tag-4000-1 == 2)
    {
        //解除任命
    }
    else if(button.tag-4000-1 == 1)
    {
        //设置发言权限
        SettingStateLimitViewController *settingLimit = [[SettingStateLimitViewController alloc] init];
        settingLimit.userid = studentID;
        settingLimit.name = studentName;
        settingLimit.classID = classID;
        settingLimit.role = role;
        [settingLimit showSelfViewController:self];
    }
    else if(button.tag-4000-1 == 0)
    {
        //踢出班级
        NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",studentName];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = KICKALTAG;
        [al show];
    }
    [self cancelPhone];
}

-(void)appointToAdmin
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":studentID,
                                                                      @"c_id":classID
                                                                      } API:APPOINTADMIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"kickuser responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
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

-(void)excludeUser
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":studentID,
                                                                      @"c_id":classID,
                                                                      @"role":@"students"
                                                                      } API:KICKUSERFROMCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"kickuser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
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

-(void)getUserInfoWithID:(NSString *)userID andClassID:(NSString *)classid
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":userID,
                                                                      @"c_id":classid
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getusetinfo-responsedict==%@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                
                if (![[[dict objectForKey:@"classInfo"] objectForKey:@"role"] isEqual:[NSNull null]])
                {
                    if ([[[dict objectForKey:@"classInfo"] objectForKey:@"role"] isEqualToString:@"parents"])
                    {
                        [pArray addObject:dict];
                        [parentsTableView reloadData];
                    }
                    else if([[[dict objectForKey:@"classInfo"] objectForKey:@"role"] isEqualToString:@"students"])
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
                        else if ([[dict objectForKey:@"sex"] intValue] == 2)
                        {
                            //
                            [genderImageView setImage:[UIImage imageNamed:@"female"]];
                        }
                        [infoView reloadData];
                    }
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
        }];
        [request startAsynchronous];
    }
}
@end
