//
//  MemberDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-2-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "MemberDetailViewController.h"
#import "Header.h"
#import "ChatViewController.h"
#import "SetObjectViewController.h"
#import "InfoCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ReportViewController.h"

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define TRANSADMINTAG  4000
#define KICKALTAG    5000

#define ContaceACTag  6000

#define BGIMAGEHEIGHT   150

@interface MemberDetailViewController ()<
UITableViewDelegate,
UITableViewDataSource,
SetObjectDelegate,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate>
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
    NSString *classID;
    
    NSString *phoneNum;
    NSString *hidePhoneNum;
    NSString *bgImageUrl;
    NSString *name;
    NSString *qqnum;
    NSString *sexureimage;
    NSString *birth;
    NSString *banjiaNum;
}
@end

@implementation MemberDetailViewController

@synthesize role,j_id,applyName,title,admin,headerImg,memDel;
@synthesize teacherID,teacherName;
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
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    qqnum = @"未绑定";
    birth = @"";
    banjiaNum = @"";
    hidePhoneNum = @"";
    self.titleLabel.text = @"个人信息";
    
    dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    db = [[OperatDB alloc] init];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    if ([teacherID isEqualToString:[Tools user_id]])
    {
        moreButton.hidden = YES;
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];

    if (![teacherID isEqualToString:[Tools user_id]])
    {
        
    }
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"]) &&
        ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentTeacherFriend] integerValue]==0))
    {
        
    }
    else if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"]) &&
             ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentTeacherFriend] integerValue]==0))
    {
        
    }
    
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":teacherID} andTableName:FRIENDSTABLE] count] > 0)
    {
        NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":teacherID} andTableName:FRIENDSTABLE] firstObject];
        DDLOG(@"database dict %@",dict);
    }
    
    if ([[db findSetWithDictionary:@{@"uid":teacherID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":teacherID} andTableName:CLASSMEMBERTABLE] firstObject];
        DDLOG(@"database dict %@",dict);
        if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
        {
            phoneNum = [dict objectForKey:@"phone"];
        }
        if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
        {
            headerImg = [dict objectForKey:@"img_icon"];
        }
        if (![[dict objectForKey:@"birth"] isEqual:[NSNull null]])
        {
            birth = [dict objectForKey:@"birth"];
        }
        if (![[dict objectForKey:@"sex"] isEqual:[NSNull null]] && [[dict objectForKey:@"sex"] length] > 0)
        {
            if ([[dict objectForKey:@"sex"] intValue] == 1)
            {
                //男
                sexureimage = @"male";
            }
            else if ([[dict objectForKey:@"sex"] intValue] == 0)
            {
                //
                sexureimage = @"female";
            }
        }
    }
    if (![self showPhoneNum])
    {
        phoneNum = @"";
    }
    if ([birth rangeOfString:@"设置"].length > 0)
    {
        birth = @"";
    }
    
    if([Tools NetworkReachable])
    {
        [self getUserInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)showPhoneNum
{
    if ([teacherID isEqualToString:[Tools user_id]])
    {
        return YES;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        return YES;
    }
    return NO;
}

#pragma mark - setobjectdel
-(void)setobject:(NSString *)objectUpdate
{
    if (objectUpdate)
    {
        title = objectUpdate;
        if ([self.memDel respondsToSelector:@selector(updateListWith:)])
        {
            [self.memDel updateListWith:YES];
        }
    }
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        if ([phoneNum length] > 0 || ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
        {
            return 35;
        }
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([phoneNum length] > 0 || ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = @"   个人信息";
        //    headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.textColor = TITLE_COLOR;
        return headerLabel;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return BGIMAGEHEIGHT;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < 3)
        {
            if (indexPath.row == 0 && [phoneNum length] > 0)
            {
                return 40;
            }
            if (indexPath.row == 1 && ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
            {
                return 40;
            }
            if (indexPath.row == 2 && [banjiaNum length] > 0)
            {
                return 40;
            }
        }
        else
            return 60;
    }
    return 0;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *infocell = @"onfocell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
    }
    cell.headerImageView.hidden = YES;
    cell.bgImageView.hidden = YES;
    cell.sexureImageView.hidden = YES;
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.section == 0)
    {
        cell.sexureImageView.hidden = NO;
        cell.headerImageView.hidden = NO;
        cell.bgImageView.hidden = NO;
        
        cell.bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, BGIMAGEHEIGHT);
        [cell.bgImageView setImage:[UIImage imageNamed:@"toppic"]];
        
        cell.headerImageView.frame = CGRectMake(15, BGIMAGEHEIGHT-DetailHeaderHeight-15, DetailHeaderHeight, DetailHeaderHeight);
        
        if ([headerImg length] > 0)
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:headerImg imageWidth:106 andDefault:HEADERICON];
        }
        else
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERICON]];
        }
        
        UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)];
        cell.headerImageView.userInteractionEnabled = YES;
        [cell.headerImageView addGestureRecognizer:headerTap];
        
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.headerImageView.layer.borderWidth = 2;
        
        //        cell.nameLabel.textColor = TITLE_COLOR;
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+10, [teacherName length]*18, 20);
        cell.nameLabel.text = teacherName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        
        cell.sexureImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+10, cell.nameLabel.frame.origin.y, 20, 20);
        [cell.sexureImageView setImage:[UIImage imageNamed:sexureimage]];
        
        //        cell.contentLabel.textColor = TITLE_COLOR;
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+35, 100, 20);
        cell.contentLabel.text = title;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *copyPhoneNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyPhoneNum)];
        cell.nameLabel.userInteractionEnabled = YES;
        copyPhoneNumTap.numberOfTapsRequired = 7;
        copyPhoneNumTap.numberOfTouchesRequired = 1;
        [cell.nameLabel addGestureRecognizer:copyPhoneNumTap];

    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < 3)
        {
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-150, 5, 140, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                if([phoneNum length] > 0)
                {
                    cell.nameLabel.text = @"手机号";
                    cell.contentLabel.text = phoneNum;
                }
                else
                {
                    cell.nameLabel.text = @"";
                }
            }
            else if(indexPath.row == 1)
            {
                if([birth length] > 0 && ![birth isEqualToString:@"请设置生日"])
                {
                    cell.nameLabel.text = @"生日";
                    cell.contentLabel.text = birth;
                }
                else
                {
                    cell.nameLabel.text = @"";
                }
            }
            else if (indexPath.row == 2)
            {
                if ([banjiaNum length] > 0)
                {
                    cell.nameLabel.text = @"班家号";
                    cell.contentLabel.text = banjiaNum;
                }
                else
                {
                    cell.nameLabel.text = @"";
                }
            }
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            cell.nameLabel.hidden = YES;
            cell.contentLabel.hidden = YES;
            if (![teacherID isEqualToString:[Tools user_id]])
            {
                cell.button1.hidden = NO;
                cell.button2.hidden = NO;
            }
            
            cell.button1.frame = CGRectMake(10, 10, 145, 43.5);
            [cell.button1 setTitle:ADDFRIEND forState:UIControlStateNormal];
            
            cell.button2.layer.cornerRadius = 5;
            cell.button2.clipsToBounds = YES;
            [cell.button2 setBackgroundImage:[ImageTools createImageWithColor:RGB(57, 188, 173, 1)] forState:UIControlStateNormal];
            
            [cell.button1 addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
            
            cell.button2.frame = CGRectMake(165, 10, 145, 43.5);
            [cell.button2 setTitle:CHATTO forState:UIControlStateNormal];
            
            cell.button2.layer.cornerRadius = 5;
            cell.button2.clipsToBounds = YES;
            [cell.button2 setBackgroundImage:[ImageTools createImageWithColor:RGB(57, 188, 173, 1)] forState:UIControlStateNormal];
            
            cell.button1.iconImageView.frame = CGRectMake(ALEFT, ATOP, CHATW, CHATH);
            [cell.button1.iconImageView setImage:[UIImage imageNamed:@"add_friend"]];
            
            cell.button2.iconImageView.frame = CGRectMake(CLEFT, CTOP, ADDFRIW, ADDFRIH);
            [cell.button2.iconImageView setImage:[UIImage imageNamed:@"chatto"]];
            
            if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fname":teacherName,@"checked":@"1"} andTableName:FRIENDSTABLE] count] > 0 || ![self canAddFriendTeacher])
            {
                cell.button1.hidden = YES;
                cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            
            if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserChatTeacher] intValue] == 0 &&
                [[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
            {
                cell.button2.hidden = YES;
                cell.button1.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            
            [cell.button2 addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)canAddFriendTeacher
{
    NSDictionary *setDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"set"];
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"] &&
         [[setDict objectForKey:StudentTeacherFriend] intValue] == 0) ||
        ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] &&
         [[setDict objectForKey:ParentTeacherFriend] intValue] == 0))
    {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if (![teacherID isEqualToString:[Tools user_id]])
            {
                UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打电话",@"发短信", nil];
                ac.tag = ContaceACTag;
                [ac showInView:self.bgView];
            }
        }
    }
}

