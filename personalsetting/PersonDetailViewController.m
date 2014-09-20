//
//  PersonDetailViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-28.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "PersonDetailViewController.h"

#import "Header.h"
#import "ChatViewController.h"
#import "SetObjectViewController.h"
#import "InfoCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ReportViewController.h"

#import <MessageUI/MessageUI.h>

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define TRANSADMINTAG  4000
#define KICKALTAG    5000

#define MoreACTag   6000
#define ContaceACTag  7000

#define BGIMAGEHEIGHT   120

@interface PersonDetailViewController ()<
UITableViewDelegate,
UITableViewDataSource,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate,UIAlertViewDelegate,
MFMailComposeViewControllerDelegate>
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
//    NSString *classID;
    
    NSString *phoneNum;
    NSString *headerImageUrl;
    NSString *bgImageUrl;
    NSString *name;
    NSString *qqnum;
    NSString *sexureimage;
    NSString *birth;
    
    NSString *email;
}
@end

@implementation PersonDetailViewController
@synthesize fromChat;
@synthesize personID,personName,c_id,headerImg;
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
    
//    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    qqnum = @"未绑定";
    birth = @"未设置";
    
    self.titleLabel.text = @"个人信息";
    
    
    dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    db = [[OperatDB alloc] init];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    if ([personID isEqualToString:[Tools user_id]])
    {
        moreButton.hidden = YES;
    }
    if ([personID isEqualToString:OurTeamID] || [personID isEqualToString:AssistantID])
    {
        moreButton.hidden = YES;
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    if (![personID isEqualToString:[Tools user_id]])
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
    
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":personID} andTableName:FRIENDSTABLE] count] > 0)
    {
        NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":personID} andTableName:FRIENDSTABLE] firstObject];
        DDLOG(@"database dict %@",dict);
    }
    
    if ([[db findSetWithDictionary:@{@"uid":personID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":personID} andTableName:CLASSMEMBERTABLE] firstObject];
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
    
    if (![personID isEqualToString:[Tools user_id]])
    {
        phoneNum = @"";
    }
    
    [infoView reloadData];
    
    
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
        return 3;
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
        if (indexPath.row < 2)
        {
            if (![personID isEqualToString:OurTeamID] && ![personID isEqualToString:AssistantID])
            {
                if (indexPath.row == 0 && [phoneNum length] > 0)
                {
                    return 40;
                }
                else if (indexPath.row == 1 && ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
                {
                    return 40;
                }
            }
            else
            {
                return 40;
            }
        }
        else if(indexPath.row == 2)
        {
            return 65;
        }
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
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.section == 0)
    {
        cell.headerImageView.hidden = NO;
        cell.bgImageView.hidden = NO;
        
        cell.bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 120);
        [cell.bgImageView setImage:[UIImage imageNamed:@"toppic"]];
        
        cell.headerImageView.frame = CGRectMake(15, BGIMAGEHEIGHT-DetailHeaderHeight-15, DetailHeaderHeight, DetailHeaderHeight);
        if ([headerImageUrl isEqualToString:HEADERICON])
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
        
        //        cell.nameLabel.textColor = TITLE_COLOR;
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, 60, 100, 20);
        cell.nameLabel.text = personName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        
        //        cell.contentLabel.textColor = TITLE_COLOR;
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, 80, 100, 20);
//        cell.contentLabel.text = title;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < 2)
        {
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            cell.lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-200, 5, 190, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                if (![personID isEqualToString:OurTeamID] && ![personID isEqualToString:AssistantID])
                {
                    if ([phoneNum length] > 0)
                    {
                        cell.nameLabel.text = @"手机号";
                    }
                    else
                    {
                        cell.nameLabel.text = @"";
                        cell.lineImageView.hidden = YES;
                    }
                    cell.contentLabel.text = phoneNum;
                    
                }
                else
                {
                    cell.nameLabel.text = @"邮件地址";
                    cell.contentLabel.text = email;
                }
            }
            else if(indexPath.row == 1)
            {
                if ([personID isEqualToString:OurTeamID])
                {
                    cell.nameLabel.text = @"创建时间";
                    cell.contentLabel.text = birth;
                }
                else if([birth length] > 0 && ![birth isEqualToString:@"请设置生日"])
                {
                    cell.nameLabel.text = @"生日";
                    cell.contentLabel.text = birth;
                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = @"";
                    cell.lineImageView.hidden = YES;
                }
            }
        }
        else
        {
            cell.nameLabel.hidden = YES;
            cell.contentLabel.hidden = YES;
            if (![personID isEqualToString:[Tools user_id]])
            {
                cell.button1.hidden = NO;
                cell.button2.hidden = NO;
            }
            else
            {
                cell.button1.hidden = YES;
                cell.button2.hidden = YES;
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
            
            if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":personID,@"checked":@"1"} andTableName:FRIENDSTABLE] count] > 0)
            {
                cell.button1.hidden = YES;
                cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            if([personID isEqualToString:OurTeamID])
            {
                cell.button1.hidden = YES;
                cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
            }
            
            [cell.button2 addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
            if([personID isEqualToString:AssistantID])
            {
                [cell.button2 setTitle:@"      查看消息" forState:UIControlStateNormal];
            }
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
            if ([personID isEqualToString:OurTeamID] || [personID isEqualToString:AssistantID])
            {
                UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送邮件", nil];
                ac.tag = ContaceACTag;
                [ac showInView:self.bgView];
            }
            else if (![personID isEqualToString:[Tools user_id]])
            {
                UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打电话",@"发短信", nil];
                ac.tag = ContaceACTag;
                [ac showInView:self.bgView];
            }
        }
    }
}

-(void)callToUser
{
    if ([phoneNum length] > 0)
    {
        [Tools dialPhoneNumber:phoneNum inView:self.bgView];
    }
}

-(void)msgToUser
{
    [self showMessageView];
}

-(void)moreClick
{
    
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":personID} andTableName:FRIENDSTABLE] count] > 0)
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除好友关系",@"举报此人", nil];
        ac.tag = MoreACTag;
        [ac showInView:self.bgView];
    }
    else
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报此人", nil];
        ac.tag = MoreACTag;
        [ac showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(actionSheet.tag == MoreACTag)
    {
        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":personID} andTableName:FRIENDSTABLE] count] > 0)
        {
            if (buttonIndex == 0)
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您确定与%@解除好友关系吗？",personName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定解除", nil];
                al.tag = 3333;
                [al show];
            }
            else if (buttonIndex == 1)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = personID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
        else if(buttonIndex == 0)
        {
            ReportViewController *reportVC = [[ReportViewController alloc] init];
            reportVC.reportType = @"people";
            reportVC.reportUserid = personID;
            reportVC.reportContentID = @"";
            [self.navigationController pushViewController:reportVC animated:YES];
        }
        
    }
    else if(actionSheet.tag == ContaceACTag)
    {
        if([personID isEqualToString:OurTeamID] || [personID isEqualToString:AssistantID])
        {
            if (buttonIndex == 0)
            {
                [self displayMailPicker];
            }
        }
        else
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
}

#pragma mark - 意见反馈
//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"班家意见反馈"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: phoneNum];
    [mailPicker setToRecipients: toRecipients];
    //添加抄送
    //    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    //    [mailPicker setCcRecipients:ccRecipients];
    //添加密送
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
    //    [mailPicker setBccRecipients:bccRecipients];
    
    //    // 添加一张图片
    //    UIImage *addPic = [UIImage imageNamed: @"icon@2x.png"];
    //    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
    //    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
    //    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"icon.png"];
    
    //添加一个pdf附件
    //    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
    //    NSData *pdf = [NSData dataWithContentsOfFile:file];
    //    [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
    
    //    NSString *emailBody = @"<font color='black'>请输入您要反馈的内容：</font> ";
    //    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    [Tools showAlertView:msg delegateViewController:nil];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3333)
    {
        if (buttonIndex == 1)
        {
            [self releaseFriend];
        }
    }
}

-(void)releaseFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":personID
                                                                      } API:MB_RMFRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addfriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db deleteRecordWithDict:@{@"uid":[Tools user_id],@"fid":personID} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend success");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEFRIENDSLIST object:nil];
                [self.navigationController popViewControllerAnimated:YES];
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
    if (fromChat)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.toID = personID;
    chatViewController.name = personName;
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


-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":personID
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
                                                                      @"other_id":personID
//                                                                      @"other_id":@"NTM4NjhmYTMzNGRhYjVhZTFjOGI0NThm"
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberinfo responsedict %@",responseString);
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
                        phoneNum = [dict objectForKey:@"phone"];
                    }
                    
                    if ([dict objectForKey:@"email"])
                    {
                        email = [dict objectForKey:@"email"];
                    }
                    if ([dict objectForKey:@"birth"])
                    {
                        birth = [dict objectForKey:@"birth"];
                    }
                    if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                    {
                        
                        if ([[dict objectForKey:@"img_icon"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"img_icon"] length] > 10)
                        {
                            headerImg = [dict objectForKey:@"img_icon"];
                        }
                        else
                        {
                            headerImg = HEADERICON;
                        }
                    }
                    
                    if ([[db findSetWithDictionary:@{@"uid":personID} andTableName:CLASSMEMBERTABLE] count] > 0)
                    {
                        [db updeteKey:@"phone" toValue:phoneNum withParaDict:@{@"uid":personID} andTableName:CLASSMEMBERTABLE];
                    }
                    else
                    {
                        if (phoneNum)
                        {
                            [db insertRecord:@{@"uid":personID,
                                               @"name":personName,
                                               @"phone":phoneNum,
                                               @"birth":birth,
                                               @"img_icon":headerImg}
                                andTableName:CLASSMEMBERTABLE];
                        }
                        else if(email)
                        {
                            [db insertRecord:@{@"uid":personID,
                                               @"name":personName,
                                               @"phone":email,
                                               @"birth":birth,
                                               @"img_icon":headerImg}
                                andTableName:CLASSMEMBERTABLE];
                        }
                    }
                    
                }
                if (![personID isEqualToString:[Tools user_id]])
                {
                    phoneNum = @"";
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