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

#define SWITCHTAG   1000
#define CLEARCACHE   2000
#define LOGOUTTAG    3000

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *settingTableView;
    NSArray *setArray1;
    NSArray *setArray2;
    NSArray *setArray3;
    NSMutableDictionary *settingDict;
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
    
    self.titleLabel.text = @"个人设置";
    setArray1 = [[NSArray alloc] initWithObjects:@"收到公告时提醒",@"收到公告时手机震动",@"新班级日记提醒",@"好友消息提醒", nil];
    setArray2 = [[NSArray alloc] initWithObjects:@"检查版本更新",@"手动清除缓存", nil];
    setArray3 = [[NSArray alloc] initWithObjects:@"应用推荐",@"意见反馈",@"给五星好评",@"", nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"useropt"] count] > 0)
    {
        settingDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"useropt"];
    }
    else
    {
        settingDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    settingTableView.delegate = self;
    settingTableView.backgroundView = tableViewBg;
    settingTableView.dataSource = self;
    settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:settingTableView];
    
//    [self getUserSet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    headerLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    headerLabel.font = [UIFont systemFontOfSize:16];
    if (section == 0)
    {
        headerLabel.text = @"   消息设置";
    }
    else if(section == 1)
    {
        headerLabel.text = @"   功能设置";
    }
    else if(section == 2)
    {
        headerLabel.text = @"   其他";
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
    
    for(UIView *v in cell.contentView.subviews)
    {
        if ([v isKindOfClass:[UIButton class]])
        {
            [v removeFromSuperview];
        }
    }
    
    cell.mySwitch.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    if (SYSVERSION < 7)
    {
        cell.mySwitch.frame = CGRectMake(SCREEN_WIDTH-95, 6.5, 60, 30);
    }
    else
    {
        cell.mySwitch.frame = CGRectMake(SCREEN_WIDTH-75, 6.5, 60, 30);
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentLabel.frame = CGRectMake(10, 6.5, 150, 30);
    cell.contentLabel.textColor = TITLE_COLOR;
    cell.markLabel.text = @"";
    cell.markLabel.frame = CGRectMake(SCREEN_WIDTH - 150, 6.5, 120, 30);
    DDLOG(@"settingDict=%@",settingDict);
    if (indexPath.section == 0)
    {
        cell.contentLabel.text = [setArray1 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = NO;
        if (indexPath.row == 0)
        {
            if ([[settingDict objectForKey:NewNoticeAlert] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
        else if(indexPath.row == 1)
        {
            if ([[settingDict objectForKey:NewNoticeMotion] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
        else if(indexPath.row == 2)
        {
            if ([[settingDict objectForKey:NewDiaryAlert] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
        else if (indexPath.row == 3)
        {
            if ([[settingDict objectForKey:NewChatAlert] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
        cell.mySwitch.tag = indexPath.row*SWITCHTAG;
        [cell.mySwitch addTarget:self action:@selector(switchchange:) forControlEvents:UIControlEventValueChanged];
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
        cell.backgroundView = bgImageBG;
    }
    else if (indexPath.section == 1)
    {
        cell.contentLabel.text = [setArray2 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = YES;
        if (indexPath.row == 1)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.markLabel.text = [NSString stringWithFormat:@"%.2fM",[self folderSizeAtPath:[FTWCache pathString]]];
        }
        else
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 11.5, 10, 20)];
        }
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
        cell.backgroundView = bgImageBG;
    }
    else if(indexPath.section == 2)
    {
        cell.contentLabel.text = [setArray3 objectAtIndex:indexPath.row];
        cell.mySwitch.hidden = YES;
        if (indexPath.row == [setArray3 count]-1)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            UIButton *loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
            loginOutButton.frame = CGRectMake(38.5, 16.5, SCREEN_WIDTH-77, 40);
            [loginOutButton setBackgroundImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
            [loginOutButton setTitle:@"注销" forState:UIControlStateNormal];
            [loginOutButton addTarget:self action:@selector(askloginOut) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:loginOutButton];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
        }
        else
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 11.5, 10, 20)];
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
            cell.backgroundView = bgImageBG;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 1)
        {
            //清除内存
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要清楚缓存吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.tag = CLEARCACHE;
            [al show];
        }
    }
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
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要注销登录吗?" delegate:self cancelButtonTitle:@"再玩会儿" otherButtonTitles:@"注销登录", nil];
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
            [FTWCache resetCache];
            [settingTableView reloadData];
        }
    }
}

-(void)logOut
{
    if ([Tools NetworkReachable])
    {
        DDLOG(@"%@==%@",[Tools user_id],[Tools client_token]);
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
                WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] init];
                [self presentViewController:welcomeViewController animated:YES completion:nil];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
    
}


-(void)switchchange:(UISwitch *)sw
{
    NSString *value = @"";
    if ([sw isOn])
    {
        value = @"1";
    }
    else
    {
        value = @"0";
    }
    if (sw.tag/1000 == 0)
    {
        [self settingValue:value forKay:NewNoticeAlert];
    }
    else if(sw.tag/1000 == 1)
    {
        [self settingValue:value forKay:NewNoticeMotion];
    }
    else if(sw.tag/1000 == 2)
    {
        [self settingValue:value forKay:NewDiaryAlert];
    }
    else if(sw.tag/1000 == 3)
    {
        [self settingValue:value forKay:NewChatAlert];
    }
}

-(void)settingValue:(NSString *)value forKay:(NSString *)key
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
                [settingDict setObject:value forKey:key];
                [settingTableView reloadData];
                [Tools showTips:@"设置成功" toView:self.bgView];
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