-(void)copyPhoneNum
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:hidePhoneNum];
    [Tools showTips:hidePhoneNum toView:self.bgView];
}

#pragma mark - 查看大头像
-(void)headerTap:(UITapGestureRecognizer *)headerTap
{
    MJPhoto *photo = [[MJPhoto alloc] init];
    if ([headerImg length] > 0 && ![headerImg isEqualToString:HEADERICON])
    {
        if ([Tools NetworkReachable])
        {
            if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi)
            {
                //wifi
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,headerImg]];
            }
            else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
            {
                //蜂窝
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@@%dw",IMAGEURL,headerImg,WWAN_IMAGE_WIDTH]];
            }
        }
        else
        {
            photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,headerImg]];
        }
    }
    else
    {
        photo.image = [UIImage imageNamed:HEADERICON];
    }
    photo.srcImageView = (UIImageView *)headerTap.view;
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = [NSArray arrayWithObject:photo];
    [photoBroser show];
}

-(void)callToUser
{
    [Tools dialPhoneNumber:phoneNum inView:self.bgView];
}

-(void)msgToUser
{
    [self showMessageView];
}

-(void)moreClick
{
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] intValue];
    
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"设置班级角色",@"任命为班主任",@"踢出班级",@"举报此人", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
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
        int userAdmin = [[dict objectForKey:@"admin"] intValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                //设置班级角色
                SetObjectViewController *setobject = [[SetObjectViewController alloc] init];
                setobject.name = teacherName;
                setobject.userid = teacherID;
                setobject.classID = classID;
                setobject.title = title;
                setobject.setobject= self;
                [self.navigationController pushViewController:setobject animated:YES];
            }
            else if(buttonIndex == 1)
            {
                //任命为班主任
                NSString *message = [NSString stringWithFormat:@"您确定要转交班主任权限给%@吗？",teacherName];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = TRANSADMINTAG;
                [al show];
            }
