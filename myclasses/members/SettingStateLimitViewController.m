//
//  SettingStateLimitViewController.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SettingStateLimitViewController.h"
#import "LimitCell.h"

@interface SettingStateLimitViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *limitArray;
    UITableView *limitTableView;
    NSMutableDictionary *optDict;
    NSMutableDictionary *optionDict;
    
    NSString *classID;
}
@end

@implementation SettingStateLimitViewController
@synthesize name,userid,role,userOptDict,updateUserSettingDel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        userOptDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"设置发言权限";
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    if ([role isEqualToString:@"parents"])
    {
        limitArray = [[NSArray alloc] initWithObjects:@"赞",@"评论",@"给老师发消息", nil];
    }
    else if([role isEqualToString:@"students"])
    {
        limitArray = [[NSArray alloc] initWithObjects:@"赞",@"评论", nil];
    }

    CGFloat tableViewHeight = 150;
    if ([role isEqualToString:@"students"])
    {
        tableViewHeight = 100;
    }
    
    limitTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-20, tableViewHeight) style:UITableViewStylePlain];
    limitTableView.delegate = self;
    limitTableView.dataSource = self;
    limitTableView.layer.cornerRadius = 5;
    limitTableView.clipsToBounds = YES;
    [self.bgView addSubview:limitTableView];
    
    if ([limitTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [limitTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
//    [self getUserInfo];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [limitArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *limitCell = @"limitCell";
    LimitCell *cell = [tableView dequeueReusableCellWithIdentifier:limitCell];
    if (cell == nil)
    {
        cell = [[LimitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:limitCell];
    }
    cell.contentLabel.text = [limitArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0)
    {
        if ([[userOptDict objectForKey:UserSendLike] intValue] == 0)
        {
            [cell.mySwitch isOn:NO];
        }
        else if ([[userOptDict objectForKey:UserSendLike] intValue] == 1)
        {
            [cell.mySwitch isOn:YES];
        }
    }
    else if (indexPath.row == 1)
    {
        if ([[userOptDict objectForKey:UserSendComment] intValue] == 0)
        {
            [cell.mySwitch isOn:NO];
        }
        else if ([[userOptDict objectForKey:UserSendComment] intValue] == 1)
        {
            [cell.mySwitch isOn:YES];
        }
    }
    else if(indexPath.row == 2)
    {
        if ([role isEqualToString:@"students"])
        {
            if ([[userOptDict objectForKey:UserReceiveDiary] intValue] == 0)
            {
                [cell.mySwitch isOn:NO];
            }
            else if ([[userOptDict objectForKey:UserReceiveDiary] intValue] == 1)
            {
                [cell.mySwitch isOn:YES];
            }
        }
        else if([role isEqualToString:@"parents"])
        {
            if ([[userOptDict objectForKey:UserChatTeacher] intValue] == 0)
            {
                [cell.mySwitch isOn:NO];
            }
            else if ([[userOptDict objectForKey:UserChatTeacher] intValue] == 1)
            {
                [cell.mySwitch isOn:YES];
            }
        }
    }
    cell.mySwitch.tag = indexPath.row+1000;
    [cell.mySwitch addTarget:self action:@selector(switchchange:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)switchchange:(KLSwitch *)sw
{
    switch (sw.tag % 1000)
    {
        case 0:
            if ([[userOptDict objectForKey:UserSendLike] intValue] == 0)
            {
                [self settingValue:@"1" forKay:UserSendLike withSwitch:sw];
                [userOptDict setObject:@"1" forKey:UserSendLike];
            }
            else if ([[userOptDict objectForKey:UserSendLike] intValue] == 1)
            {
                [self settingValue:@"0" forKay:UserSendLike withSwitch:sw];
                [userOptDict setObject:@"0" forKey:UserSendLike];
            }
            break;
        case 1:
            if ([[userOptDict objectForKey:UserSendComment] intValue] == 0)
            {
                [self settingValue:@"1" forKay:UserSendComment withSwitch:sw];
                [userOptDict setObject:@"1" forKey:UserSendComment];
            }
            else if ([[userOptDict objectForKey:UserSendComment] intValue] == 1)
            {
                [self settingValue:@"0" forKay:UserSendComment withSwitch:sw];
                [userOptDict setObject:@"0" forKey:UserSendComment];
            }
            break;
        case 2:
        {
            if ([role isEqualToString:@"students"])
            {
                if ([[userOptDict objectForKey:UserReceiveDiary] intValue] == 0)
                {
                    [self settingValue:@"1" forKay:UserReceiveDiary withSwitch:sw];
                    [userOptDict setObject:@"1" forKey:UserReceiveDiary];
                }
                else if ([[userOptDict objectForKey:UserReceiveDiary] intValue] == 1)
                {
                    [self settingValue:@"0" forKay:UserReceiveDiary withSwitch:sw];
                    [userOptDict setObject:@"0" forKey:UserReceiveDiary];
                }
            }
            else if([role isEqualToString:@"parents"])
            {
                if ([[userOptDict objectForKey:UserChatTeacher] intValue] == 0)
                {
                    [self settingValue:@"1" forKay:UserChatTeacher withSwitch:sw];
                    [userOptDict setObject:@"1" forKey:UserChatTeacher];
                }
                else if ([[userOptDict objectForKey:UserChatTeacher] intValue] == 1)
                {
                    [self settingValue:@"0" forKay:UserChatTeacher withSwitch:sw];
                    [userOptDict setObject:@"0" forKey:UserChatTeacher];
                }
            }
            break;
        }
        default:
            break;
    }
}

-(void)settingValue:(NSString *)value forKay:(NSString *)key withSwitch:(KLSwitch *)sw
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"o_id":userid,
                                                                      @"s_k":key,
                                                                      @"s_v":value
                                                                      } API:MB_SETUSERSETOFCLASS];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [userOptDict setObject:value forKey:key];
                [Tools showTips:@"设置成功" toView:self.bgView];
                
                if ([value intValue] == 0)
                {
                    [sw isOn:NO];
                }
                else if([value intValue] == 1)
                {
                    [sw isOn:YES];
                }
                
                if ([self.updateUserSettingDel respondsToSelector:@selector(updateUserSeting)])
                {
                    [self.updateUserSettingDel updateUserSeting];
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
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":userid,
                                                                      @"c_id":classID
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getusetinfo-responsedict==%@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                if (![[[dict objectForKey:@"classInfo"] objectForKey:@"opt"]isEqual:[NSNull null]])
                {
                    optionDict = [[NSMutableDictionary alloc] initWithDictionary:[[dict objectForKey:@"classInfo"] objectForKey:@"opt"]];
                }
                DDLOG(@"option=%@",optionDict);
                [limitTableView reloadData];
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
