//
//  InviteStuPareViewController.m
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "InviteStuPareViewController.h"
#import "Header.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

#import "PersonalSettingCell.h"
#import "ClassCell.h"

#define ParentsAlterTag  44444

#define TIPSLABEL_TAG 10086

#define BUFFER_SIZE 1024 * 100

#define InviteWayTag 22222
#define ParentTableViewtag 33333

#define RelateButtonWidth  120

@interface InviteStuPareViewController ()<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
MFMessageComposeViewControllerDelegate,
UIAlertViewDelegate>
{
    UITableView *parentsTableView;
    NSArray *parentArray;
    UITextField *parentTextField;
    
    UIView *parentView;
    UILabel *parentLabel;
    
    NSString *relateString;
    
    UIView *buttonView;
    
    BOOL open;
    
    UILabel *tipLabel;
    
    UITableView *inviteWayTableview;
    
    NSMutableArray *waynames;
    NSMutableArray *iconsArray;
    
    UIImageView *arrowImageView;
}
@end

@implementation InviteStuPareViewController
@synthesize name,userid,classID,className,schoolName;
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
    
    open = YES;
    
    relateString = @"";
    
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    self.titleLabel.text = @"邀请学生家长";
    
    NSString *tipStr = [NSString stringWithFormat:@"您邀请%@的:",name];
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, UI_NAVIGATION_BAR_HEIGHT+40, 147, 30)];
    tipLabel.text = tipStr;
    tipLabel.textColor = CONTENTCOLOR;
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:tipLabel];
    
    parentView = [[UIView alloc] initWithFrame:CGRectMake(tipLabel.frame.origin.x+tipLabel.frame.size.width-5, tipLabel.frame.origin.y-5, RelateButtonWidth, 42)];
    parentView.backgroundColor = [UIColor whiteColor];
    parentView.layer.cornerRadius = 8;
    parentView.clipsToBounds = YES;
    [self.bgView addSubview:parentView];
    
    parentLabel = [[UILabel alloc] init];
    parentLabel.frame = CGRectMake(2, 0, RelateButtonWidth-25, 42);
    parentLabel.textColor = CONTENTCOLOR;
    parentLabel.text = @"    爸爸";
    parentLabel.font = [UIFont systemFontOfSize:16];
    [parentView addSubview:parentLabel];
    
    arrowImageView = [[UIImageView alloc] init];
    arrowImageView.frame = CGRectMake(parentView.frame.size.width- 30, parentLabel.frame.origin.y+16, 18, 10);
    arrowImageView.backgroundColor = [UIColor whiteColor];
    [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    [parentView addSubview:arrowImageView];
    
    
    UITapGestureRecognizer *openTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opentableview)];
    parentLabel.userInteractionEnabled = YES;
    [parentLabel addGestureRecognizer:openTgr];
    
    parentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(parentView.frame.origin.x, parentView.frame.size.height+parentView.frame.origin.y+10, parentView.frame.size.width, 0) style:UITableViewStylePlain];
    parentsTableView.delegate = self;
    parentsTableView.dataSource = self;
    parentsTableView.tag = ParentTableViewtag;
    parentsTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:parentsTableView];
    parentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    parentsTableView.layer.cornerRadius = 5;
    parentsTableView.clipsToBounds = YES;
    
//    [self.bgView addSubview:parentButton];

    parentArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"其他", nil];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opentableview)];
    parentTextField.userInteractionEnabled = YES;
    [parentTextField addGestureRecognizer:tgr];
    
    waynames = [[NSMutableArray alloc] initWithObjects:@"手机短信", nil];
    iconsArray = [[NSMutableArray alloc] initWithObjects:@"mesginviteicon", nil];
    if ([WXApi isWXAppInstalled])
    {
        [waynames addObject:@"微信"];
        [iconsArray addObject:@"weichat"];
    }
    
    if ([QQApi isQQInstalled])
    {
        [waynames addObject:@"QQ好友"];
        [iconsArray addObject:@"QQicon"];
    }
    
    inviteWayTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, parentView.frame.size.height + parentView.frame.origin.y, SCREEN_WIDTH, ([iconsArray count]+1)*50) style:UITableViewStylePlain];
    inviteWayTableview.tag = InviteWayTag;
    inviteWayTableview.delegate = self;
    inviteWayTableview.dataSource = self;
    inviteWayTableview.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:inviteWayTableview];
    
    [self.bgView addSubview:parentsTableView];
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

