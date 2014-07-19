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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ReportViewController.h"


#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000

#define BGIMAGEHEIGHT  150

@interface ParentsDetailViewController ()<
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
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
    NSString *headerImageUrl;
    NSString *bgImageUrl;
    NSString *name;
    NSString *qqnum;
    NSString *sexureimage;
    NSString *birth;
    
    NSDictionary *parentDict;
}
@end

@implementation ParentsDetailViewController
@synthesize parentID,parentName,title,admin,headerImg,role,studentName;
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
    
    self.titleLabel.text = @"个人信息";
    
    qqnum = @"未绑定";
    birth = @"未设置";
    
    
    dataDict  = [[NSMutableDictionary alloc] initWithCapacity:0];
    db = [[OperatDB alloc] init];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    if ([parentID isEqualToString:[Tools user_id]])
    {
        moreButton.hidden = YES;
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    if ([[db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        parentDict = [[db findSetWithDictionary:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE] firstObject];
        if (![[parentDict objectForKey:@"phone"] isEqual:[NSNull null]])
        {
            phoneNum = [parentDict objectForKey:@"phone"];
        }
        if (![[parentDict objectForKey:@"img_icon"] isEqual:[NSNull null]])
        {
            headerImageUrl = [parentDict objectForKey:@"img_icon"];
        }
        if (![[parentDict objectForKey:@"birth"] isEqual:[NSNull null]])
        {
            birth = [parentDict objectForKey:@"birth"];
        }
    }
    
    if([Tools NetworkReachable])
    {
        [self getUserInfo];
    }
    else
    {
        [infoView reloadData];
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

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
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
        return 3;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = @"   个人信息";
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
        if (indexPath.row < 2)
        {
            return 40;
        }
    }
    return 60;
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
        if ([headerImageUrl isEqualToString:HEADERICON])
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERICON]];
        }
        else
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:headerImageUrl andDefault:HEADERICON];
        }
        
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.headerImageView.layer.borderWidth = 2;
        
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+10, [parentName length]*18, 20);
        cell.nameLabel.text = parentName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        
       cell.sexureImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+10, cell.nameLabel.frame.origin.y, 20, 20);
        [cell.sexureImageView setImage:[UIImage imageNamed:sexureimage]];
        
        NSMutableString *titlestr = [[NSMutableString alloc] initWithString:title];
        [titlestr replaceCharactersInRange:[title rangeOfString:@"."] withString:@"的"];
        
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+35, 100, 20);
        cell.contentLabel.text = titlestr;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (indexPath.section == 1)
    {
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
            if (![parentID isEqualToString:[Tools user_id]])
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

            
            if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fname":parentName,@"checked":@"1"} andTableName:FRIENDSTABLE] count] > 0)
            {
                cell.button1.hidden = YES;
                cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            
            [cell.button2 addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if (![parentID isEqualToString:[Tools user_id]])
            {
                [self callToUser];
            }
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
    chatViewController.toID = parentID;
    chatViewController.name = parentName;
    chatViewController.imageUrl = headerImg;
    chatViewController.fromClass = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == MSGBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [self showMessageView];
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
                NSDictionary *studentDict = [[db findSetWithDictionary:@{@"classid":classID,@"name":[parentDict objectForKey:@"re_name"]} andTableName:CLASSMEMBERTABLE] firstObject];
                if ([[studentDict objectForKey:@"uid"] isEqual:[NSNull null]] || ([[studentDict objectForKey:@"uid"] length]==0))
                {
                    if ([db deleteRecordWithDict:@{@"name":[parentDict objectForKey:@"re_name"],@"classid":classID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"delete student success!");
                        if ([db deleteRecordWithDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"delete parent success!");
                        }
                    }
                }
                else
                {
                    if ([db deleteRecordWithDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"delete parent success!");
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

-(void)moreClick
{
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] integerValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"设置家长学生关系",@"设置发言权限",@"踢出班级",@"举报此人", nil];
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
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                //设置关系
                SettingRelateViewController *settingRelate = [[SettingRelateViewController alloc] init];
                settingRelate.parentName = parentName;
                settingRelate.title = title;
                settingRelate.parentID = parentID;
                settingRelate.admin = admin;
                settingRelate.classID = classID;
                [self.navigationController pushViewController:settingRelate animated:YES];
            }
            else if (buttonIndex == 1)
            {
                //设置发言权限
                SettingStateLimitViewController *settingLimit = [[SettingStateLimitViewController alloc] init];
                settingLimit.userid = parentID;
                settingLimit.name = parentName;
                settingLimit.role = role;
                [self.navigationController pushViewController:settingLimit animated:YES];
            }
            else if (buttonIndex == 2)
            {
                //踢出班级
                NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",parentName];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = KICKALTAG;
                [al show];
            }
            else if (buttonIndex == 3)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = parentID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
        else if(buttonIndex == 0)
        {
            ReportViewController *reportVC = [[ReportViewController alloc] init];
            reportVC.reportType = @"people";
            reportVC.reportUserid = parentID;
            reportVC.reportContentID = @"";
            [self.navigationController pushViewController:reportVC animated:YES];

        }
    }
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
                    if ([dict objectForKey:@"phone"])
                    {
                        if ([db updeteKey:@"phone" toValue:[dict objectForKey:@"phone"] withParaDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach phone update success!");
                        }
                        phoneNum = [dict objectForKey:@"phone"];
                    }
                    if ([dict objectForKey:@"birth"])
                    {
                        if ([db updeteKey:@"birth" toValue:[dict objectForKey:@"birth"] withParaDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach birth update success!");
                        }
                        birth = [dict objectForKey:@"birth"];
                    }
                    if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                    {
                        
                        if ([dict objectForKey:@"img_icon"])
                        {
                            headerImageUrl = [dict objectForKey:@"img_icon"];
                        }
                        else
                        {
                            headerImageUrl = HEADERICON;
                        }
                    }
                    
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
-(void)showMessageView
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:userPhone];
        
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
