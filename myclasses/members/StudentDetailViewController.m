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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000
#define SETADMINTAG  5000
#define INFOTABLEVIEWTAG  3333
#define PARENTTABLEVIEWTAG  4444

@interface StudentDetailViewController ()<UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
PareberDetailDelegate,
SetStudentObject,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate>
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
    
    NSString *otherUserAdmin;
    OperatDB *db;
    
    NSString *userPhone;
    
    UIScrollView *mainScrollView;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
}
@end

@implementation StudentDetailViewController
@synthesize studentName,studentID,title,admin,headerImg,role,memDel;
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
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    self.titleLabel.text = @"个人信息";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    pArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    db = [[OperatDB alloc] init];
    
    otherUserAdmin = @"0";
    role = @"students";
    
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
    
    [self.bgView addSubview:mainScrollView];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 32);
    moreButton.hidden = YES;
    [moreButton setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    if (![studentID isEqual:[NSNull null]])
    {
        [self.navigationBarView addSubview:moreButton];
        if ([studentID length]>10)
        {
            if (![studentID isEqualToString:[Tools user_id]])
            {
                moreButton.hidden = NO;
            }
        }
    }
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.5, 11, 80, 80)];
    headerImageView.backgroundColor = [UIColor clearColor];
    headerImageView.layer.cornerRadius = headerImageView.frame.size.width/2;
    headerImageView.clipsToBounds = YES;
    if (![headerImg isEqual:[NSNull null]])
    {
        [Tools fillImageView:headerImageView withImageFromURL:headerImg andDefault:HEADERBG];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:HEADERBG]];
    }
    [mainScrollView addSubview:headerImageView];
    
    UITapGestureRecognizer *tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    headerImageView.userInteractionEnabled = YES;
    if (![studentID isEqual:[NSNull null]])
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if ([studentID length]>10)
            {
                if (![studentID isEqualToString:[Tools user_id]])
                {
                    [headerImageView addGestureRecognizer:tapTgr];
                }
            }
        }
    }

    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.frame.size.width+headerImageView.frame.origin.x+20, 36, [studentName length]*18>100?100:([studentName length]*18), 20)];
    nameLabel.text = studentName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:18];
    [mainScrollView addSubview:nameLabel];
    
    genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x, headerImageView.frame.origin.y, 15, 15)];
    genderImageView.backgroundColor = [UIColor clearColor];
    [mainScrollView addSubview:genderImageView];
    
    
    if (![title isEqual:[NSNull null]])
    {
        CGSize titleSize = [Tools getSizeWithString:title andWidth:200 andFont:[UIFont systemFontOfSize:13]];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height+nameLabel.frame.origin.y, titleSize.width, titleSize.height>0?(titleSize.height+10):40)];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.numberOfLines = 3;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
    }
   
    [mainScrollView addSubview:titleLabel];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height+titleLabel.frame.origin.y+20, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.frame.size.height-headerImageView.frame.origin.y+80)];
    [bgImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
    [mainScrollView addSubview:bgImageView];
    
    parentsTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, headerImageView.frame.size.height+headerImageView.frame.origin.y+10, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    parentsTableView.delegate = self;
    parentsTableView.dataSource = self;
    parentsTableView.tag = PARENTTABLEVIEWTAG;
    parentsTableView.backgroundColor = [UIColor clearColor];
    parentsTableView.scrollEnabled = NO;
    [mainScrollView addSubview:parentsTableView];
    
    
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(10, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+50, SCREEN_WIDTH-15, 210) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.tag = INFOTABLEVIEWTAG;
    infoView.scrollEnabled = NO;
    infoView.backgroundColor = [UIColor clearColor];
    [mainScrollView addSubview:infoView];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIButton *sendMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendMsgButton setTitle:@"发消息" forState:UIControlStateNormal];
    sendMsgButton.frame = CGRectMake(50, infoView.frame.size.height+infoView.frame.origin.y+5, SCREEN_WIDTH-100, 35);
    [sendMsgButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [sendMsgButton addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addFriendButton setTitle:@"加好友" forState:UIControlStateNormal];
    addFriendButton.frame = CGRectMake(50, sendMsgButton.frame.size.height+sendMsgButton.frame.origin.y+10, SCREEN_WIDTH-100, 35);
    [addFriendButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    [addFriendButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fname":studentName} andTableName:FRIENDSTABLE] count] > 0)
    {
        addFriendButton.hidden = YES;
    }
    if (![studentID isEqual:[NSNull null]])
    {
        if (![studentID isEqualToString:[Tools user_id]])
        {
            if ([studentID length] > 10)
            {
                [mainScrollView addSubview:addFriendButton];
                [mainScrollView addSubview:sendMsgButton];
            }
        }
    }
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, addFriendButton.frame.size.height+addFriendButton.frame.origin.y+20);
    mainScrollView.bounces = NO;
    [self getParentsWithStudentName];
    
    if (![studentID isEqual:[NSNull null]])
    {
        if ([studentID length]>10)
        {
            if([Tools NetworkReachable])
            {
                [self getUserInfo];
            }
            else
            {
                [infoView reloadData];
            }
            
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.memDel = nil;
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getParentsWithStudentName
{
    [pArray removeAllObjects];
    NSArray *tmpParentsArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents",@"re_name":studentName} andTableName:CLASSMEMBERTABLE];
    if ([tmpParentsArray count] > 0)
    {
        [pArray addObjectsFromArray:tmpParentsArray];
    }
    [parentsTableView reloadData];
    
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
                [Tools showTips:@"请求已申请，请等待对方答复！" toView:self.bgView];
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
#pragma mark - setstuobj
-(void)setStuObj:(NSString *)newTitle
{
    titleLabel.text = newTitle;
    if ([self.memDel respondsToSelector:@selector(updateChatList:)])
    {
        [self.memDel updateListWith:YES];
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
        if(![studentID isEqual:[NSNull null]])
        {
            if ([studentID length]>10)
            {
                if ([[db findSetWithDictionary:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
                {
                    NSArray *array = [db findSetWithDictionary:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
                    if (![[[array firstObject] objectForKey:@"phone"] isEqual:[NSNull null]])
                    {
                        if ([[[array firstObject] objectForKey:@"phone"] length] > 8)
                        {
                            return 1;
                        }
                    }
                }
            }
        }
        
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
            if (![studentID isEqual:[NSNull null]])
            {
                if ([studentID length]>10)
                {
                    if ([[db findSetWithDictionary:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
                    {
                        NSArray *array = [db findSetWithDictionary:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
                        if (![[[array firstObject] objectForKey:@"phone"] isEqual:[NSNull null]])
                        {
                            if ([[[array firstObject] objectForKey:@"phone"] length] > 8)
                            {
                                userPhone = [[array firstObject]objectForKey:@"phone"];
                            }
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
                if ([studentID isEqualToString:[Tools user_id]])
                {
                    cell.button2.hidden = YES;
                    cell.button1.hidden = YES;
                }

            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"line3"];
        bgImageBG.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgImageBG;
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
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
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
        
        cell.button1.frame = CGRectMake(SCREEN_WIDTH-110, 10, 30, 30);
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-60, 10, 30, 30);
        cell.button2.tag = indexPath.row+100;
        [cell.button2 addTarget:self action:@selector(callToParents:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.button1.tag = indexPath.row+100;
        [cell.button1 addTarget:self action:@selector(msgToParents:) forControlEvents:UIControlEventTouchUpInside];
        NSString *titleStr;
        if ([[dict objectForKey:@"title"] rangeOfString:@"."].length > 0)
        {
            titleStr = [[dict objectForKey:@"title"] substringFromIndex:[[dict objectForKey:@"title"] rangeOfString:@"."].location+1];
        }
        else
        {
            titleStr = [dict objectForKey:@"title"];
        }
        NSString *name = [NSString stringWithFormat:@"%@（%@）",[dict objectForKey:@"name"],titleStr];
        cell.nameLabel.frame = CGRectMake(83, 15, [name length]*20>150?150:[name length]*20, 20);
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
        if (![studentID isEqual:[NSNull null]])
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
        else
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
    }
}

#pragma mark - parentDetailDelegate
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        [pArray removeAllObjects];
        NSArray *tmpParentsArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents",@"re_name":studentName} andTableName:CLASSMEMBERTABLE];
        if ([tmpParentsArray count] > 0)
        {
            [pArray addObjectsFromArray:tmpParentsArray];
        }
        else
        {
            if ([self.memDel respondsToSelector:@selector(updateListWith:)])
            {
                [self.memDel updateListWith:YES];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        [parentsTableView reloadData];
    }
}

-(void)callToParents:(UIButton *)button
{
    NSDictionary *dict = [pArray objectAtIndex:button.tag - 100];
    if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:@"phone"] length] > 8)
        {
            [Tools dialPhoneNumber:[dict objectForKey:@"phone"] inView:self.bgView];
        }
    }
    else
    {
        NSDictionary *dict = [pArray objectAtIndex:button.tag - 100];
        if ([studentID length] > 0)
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
        else
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }

    }
}
-(void)msgToParents:(UIButton *)button
{
    NSDictionary *dict = [pArray objectAtIndex:button.tag - 100];
    if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:@"phone"] length] > 8)
        {
            [self showMessageView:[dict objectForKey:@"phone"]];
        }
    }
    else
    {
        NSDictionary *dict = [pArray objectAtIndex:button.tag - 100];
        if ([studentID length] > 0)
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
        else
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
    }
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
    chatViewController.toID = studentID;
    chatViewController.name = studentName;
    chatViewController.imageUrl = headerImg;
    chatViewController.fromClass = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
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
            [Tools dialPhoneNumber:phoneNum inView:self.bgView];
        }
        
    }
    else if(alertView.tag == MSGBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [self showMessageView:userPhone];
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
            if ([otherUserAdmin integerValue] == 0)
            {
                [self appointToAdmin];
            }
            else if ([otherUserAdmin integerValue] == 1)
            {
                //解除管理员任命
                [self rmAdmin];
            }
        }
    }
    else if(alertView.tag == 3333)
    {
        ;
    }
}

-(void)moreClick
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        if ([otherUserAdmin integerValue] == 0)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"任命为普通管理员",@"设置发言权限",@"任命/解除班干部",@"邀请家长",@"踢出班级",@"举报此人", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
            
        }
        else if([otherUserAdmin integerValue] == 1)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除管理员任命",@"设置发言权限",@"任命/解除班干部",@"邀请家长",@"踢出班级",@"举报此人", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
    }
    else
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报此人", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3333)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                if ([otherUserAdmin integerValue] == 0)
                {
                    //任命为普通管理员
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定要任命%@为管理员吗？",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = SETADMINTAG;
                    [al show];
                }
                else if([otherUserAdmin integerValue] == 1)
                {
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定要解除%@的管理员身份吗？",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = SETADMINTAG;
                    [al show];
                }
            }
            else if(buttonIndex == 1)
            {
                //设置发言权限
                SettingStateLimitViewController *settingLimit = [[SettingStateLimitViewController alloc] init];
                settingLimit.userid = studentID;
                settingLimit.name = studentName;
                settingLimit.role = role;
                [self.navigationController pushViewController:settingLimit animated:YES];
            }
            else if(buttonIndex == 2)
            {
                //任命班干部
                SetStuObjectViewController *setStuViewController = [[SetStuObjectViewController alloc] init];
                setStuViewController.classID = classID;
                setStuViewController.userid = studentID;
                setStuViewController.name = studentName;
                setStuViewController.setStudel = self;
                [self.navigationController pushViewController:setStuViewController animated:YES];
                if ([self.memDel respondsToSelector:@selector(updateListWith:)])
                {
                    [self.memDel updateListWith:YES];
                }

            }
            else if(buttonIndex == 3)
            {
                //邀请家长
                InviteStuPareViewController *invite = [[InviteStuPareViewController alloc] init];
                invite.classID = classID;
                invite.name = studentName;
                invite.userid = studentID;
                invite.className = className;
                invite.schoolName = schoolName;
                [self.navigationController pushViewController:invite animated:YES];
            }
            else if(buttonIndex == 4)
            {
                //踢出班级
                NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",studentName];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = KICKALTAG;
                [al show];
            }
            else if (buttonIndex == 5)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = studentID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
            
        }
        else
        {
            if (buttonIndex == 0)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = studentID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
    }
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
            DDLOG(@"appointadmin responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.memDel respondsToSelector:@selector(updateListWith:)])
                {
                    [self.memDel updateListWith:YES];
                }
                [self.navigationController popViewControllerAnimated:YES];
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

-(void)rmAdmin
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":studentID,
                                                                      @"c_id":classID
                                                                      } API:RMADMIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"rmadmin responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.memDel respondsToSelector:@selector(updateListWith:)])
                {
                    [self.memDel updateListWith:YES];
                }
                [self.navigationController popViewControllerAnimated:YES];
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
                [self.navigationController popViewControllerAnimated:YES];
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

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":studentID,
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
                        [db updeteKey:@"phone" toValue:[dataDict objectForKey:@"phone"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE];
                    }
                    otherUserAdmin = [NSString stringWithFormat:@"%d",[[[dict objectForKey:@"classInfo"] objectForKey:@"admin"] integerValue]];
                    [Tools fillImageView:headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
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

#pragma  mark - showmsg
-(void)showMessageView:(NSString *)phoneStr
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:phoneStr];
        
        NSString *msgBody;
        
        controller.body = msgBody;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
//            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        default:
            break;
    }
}

- (void) alertWithTitle:(NSString *)titles msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titles
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    alert.tag = 3333;
    [alert show];
    
}

@end
