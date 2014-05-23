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

#define TIPSLABEL_TAG 10086

#define BUFFER_SIZE 1024 * 100

@interface InviteStuPareViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate>
{
    UITableView *parentsTableView;
    NSArray *parentArray;
    UITextField *parentTextField;
    UILabel *parentLabel;
    UIImageView *bg2;
    
    NSString *relateString;
    
    UIView *buttonView;
    
    BOOL open;
    
    UILabel *tipLabel;
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
    
    self.titleLabel.text = @"邀请学生家长";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    
    NSString *tipStr = [NSString stringWithFormat:@"您正在邀请%@的",name];
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, UI_NAVIGATION_BAR_HEIGHT+45, [tipStr length]*18, 30)];
    tipLabel.text = tipStr;
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];    
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    CGFloat yyy = tipLabel.frame.size.height+tipLabel.frame.origin.y;
    
    bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(27, yyy+20, 134, 30)];
    [bg2 setImage:inputImage];
    [self.bgView addSubview:bg2];
    
    parentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, 0) style:UITableViewStylePlain];
    parentsTableView.delegate = self;
    parentsTableView.dataSource = self;
    parentsTableView.tag = 1000;
    parentsTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:parentsTableView];
    
    parentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 60, 20)];
    parentLabel.backgroundColor = [UIColor clearColor];
    parentLabel.textColor = [UIColor grayColor];
    parentLabel.text = @"爸爸";
    parentLabel.textAlignment = NSTextAlignmentCenter;
    parentLabel.font = [UIFont systemFontOfSize:15];
    [bg2 addSubview:parentLabel];

    UIButton *parentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    parentButton.frame = CGRectMake(parentsTableView.frame.origin.x, parentsTableView.frame.size.height+parentsTableView.frame.origin.y-30, parentsTableView.frame.size.width, 30);
    parentButton.backgroundColor = [UIColor clearColor];
    [parentButton addTarget:self action:@selector(opentableview) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:parentButton];
    
    parentArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"输入", nil];
    
    parentTextField = [[UITextField alloc] initWithFrame:CGRectMake(parentButton.frame.size.width+parentButton.frame.origin.x+20 , parentButton.frame.origin.y, 100, 30)];
    parentTextField.enabled = NO;
    parentTextField.hidden = YES;
    parentTextField.placeholder = @"输入";
    parentTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    parentTextField.delegate = self;
    parentTextField.textAlignment = NSTextAlignmentCenter;
    parentTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    parentTextField.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:parentTextField];
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opentableview)];
    parentTextField.userInteractionEnabled = YES;
    [parentTextField addGestureRecognizer:tgr];
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"QQ好友邀请",@"微信好友邀请",@"手机短信邀请", nil];
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];

    buttonView = [[UIView alloc] initWithFrame:CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+20, SCREEN_WIDTH-60, 40*[array count])];
    [self.bgView addSubview:buttonView];
    
    for (int i=0; i<[array count]; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 40*i, SCREEN_WIDTH-60, 38);
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(inviteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000+i;
        [button setBackgroundImage:btnImage forState:UIControlStateNormal];
        [buttonView addSubview:button];
    }
    
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
            parentsTableView.frame = CGRectMake(27, parentsTableView.frame.origin.y, bg2.frame.size.width, [parentArray count]*30);
            buttonView.frame = CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+10, SCREEN_WIDTH-60, 120);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            parentsTableView.frame = CGRectMake(27, parentsTableView.frame.origin.y, bg2.frame.size.width, 0);
            buttonView.frame = CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+20, SCREEN_WIDTH-60, 120);

        }];
    }
    open = !open;
    [parentsTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [parentArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *relateCell = @"relateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
    }
    cell.textLabel.text = [parentArray objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [parentArray count]-1)
    {
        parentLabel.text = nil;
        parentTextField.enabled = YES;
        parentTextField.hidden = NO;
        [parentTextField becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self opentableview];
    }
    else
    {
        parentLabel.text = [parentArray objectAtIndex:indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        parentTextField.enabled = NO;
        parentTextField.hidden = YES;
        parentTextField.text = nil;
        [self opentableview];
    }
}

-(void)inviteButtonClick:(UIButton *)button
{
    if (button.tag == 1000)
    {
        //QQ好友邀请
        [self shareToQQFriendClickHandler:nil];
    }
    else if(button.tag == 1001)
    {
        //微信好友邀请
        [self inviteWeiXin];
    }
    else if(button.tag == 1002)
    {
        //手机短信邀请
        [self showMessageView];
    }
    else if(button.tag == 1003)
    {
        //邀请好友
    }
}

#pragma  mark - showmsg
-(void)showMessageView
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
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
//        controller.recipients = contactInviteArray;
        
        NSString *msgBody;
        msgBody = [NSString stringWithFormat:@"%@的%@，您好，我是%@-%@的老师%@",name,relateString,schoolName,className,[Tools user_name]];
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
            
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
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
    NSString *content = [NSString stringWithFormat:@"%@的%@，您好，我是%@-%@的老师%@",name,relateString,schoolName,className,[Tools user_name]];
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:nil
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
     NSString *contentstr = [NSString stringWithFormat:@"%@的%@，您好，我是%@-%@的老师%@",name,relateString,schoolName,className,[Tools user_name]];
    id<ISSContent> content = [ShareSDK content:contentstr
                                defaultContent:nil
                                         image:nil
                                         title:NSLocalizedString(@"班家", @"这是App消息")
                                           url:@"http://www.banjiaedu.com"
                                   description:contentstr
                                     mediaType:SSPublishContentMediaTypeApp];
    [content addWeixinSessionUnitWithType:INHERIT_VALUE
                                  content:contentstr
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