-(void)opentableview
{
    if (open)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            parentsTableView.frame = CGRectMake(parentView.frame.origin.x, parentsTableView.frame.origin.y, parentView.frame.size.width, [parentArray count]*42);
            [arrowImageView setImage:[UIImage imageNamed:@"arrow_up"]];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            parentsTableView.frame = CGRectMake(parentView.frame.origin.x, parentsTableView.frame.origin.y, parentView.frame.size.width, 0);
            [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
        }];
    }
    open = !open;
    [parentsTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == InviteWayTag)
    {
        return 50;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == InviteWayTag)
    {
        UILabel *headerlabel = [[UILabel alloc] init];
        headerlabel.font = [UIFont systemFontOfSize:16];
        headerlabel.textColor = CONTENTCOLOR;
        headerlabel.text = @"      通过哪种方式邀请:";
        headerlabel.backgroundColor = self.bgView.backgroundColor;
        return headerlabel;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == ParentTableViewtag)
    {
        return [parentArray count];
    }
    else
    {
        return [iconsArray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ParentTableViewtag)
    {
        return 42;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ParentTableViewtag)
    {
        static NSString *parentcell = @"invitepareobject";
        ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:parentcell];
        if (cell == nil)
        {
            cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentcell];
        }
        
//        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
//        UIImageView *lineImageView = [[UIImageView alloc] init];
//        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
//        lineImageView.backgroundColor = LineBackGroudColor;
//        [cell.contentView addSubview:lineImageView];
//        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.nameLabel.text = [parentArray objectAtIndex:indexPath.row];
        cell.nameLabel.frame = CGRectMake(20, 6, 150, 30);
        return cell;
    }
    else if(tableView.tag == InviteWayTag)
    {
        static NSString *authcell = @"section0";
        PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
        if (cell == nil)
        {
            cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
        }
        cell.nameLabel.font = [UIFont systemFontOfSize:18];
        cell.nameLabel.textAlignment = NSTextAlignmentLeft;
        cell.nameLabel.frame = CGRectMake(60, 10, 100, 30);
        cell.nameLabel.textColor = TITLE_COLOR;
        
        cell.headerImageView.frame = CGRectMake(10, 8, 34, 34);
        cell.headerImageView.layer.cornerRadius = 3;
        cell.headerImageView.clipsToBounds = YES;
        [cell.headerImageView setImage:[UIImage imageNamed:[iconsArray objectAtIndex:indexPath.row]]];
        
        cell.nameLabel.text = [waynames objectAtIndex:indexPath.row];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
        }
        
        cell.arrowImageView.hidden = NO;
        [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 17.5, 10, 15)];
        [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1)
        {
            lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
        }
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ParentTableViewtag)
    {
        if (indexPath.row == [parentArray count]-1)
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入家长关系名称：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.alertViewStyle = UIAlertViewStylePlainTextInput;
            al.tag = ParentsAlterTag;
            [al show];
            [self opentableview];
        }
        else
        {
            parentLabel.text = [NSString stringWithFormat:@"    %@",[parentArray objectAtIndex:indexPath.row]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            parentTextField.enabled = NO;
            parentTextField.hidden = YES;
            parentTextField.text = nil;
            [self opentableview];
        }
    }
    else if(tableView.tag == InviteWayTag)
    {
        if(indexPath.row == 1)
        {
            [self inviteWeiXin];
        }
        else if(indexPath.row == 2)
        {
            [self shareToQQFriendClickHandler:nil];
        }
        else if(indexPath.row == 0)
        {
            [self showMessageView];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ParentsAlterTag)
    {
        if (buttonIndex == 1)
        {
            parentLabel.text = [NSString stringWithFormat:@"    %@",[alertView textFieldAtIndex:0].text];
        }
    }
}