//            农业银行北京科技园区支行
            else if(buttonIndex == 2)
            {
                //踢出班级
                NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",teacherName];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = KICKALTAG;
                [al show];
            }
            else if (buttonIndex == 3)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = teacherID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
        else if(buttonIndex == 0)
        {
            ReportViewController *reportVC = [[ReportViewController alloc] init];
            reportVC.reportType = @"people";
            reportVC.reportUserid = teacherID;
            reportVC.reportContentID = @"";
            [self.navigationController pushViewController:reportVC animated:YES];
        }
    }
    else if(actionSheet.tag == ContaceACTag)
    {
        if (buttonIndex == 0)
        {
            [self callToUser];
        }
        else if(buttonIndex == 1)
        {
            [self showMessageView];
        }
    }
}

-(void)excludeUser
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":teacherID,
                                                                      @"c_id":classID,
                                                                      @"role":@"teachers"
                                                                      } API:KICKUSERFROMCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"kickuser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db deleteRecordWithDict:@{@"classid":classID,@"uid":teacherID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"delete teacher success");
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


-(void)transAdminTo
{
    if ([Tools NetworkReachable])
    {
        
        DDLOG(@"%@=%@=%@=%@",[Tools user_id],[Tools client_token],teacherID,classID);
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":teacherID,
                                                                      @"c_id":classID
                                                                      } API:TRANSADMIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"transadmin responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"admin" toValue:@"2" withParaDict:@{@"classid":classID,@"uid":teacherID} andTableName:CLASSMEMBERTABLE])
                {
                    
                    if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update old admin to 1");
                    }
                    if ([db updeteKey:@"title" toValue:@"老师" withParaDict:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update old admin to 老师");
                    }
                    if ([db updeteKey:@"title" toValue:@"班主任" withParaDict:@{@"classid":classID,@"uid":teacherID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update new admin title");
                    }
                    DDLOG(@"transmit admin success");
                }
                [[NSUserDefaults standardUserDefaults]  setObject:@"1" forKey:@"admin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
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


-(void)toChat
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.toID = teacherID;
    chatViewController.name = teacherName;
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
    if(alertView.tag == MSGBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",[dataDict objectForKey:@"phone"]]]];
        }
    }
    else if(alertView.tag == TRANSADMINTAG)
    {
        if (buttonIndex == 1)
        {
            [self transAdminTo];
        }
    }
    else if(alertView.tag == KICKALTAG)
    {
        if (buttonIndex == 1)
        {
            [self excludeUser];
        }
    }
    else if(alertView.tag == 3333)
    {
        ;
    }
    else
    {
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":teacherID
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


-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":teacherID,
                                                                      @"c_id":classID
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                if (![dict isEqual:[NSNull null]])
                {
                    if ([[dict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        sexureimage = @"male";
                    }
                    else if ([[dict objectForKey:@"sex"] intValue] == 0)
                    {
                        //
                        sexureimage = @"female";
                    }
                    if ([db updeteKey:@"sex" toValue:[dict objectForKey:@"sex"] withParaDict:@{@"uid":teacherID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update sex success");
                    }
                    if ([dict objectForKey:@"phone"])
                    {
                        if ([db updeteKey:@"phone" toValue:[dict objectForKey:@"phone"] withParaDict:@{@"uid":teacherID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach phone update success!");
                        }
                        phoneNum = [dict objectForKey:@"phone"];
                        hidePhoneNum = phoneNum;
                    }
                    if ([dict objectForKey:@"birth"] && ![[dict objectForKey:@"birth"] isEqualToString:@"请设置生日"])
                    {
                        if ([db updeteKey:@"birth" toValue:[dict objectForKey:@"birth"] withParaDict:@{@"uid":teacherID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach birth update success!");
                        }
                        birth = [dict objectForKey:@"birth"];
                    }
                    if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                    {
                        
                        if ([[dict objectForKey:@"img_icon"] isKindOfClass:[NSString class]])
                        {
                            headerImg = [dict objectForKey:@"img_icon"];
                        }
                        else
                        {
                            headerImg = HEADERICON;
                        }
                    }
                    
                    if (![EmptyTools isEmpty:dict key:@"number"])
                    {
                        banjiaNum = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]];
                        if ([banjiaNum length] < 7)
                        {
                            banjiaNum = @"";
                        }
                    }
                }
                if (![self showPhoneNum])
                {
                    phoneNum = @"";
                }
                if ([birth rangeOfString:@"设置"].length > 0)
                {
                    birth = @"";
                }
                if ([dict objectForKey:@"number"] &&
                    ![[dict objectForKey:@"number"] isEqual:[NSNull null]])
                {
                    if ([[db findSetWithDictionary:@{@"uid":teacherID} andTableName:USERICONTABLE] count] > 0)
                    {
                        if ([db deleteRecordWithDict:@{@"uid":teacherID} andTableName:USERICONTABLE])
                        {
                            [db insertRecord:@{@"uid":teacherID,
                                               @"unum":[NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]],
                                               @"uicon":[dict objectForKey:@"img_icon"]?[dict objectForKey:@"img_icon"]:@"",
                                               @"username":[dict objectForKey:@"r_name"]}
                                andTableName:USERICONTABLE];
                        }
                        
                    }
                    else
                    {
                        if ([db insertRecord:@{@"uid":teacherID,
                                               @"unum":[NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]],
                                               @"uicon":[dict objectForKey:@"img_icon"]?[dict objectForKey:@"img_icon"]:@"",
                                               @"username":[dict objectForKey:@"r_name"]}
                                andTableName:USERICONTABLE])
                        {
                            DDLOG(@"insert success");
                        }
                    }
                }

                [infoView reloadData];
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
-(void)showMessageView
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:phoneNum];
        
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
