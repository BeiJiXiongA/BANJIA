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

#define BGIMAGEHEIGHT  150

@interface StudentDetailViewController ()<UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
SetStudentObject,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate>
{
    
    UITableView *infoView;
    
    NSMutableArray *pArray;
    
    NSString *otherUserAdmin;
    OperatDB *db;
    
    NSString *userPhone;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    NSString *phoneNum;
    NSString *headerImageUrl;
    NSString *bgImageUrl;
    NSString *name;
    NSString *qqnum;
    NSString *sexureimage;
    NSString *birth;
    
    
    CGFloat bgImageHeight;
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
    
    qqnum = @"未绑定";
    birth = @"未设置";
    
    self.titleLabel.text = @"个人信息";
    
    pArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    db = [[OperatDB alloc] init];
    
    otherUserAdmin = @"0";
    role = @"students";
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    moreButton.hidden = YES;
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    if (![studentID isEqual:[NSNull null]] && [studentID length] > 0)
    {
        [self.navigationBarView addSubview:moreButton];
        if ([studentID length] > 10)
        {
            if (![studentID isEqualToString:[Tools user_id]])
            {
                moreButton.hidden = NO;
            }
        }
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    if (![studentID isEqual:[NSNull null]])
    {
        if ([studentID length] > 10)
        {
            if ([[db findSetWithDictionary:@{@"uid":studentID} andTableName:CLASSMEMBERTABLE] count] > 0)
            {
                NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":studentID} andTableName:CLASSMEMBERTABLE] firstObject];
                DDLOG(@"database dict %@",dict);
                if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
                {
                    phoneNum = [dict objectForKey:@"phone"];
                }
                if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    headerImageUrl = [dict objectForKey:@"img_icon"];
                }
                if (![[dict objectForKey:@"birth"] isEqual:[NSNull null]])
                {
                    birth = [dict objectForKey:@"birth"];
                }
            }
        }
    }
    
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
}
-(void)dealloc
{
    self.memDel = nil;
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getParentsWithStudentName
{
    [pArray removeAllObjects];
    NSArray *tmpParentsArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents",@"re_name":studentName,@"checked":@"1"} andTableName:CLASSMEMBERTABLE];
    if ([tmpParentsArray count] > 0)
    {
        [pArray addObjectsFromArray:tmpParentsArray];
    }
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
#pragma mark - setstuobj
-(void)setStuObj:(NSString *)newTitle
{
    if ([self.memDel respondsToSelector:@selector(updateListWith:)])
    {
        [self.memDel updateListWith:YES];
    }
    title = newTitle;
    [infoView reloadData];
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 35)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = TITLE_COLOR;
    if (section == 1)
    {
        if ([pArray count] > 0)
        {
            headerLabel.text = @"   家长";
            return headerLabel;
        }
        else
            return nil;
    }
    else
        headerLabel.text = @"   个人信息";
        return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        if ([pArray count] > 0)
        {
            return 35;
        }
        else
            return 0;
    }
    else if(section == 2)
    {
        if ([studentID length] > 10)
        {
            return 35;
        }
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return BGIMAGEHEIGHT;
    }
    else if(indexPath.section == 1)
    {
        if ([pArray count] > 0)
        {
            return 60;
        }
        return 0;
    }
    else if (indexPath.section == 2)
    {
        if ([studentID length] > 10)
        {
            if (indexPath.row < 2)
            {
                return 40;
            }
            return 60;
        }
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
        return [pArray count];
    }
    else if(section == 2)
    {
        if ([studentID length] > 10)
        {
            return 3;
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *infocell = @"infocell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
    }
    cell.headerImageView.hidden = YES;
    cell.bgImageView.hidden = YES;
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.section == 0)
    {
        cell.headerImageView.hidden = NO;
        cell.bgImageView.hidden = NO;
        cell.sexureImageView.hidden = NO;
        
        cell.bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, BGIMAGEHEIGHT);
        [cell.bgImageView setImage:[UIImage imageNamed:@"toppic"]];
        
        cell.headerImageView.frame = CGRectMake(15, BGIMAGEHEIGHT-DetailHeaderHeight-15, DetailHeaderHeight, DetailHeaderHeight);
        if ([headerImg isEqualToString:HEADERICON])
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERICON]];
        }
        else
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:headerImg andDefault:HEADERICON];
        }
        
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.headerImageView.layer.borderWidth = 2;
        
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+10, [studentName length]*18, 20);
        cell.nameLabel.text = studentName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        
        cell.sexureImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+10, cell.nameLabel.frame.origin.y, 20, 20);
        [cell.sexureImageView setImage:[UIImage imageNamed:sexureimage]];
        
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+35, 100, 20);
        cell.contentLabel.text = title;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (indexPath.section == 1)
    {
        if ([pArray count] > 0)
        {
            cell.headerImageView.hidden = NO;
            NSDictionary *parentDict = [pArray objectAtIndex:indexPath.row];
            cell.headerImageView.frame = CGRectMake(15, 10, 40, 40);
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            [Tools fillImageView:cell.headerImageView withImageFromURL:[parentDict objectForKey:@"img_icon"] andDefault:HEADERICON];
            cell.nameLabel.frame = CGRectMake(70, 15, 100, 30);
            cell.nameLabel.text = [parentDict objectForKey:@"name"];
            cell.nameLabel.font = NAMEFONT;
            cell.nameLabel.textColor = NAMECOLOR;
            
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-100, 15, 80, 30);
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.text = [[parentDict objectForKey:@"title"] substringFromIndex:[[parentDict objectForKey:@"title"] rangeOfString:@"."].location+1];
        }
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"line4"];
        bgImageBG.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgImageBG;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    else if(indexPath.section == 2)
    {
        if ([studentID length] < 10)
        {
            return nil;
        }
        if (indexPath.row < 2)
        {
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-150, 5, 140, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                cell.nameLabel.text = @"手机号";
                cell.contentLabel.text = phoneNum;
            }
            else if(indexPath.row == 1)
            {
                cell.nameLabel.text = @"生日";
                cell.contentLabel.text = birth;
            }
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
            cell.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            cell.nameLabel.hidden = YES;
            cell.contentLabel.hidden = YES;
            if (![studentID isEqualToString:[Tools user_id]])
            {
                cell.button1.hidden = NO;
                cell.button2.hidden = NO;
            }
            
            cell.button1.frame = CGRectMake(10, 10, 145, 43.5);
            [cell.button1 setTitle:ADDFRIEND forState:UIControlStateNormal];
            [cell.button1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
            
            [cell.button1 addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
            
            cell.button2.frame = CGRectMake(165, 10, 145, 43.5);
            [cell.button2 setTitle:CHATTO forState:UIControlStateNormal];
            [cell.button2 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
            
            cell.button1.iconImageView.frame = CGRectMake(ALEFT, ATOP, CHATW, CHATH);
            [cell.button1.iconImageView setImage:[UIImage imageNamed:@"add_friend"]];
            
            cell.button2.iconImageView.frame = CGRectMake(CLEFT, CTOP, ADDFRIW, ADDFRIH);
            [cell.button2.iconImageView setImage:[UIImage imageNamed:@"chatto"]];

            
            if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fname":studentName,@"checked":@"1"} andTableName:FRIENDSTABLE] count] > 0)
            {
                cell.button1.hidden = YES;
                cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            
            [cell.button2 addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
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
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
    }
    else if(indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            if (![studentID isEqualToString:[Tools user_id]])
            {
                [self callToUser];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - parentDetailDelegate
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        [pArray removeAllObjects];
        if ([self.memDel respondsToSelector:@selector(updateListWith:)])
        {
            [self.memDel updateListWith:YES];
        }
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
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
    }
}

-(void)callToUser
{
    [Tools dialPhoneNumber:phoneNum inView:self.bgView];
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
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] integerValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
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
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                if ([otherUserAdmin integerValue] == 0)
                {
                    //任命为普通管理员
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"设置为管理员后，%@可以进行处理班级申请、审核班级日志、发布班级公告等操作。",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
                setStuViewController.title = title;
                [self.navigationController pushViewController:setStuViewController animated:YES];
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
                if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"appoint %@ admin success!",studentName);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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
                if ([db updeteKey:@"admin" toValue:@"0" withParaDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"rm %@ admin success!",studentName);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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
//                for (int i=0 ; i<[pArray count]; i++)
//                {
//                    NSDictionary *pDict = [pArray objectAtIndex:i];
//                    if ([db deleteRecordWithDict:@{@"uid":[pDict objectForKey:@"uid"],@"class":classID,@"re_id":studentID} andTableName:CLASSMEMBERTABLE])
//                    {
//                        DDLOG(@"delete stu parents success");
//                    }
//                }
                
                if ([pArray count] > 0)
                {
                    if ([db updeteKey:@"uid" toValue:@"" withParaDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update stu success with parents");
                    }
                }
                else
                {
                    if ([db deleteRecordWithDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"delete stu success without parents");
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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
                        if ([db updeteKey:@"phone" toValue:[dict objectForKey:@"phone"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach phone update success!");
                        }
                        phoneNum = [dict objectForKey:@"phone"];
                        phoneNum = [dict objectForKey:@"phone"];
                    }
                    
                    if ([[dict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        sexureimage = @"male";
                    }
                    else
                    {
                        //
                        sexureimage = @"female";
                    }
                    
                    if ([dict objectForKey:@"birth"])
                    {
                        if ([db updeteKey:@"birth" toValue:[dict objectForKey:@"birth"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach birth update success!");
                        }
                        birth = [dict objectForKey:@"birth"];
                    }
                    otherUserAdmin = [NSString stringWithFormat:@"%d",[[[dict objectForKey:@"classInfo"] objectForKey:@"admin"] integerValue]];
                    headerImageUrl = [dict objectForKey:@"img_icon"];
                    [infoView reloadData];
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