#pragma  mark - showmsg
-(void)showMessageView
{
    if ([parentLabel.text length]<=0 && ![parentLabel.text isEqualToString:@"其他"] && [parentTextField.text length] <=0)
    {
        [Tools showAlertView:@"请先确定孩子和家长的关系" delegateViewController:nil];
        return;
    }
    if ([parentTextField.text length] > 0)
    {
        relateString = parentTextField.text;
    }
    else if([parentLabel.text length] > 0)
    {
        relateString = parentLabel.text;
    }
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
//        controller.recipients = contactInviteArray;
        
        NSString *msgBody;
        NSMutableString *inviteBody = [[NSMutableString alloc] initWithString:InviteParent];
        
        DDLOG(@"++++==+++%@",inviteBody);
        
        NSString *parentString = [NSString stringWithFormat:@"%@的%@",name,[relateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [inviteBody replaceOccurrencesOfString:@"#parent" withString:parentString options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        
        [inviteBody replaceOccurrencesOfString:@"#school-" withString:(([schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"]) > 0)?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
        if ([classNum length] > 0)
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }
        else
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }
        [inviteBody replaceOccurrencesOfString:@"#name" withString:[Tools user_name] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        [inviteBody insertString:HOST_URL atIndex:[inviteBody length]];
        msgBody = inviteBody;

        controller.body = msgBody;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"短信邀请"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    switch ( result ) {
            
        case MessageComposeResultCancelled:
        {
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        }
        case MessageComposeResultFailed:// send failed
        {
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        }
        case MessageComposeResultSent:
        {
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        }
        default:
            break;
    }
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
    
}



/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    if ([parentLabel.text length]<=0 && [parentTextField.text length] <=0)
    {
        [Tools showAlertView:@"请先确定孩子和家长的关系" delegateViewController:nil];
        return;
    }
    if ([parentTextField.text length] > 0)
    {
        relateString = parentTextField.text;
    }
    else if([parentLabel.text length] > 0)
    {
        relateString = parentLabel.text;
    }
    //创建分享内容
    
    NSString *msgBody;
    NSMutableString *inviteBody = [[NSMutableString alloc] initWithString:InviteParent];;
    
    NSString *parentString = [NSString stringWithFormat:@"%@的%@",name,[relateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [inviteBody replaceOccurrencesOfString:@"#parent" withString:parentString options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    
    [inviteBody replaceOccurrencesOfString:@"#school-" withString:([schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"])?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
    if ([classNum length] > 0)
    {
        [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    }
    else
    {
        [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    }
    [inviteBody replaceOccurrencesOfString:@"#name" withString:[Tools user_name] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    
    msgBody = inviteBody;
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    
    id<ISSContent> publishContent = [ShareSDK content:msgBody
                                       defaultContent:msgBody
                                         image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"logo120"] quality:1]
                                         title:NSLocalizedString(@"班家", @"这是App消息")
                                           url:ShareUrl
                                   description:msgBody
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

- (void)inviteWeiXin
{
    
    if ([parentLabel.text length]<=0 && [parentTextField.text length] <=0)
    {
        [Tools showAlertView:@"请先确定孩子和家长的关系" delegateViewController:nil];
        return;
    }
    if ([parentTextField.text length] > 0)
    {
        relateString = parentTextField.text;
    }
    else if([parentLabel.text length] > 0)
    {
        relateString = parentLabel.text;
    }
    // 发送内容给微信
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    NSMutableString *inviteBody = [[NSMutableString alloc] initWithString:InviteParent];;
    
    NSString *parentString = [NSString stringWithFormat:@"%@的%@",name,[relateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [inviteBody replaceOccurrencesOfString:@"#parent" withString:parentString options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    
    [inviteBody replaceOccurrencesOfString:@"#school-" withString:([schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"])?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
    if ([classNum length] > 0)
    {
        [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    }
    else
    {
        [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    }
    [inviteBody replaceOccurrencesOfString:@"#name" withString:[Tools user_name] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
    
    id<ISSContent> content = [ShareSDK content:inviteBody
                                       defaultContent:inviteBody
                                                image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"logo120"] quality:1]
                                                title:NSLocalizedString(@"班家", @"这是App消息")
                                                  url:ShareUrl
                                          description:inviteBody
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [content addWeixinSessionUnitWithType:INHERIT_VALUE
                                  content:inviteBody
                                    title:INHERIT_VALUE
                                      url:INHERIT_VALUE
                                    image:INHERIT_VALUE
                             musicFileUrl:nil
                                  extInfo:@""
                                 fileData:data
                             emoticonData:nil];
    
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
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            [DealJiFen dealJiFenWithID:WXBASE64];
                            NSLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TEXT_TIPS", @"提示")
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"TEXT_KNOW", @"知道了")
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}



-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [parentTextField resignFirstResponder];
    return YES;
}

@end
