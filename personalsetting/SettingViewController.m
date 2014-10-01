//
//  SettingViewController.m
//  School
//
//  Created by TeekerZW on 3/20/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SettingViewController.h"
#import "Header.h"
#import "LimitCell.h"
#import "WelcomeViewController.h"
#import <MessageUI/MessageUI.h>
#import "AboutUsViewController.h"
#import "SendAdviseViewController.h"
#import "KKNavigationController.h"
#import "UserProtocolViewController.h"
#import "SDImageCache.h"

#define SWITCHTAG   1000
#define CLEARCACHE   2000
#define LOGOUTTAG    3000
#define NEWVERSION   4000

@interface SettingViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate>
{
    UITableView *settingTableView;
    NSArray *setArray1;
    NSArray *setArray2;
    NSArray *setArray3;
    NSMutableDictionary *settingDict;
    
    NSString *_trackViewUrl;
    NSUserDefaults *ud;
}
@end

@implementation SettingViewController

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
    
    self.titleLabel.text = @"系统设置";
    setArray1 = [[NSArray alloc] initWithObjects:@"收到公告时声音提醒",@"收到公告时手机震动",@"新班级日记提醒",@"好友消息手机震动", nil];
    setArray2 = [[NSArray alloc] initWithObjects:@"检查版本更新",@"手动清除缓存", nil];
    setArray3 = [[NSArray alloc] initWithObjects:@"关于我们",@"意见反馈",@"给五星好评",@"用户协议",@"", nil];
    
    ud = [NSUserDefaults standardUserDefaults];
    
    DDLOG(@"NewNoticeAlert=%@++NewChatAlert=%@++NewNoticeMotion=%@++NewDiaryAlert=%@",[ud objectForKey:NewNoticeAlert],[ud objectForKey:NewChatAlert],[ud objectForKey:NewNoticeMotion],[ud objectForKey:NewDiaryAlert]);
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"useropt"] count] > 0)
    {
        settingDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"useropt"];
    }
    else
    {
        settingDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    settingTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:settingTableView];
    
