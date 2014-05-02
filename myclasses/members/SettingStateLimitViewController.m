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
}
@end

@implementation SettingStateLimitViewController
@synthesize name,userid,classID,role;
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
    self.titleLabel.text = @"设置发言权限";
    
    if ([role isEqualToString:@"parents"])
    {
        limitArray = [[NSArray alloc] initWithObjects:@"赞",@"评论",@"给老师发消息", nil];
    }
    else if([role isEqualToString:@"students"])
    {
        limitArray = [[NSArray alloc] initWithObjects:@"赞",@"评论",@"接受班级动态", nil];
    }

    limitTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-20, 150) style:UITableViewStylePlain];
    limitTableView.delegate = self;
    limitTableView.dataSource = self;
    [self.bgView addSubview:limitTableView];
    
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        DDLOG(@"%@===%@", UserSendLike,[optionDict objectForKey:UserSendLike]);
        if ([[optionDict objectForKey:UserSendLike] integerValue] == 0)
        {
            [cell.mySwitch setOn:NO];
        }
        else
        {
            [cell.mySwitch setOn:YES];
        }
    }
    else if (indexPath.row == 1)
    {
        if ([[optionDict objectForKey:UserSendComment] integerValue] == 0)
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
        if ([role isEqualToString:@"students"])
        {
            if ([[optionDict objectForKey:UserSendComment] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
        else if([role isEqualToString:@"parents"])
        {
            if ([[optionDict objectForKey:UserChatTeacher] integerValue] == 0)
            {
                [cell.mySwitch setOn:NO];
            }
            else
            {
                [cell.mySwitch setOn:YES];
            }
        }
    }
    cell.mySwitch.tag = indexPath.row*1000;
    [cell.mySwitch addTarget:self action:@selector(switchchange:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
        [self settingValue:value forKay:UserSendLike];
    }
    else if(sw.tag/1000 == 1)
    {
        [self settingValue:value forKay:UserSendComment];
    }
    else if(sw.tag/1000 == 2)
    {
        if ([role isEqualToString:@"students"])
        {
            [self settingValue:value forKay:UserReceiveDiary];
        }
        else if([role isEqualToString:@"parents"])
        {
            [self settingValue:value forKay:UserChatTeacher];
        }
    }
}

-(void)settingValue:(NSString *)value forKay:(NSString *)key
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
                [optionDict setObject:value forKey:key];
                [limitTableView reloadData];
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