//    [self getUserSet];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [setArray1 count];
    }
    else if(section == 1)
    {
        return [setArray2 count];
    }
    else if (section == 2)
    {
        return [setArray3 count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8.5, SCREEN_WIDTH, 20)];
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    headerLabel.font = [UIFont systemFontOfSize:16];
    
    if (section == 0)
    {
        headerLabel.text = @"  消息设置";
    }
    else if(section == 1)
    {
        headerLabel.text = @"  功能设置";
    }
    else if(section == 2)
    {
        headerLabel.text = @"  其他";
    }
    
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if (indexPath.row == [setArray3 count]-1)
        {
            return 73;
        }
    }
    return 43;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *settingcell = @"settingcell";
    LimitCell *cell = [tableView dequeueReusableCellWithIdentifier:settingcell];
    if (cell == nil)
    {
        cell = [[LimitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingcell];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    for(UIView *v in cell.contentView.subviews)
    {
        if ([v isKindOfClass:[UIButton class]])
        {
            [v removeFromSuperview];
        }
    }
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    cell.lineImageView.frame = CGRectMake(0, cellHeight-0.3, cell.frame.size.width, 0.3);
    cell.lineImageView.backgroundColor = LineBackGroudColor;
    
    cell.mySwitch.hidden = YES;
    cell.mySwitch.frame = CGRectMake( SCREEN_WIDTH-65, 7, 50, 30);
    cell.mySwitch.tag = indexPath.row + 3333;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    cell.contentLabel.frame = CGRectMake(10, 6.5, 150, 30);
    cell.contentLabel.textColor = TITLE_COLOR;
    cell.markLabel.text = @"";
    cell.markLabel.frame = CGRectMake(SCREEN_WIDTH - 150, 6.5, 120, 30);
    if (indexPath.section == 0)
    {
        cell.arrowImageView.hidden = YES;
        cell.contentLabel.text = [setArray1 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = NO;
        if (indexPath.row == 0)
        {
            if ([ud objectForKey:NewNoticeAlert])
            {
                if ([[ud objectForKey:NewNoticeAlert] integerValue] == 0)
                {
                    [cell.mySwitch isOn:NO];
                }
                else
                {
                    [cell.mySwitch isOn:YES];
                }
            }
            else
            {
                [cell.mySwitch isOn:YES];
            }
        }
        else if(indexPath.row == 1)
        {
            if ([ud objectForKey:NewNoticeMotion])
            {
                if ([[ud objectForKey:NewNoticeMotion] integerValue] == 0)
                {
                    [cell.mySwitch isOn:NO];
                }
                else
                {
                    [cell.mySwitch isOn:YES];
                }
            }
            else
            {
                [cell.mySwitch isOn:YES];
            }
        }
        else if(indexPath.row == 2)
        {
            if ([ud objectForKey:NewDiaryAlert])
            {
                if ([[ud objectForKey:NewDiaryAlert] integerValue] == 0)
                {
                    [cell.mySwitch isOn:NO];
                }
                else
                {
                    [cell.mySwitch isOn:YES];
                }
            }
            else
            {
                [cell.mySwitch isOn:YES];
            }
            
        }
        else if (indexPath.row == 3)
        {
            if ([ud objectForKey:NewChatAlert])
            {
                if ([[ud objectForKey:NewChatAlert] integerValue] == 0)
                {
                    [cell.mySwitch isOn:NO];
                }
                else
                {
                    [cell.mySwitch isOn:YES];
                }
            }
            else
            {
                [cell.mySwitch isOn:YES];
            }
        }
        cell.mySwitch.tag = indexPath.row*SWITCHTAG;
        [cell.mySwitch addTarget:self action:@selector(switchchange:) forControlEvents:UIControlEventValueChanged];
       
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    else if (indexPath.section == 1)
    {
        cell.contentLabel.text = [setArray2 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = YES;
        if (indexPath.row == 1)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            CGFloat cachesize = (((float)[[SDImageCache sharedImageCache] getSize])/1024/1024);
            if (cachesize == 0)
            {
                cachesize = 0;
            }
            
            cell.markLabel.text = [NSString stringWithFormat:@"%.2fM",cachesize];
        }
        else
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:SCHEMETYPE] isEqualToString:SCHEMEDEBUG])
            {
                cell.markLabel.text = [NSString stringWithFormat:@"当前版本%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentVersion"]];
            }
            else
            {
                cell.markLabel.text = [NSString stringWithFormat:@"当前版本%@",[Tools client_ver]];
            }
            
//            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discovery_arrow"]];
//            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 12.5, 10, 15)];
        }
        
    }
    else if(indexPath.section == 2)
    {
        cell.contentLabel.text = [setArray3 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = YES;
        if (indexPath.row == [setArray3 count]-1)
        {
            cell.arrowImageView.hidden = YES;
            UIButton *loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
            loginOutButton.frame = CGRectMake(38.5, 16.5, SCREEN_WIDTH-77, 40);
            [loginOutButton setBackgroundImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
            [loginOutButton setTitle:@"注销" forState:UIControlStateNormal];
            [loginOutButton addTarget:self action:@selector(askloginOut) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:loginOutButton];
            cell.backgroundColor = self.bgView.backgroundColor;
            cell.contentView.backgroundColor = self.bgView.backgroundColor;
            cell.backgroundView = nil;
            cell.lineImageView.hidden = YES;
        }
        else
        {
            cell.arrowImageView.hidden = NO;
            cell.arrowImageView.frame = CGRectMake(SCREEN_WIDTH-25, 14, 10, 15);
            [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            cell.arrowImageView.backgroundColor = [UIColor whiteColor];
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
            //版本更新
            [self updateNewVersion];
        }
        else if (indexPath.row == 1)
        {
            //清除内存
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要清楚缓存吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.tag = CLEARCACHE;
            [al show];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            //关于我们
            AboutUsViewController *aboutUs = [[AboutUsViewController alloc] init];
            [self.navigationController pushViewController:aboutUs animated:YES];
            
        }
        else if (indexPath.row == 1)
        {
            //意见反馈

            
            SendAdviseViewController *sendAdviseVC = [[SendAdviseViewController alloc] init];
            [self.navigationController pushViewController:sendAdviseVC animated:YES];
        }
        else if(indexPath.row == 2)
        {
            [self getNewVersionUrl];
        }
        else if(indexPath.row == 3)
        {
            UserProtocolViewController *userprotocol = [[UserProtocolViewController alloc] init];
            [self.navigationController pushViewController:userprotocol animated:YES];
        }
    }
}

#pragma mark - updateNewVersion
-(void)updateNewVersion
{
    if ([Tools NetworkReachable])
    {
        NSString *appleID = @"862315597";
        NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
        __weak ASIHTTPRequest *request = [Tools getRequestWithDict:@{} andHostUrl:urlStr];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newViewsion== responsedict %@",responseDict);
            int resultCount = [[responseDict objectForKey:@"resultCount"] intValue];
            if (resultCount >= 1) {
                NSMutableArray *results = [responseDict objectForKey:@"results"];
                NSDictionary *releaseInfo = [results objectAtIndex:0];
                
                NSString *latestVersion = [releaseInfo objectForKey:@"version"];
//                double doubleUpdateVersion = [latestVersion doubleValue];
                _trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                NSString *trackName = [releaseInfo objectForKey:@"trackName"];
                
                
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
                
                if ([currentVersion compare:latestVersion] < 0) {
                    
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:trackName
                                                       message:@"有新版本，是否升级！"
                                                      delegate: self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles: @"升级", nil];
                    alert.tag = NEWVERSION;
                    [alert show];
                }
                else{
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:trackName
                                                       message:@"您现在用的已经是最新版，最最新版值得您期待！"
                                                      delegate: nil
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles: nil, nil];
                    [alert show];
                }
            }else{
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"更新检查失败"
                                                   message:@"啊哦，貌似暂时搞不定版本信息，稍后再试试吧，期待你的好评哦！"
                                                  delegate: nil
                                         cancelButtonTitle:@"好的"
                                         otherButtonTitles: nil, nil];
                [alert show];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)getNewVersionUrl
{
    if ([Tools NetworkReachable])
    {
        NSString *appleID = @"862315597";
        NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
        __weak ASIHTTPRequest *request = [Tools getRequestWithDict:@{} andHostUrl:urlStr];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newViewsion== responsedict %@",responseDict);
            int resultCount = [[responseDict objectForKey:@"resultCount"] intValue];
            if (resultCount >= 1) {
                NSMutableArray *results = [responseDict objectForKey:@"results"];
                NSDictionary *releaseInfo = [results objectAtIndex:0];
                _trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                if ([_trackViewUrl length] <= 0)
                {
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:nil
                                                       message:@"没有拿到APP地址，稍后再试试哦。"
                                                      delegate: nil
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles: nil, nil];
                    [alert show];
                    return ;
                }

                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_trackViewUrl]]];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
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
    NSArray *toRecipients = [NSArray arrayWithObject: @"ios-support@banjiaedu.com"];
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

- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)askloginOut
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要注销登录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注销登录", nil];
    al.tag = LOGOUTTAG;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == LOGOUTTAG)
    {
        if (buttonIndex == 1)
        {
            [self logOut];
        }
    }
    else if(alertView.tag == CLEARCACHE)
    {
        if (buttonIndex == 1)
        {
            //清楚缓存
            [[SDImageCache sharedImageCache] clearDisk];
            [settingTableView reloadData];
        }
    }
    else if(alertView.tag == NEWVERSION)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_trackViewUrl]]];
        }
    }
}

-(void)logOut
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]}
                                                                API:MB_LOGOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"logout== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools exit];
                WelcomeViewController *welcomeViewCOntroller = [[WelcomeViewController alloc]init];
                KKNavigationController *welNav = [[KKNavigationController alloc] initWithRootViewController:welcomeViewCOntroller];
                [self.navigationController presentViewController:welNav animated:YES completion:nil];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
    
}


-(void)switchchange:(KLSwitch *)sw
{
    if (sw.tag/1000 == 0)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewNoticeAlert] intValue] == 0)
        {
            [self settingValue:@"1" forKay:NewNoticeAlert withSwitch:sw];
            [sw isOn:YES];
        }
        else
        {
            [self settingValue:@"0" forKay:NewNoticeAlert withSwitch:sw];
            [sw isOn:NO];
        }
    }
    else if(sw.tag/1000 == 1)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewNoticeMotion] intValue] == 0)
        {
            [self settingValue:@"1" forKay:NewNoticeMotion withSwitch:sw];
            [sw isOn:YES];
        }
        else
        {
            [self settingValue:@"0" forKay:NewNoticeMotion withSwitch:sw];
            [sw isOn:NO];
        }
    }
    else if(sw.tag/1000 == 2)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewDiaryAlert] intValue] == 0)
        {
            [self settingValue:@"1" forKay:NewDiaryAlert withSwitch:sw];
            [sw isOn:YES];
        }
        else
        {
            [self settingValue:@"0" forKay:NewDiaryAlert withSwitch:sw];
            [sw isOn:NO];
        }
    }
    else if(sw.tag/1000 == 3)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewChatAlert] intValue] == 0)
        {
            [self settingValue:@"1" forKay:NewChatAlert withSwitch:sw];
            [sw isOn:YES];
        }
        else
        {
            [self settingValue:@"0" forKay:NewChatAlert withSwitch:sw];
            [sw isOn:NO];
        }
    }
}

-(void)settingValue:(NSString *)value forKay:(NSString *)key withSwitch:(KLSwitch *)sw
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"s_k":key,
                                                                      @"s_v":[NSNumber numberWithInt:[value integerValue]]
                                                                      } API:MB_SETUSERSET];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [Tools showTips:@"设置成功" toView:self.bgView];
                
//                if ([value intValue] == 1)
//                {
//                    [sw isOn:YES];
//                }
//                else if([value intValue] == 0)
//                {
//                    [sw isOn:NO];
//                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}


-(void)getUserSet
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:MB_GETUSERSET];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getusetinfo-responsedict==%@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] count] > 0)
                {
                    settingDict = [[NSMutableDictionary alloc] initWithDictionary:[responseDict objectForKey:@"data"]];
                }
                [settingTableView reloadData];
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
@end
