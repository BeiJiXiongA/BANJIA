
//
//  AddNotificationViewController.m
//  School
//
//  Created by TeekerZW on 14-2-18.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AddNotificationViewController.h"
#import "MySwitchView.h"
#import "Header.h"
#import "ClassesListViewController.h"

@interface AddNotificationViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextViewDelegate,
MySwitchDel,
UITextViewDelegate,
SelectClasses>
{
    UITextView *contentHolder;
    UITextView *contentTextView;
    UITableView *objectsTableView;
    NSArray *objectsArray;
    NSArray *objectsValues;
    
    UILabel *replayLabel;
    MySwitchView *replaySwitch;
    NSInteger replay;
    
    BOOL objectOpen;
    
    NSString *objectString;
    NSString *objectsValueString;
    
    UIButton *sendButton;
}
@end

@implementation AddNotificationViewController
@synthesize classID,fromClass;
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
    
    self.titleLabel.text = @"发布通知";
    replay = 1;
        
    [self.backButton addTarget:self action:@selector(myBack) forControlEvents:UIControlEventTouchUpInside];
    
    objectsArray = [[NSArray alloc] initWithObjects:@"全体师生和家长",@"全体家长",@"全体老师",@"全体学生", nil];
    objectsValues = [[NSArray alloc] initWithObjects:@"all",@"parents",@"teachers", @"students",nil];
    
    objectString = [objectsArray objectAtIndex:0];
    objectsValueString = [objectsValues objectAtIndex:0];
    
    objectOpen = NO;
    
    objectString = [objectsArray firstObject];
    objectsValueString = @"all";
    
    contentHolder = [[UITextView alloc] initWithFrame:CGRectMake(18, UI_NAVIGATION_BAR_HEIGHT+20, 200, 30)];
    contentHolder.text = @"填写通知内容";
    contentHolder.textColor = COMMENTCOLOR;
    contentHolder.font = [UIFont systemFontOfSize:18];
    contentHolder.textColor = [UIColor lightGrayColor];
    contentHolder.backgroundColor = [UIColor clearColor];
    
    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 300)/2, UI_NAVIGATION_BAR_HEIGHT+10.5, 300, 95)];
    inputImageView.layer.cornerRadius = 7;
    inputImageView.clipsToBounds = YES;
    inputImageView.layer.borderWidth = 0.3;
    inputImageView.layer.borderColor = TIMECOLOR.CGColor;
    inputImageView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:inputImageView];
    
    [self.bgView addSubview:contentHolder];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, contentHolder.frame.origin.y, SCREEN_WIDTH-40, 85)];
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.delegate = self;
    contentTextView.textColor = TITLE_COLOR;
    contentTextView.font = [UIFont systemFontOfSize:19];
    [self.bgView addSubview:contentTextView];
    
    UILabel *objectLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, contentTextView.frame.size.height+contentTextView.frame.origin.y+20, 80, 30)];
    objectLabel.text = @"发送对象";
    objectLabel.textColor = TITLE_COLOR;
    objectLabel.font = [UIFont systemFontOfSize:16];
    objectLabel.backgroundColor = [UIColor clearColor];
//    [self.bgView addSubview:objectLabel];
    
    objectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(objectLabel.frame.size.width+contentHolder.frame.origin.x+10, objectLabel.frame.origin.y+30, 150, 0) style:UITableViewStylePlain];
    objectsTableView.delegate = self;
    objectsTableView.dataSource = self;
    [self.bgView addSubview:objectsTableView];
    if ([objectsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [objectsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    replayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+9, 150, 30)];
    replayLabel.textColor = COMMENTCOLOR;
    replayLabel.backgroundColor = [UIColor clearColor];
    replayLabel.font = [UIFont systemFontOfSize:18];
    replayLabel.text = @"填写通知内容";
//    [self.bgView addSubview:replayLabel];
    
    replaySwitch = [[MySwitchView alloc] initWithFrame:CGRectMake(replayLabel.frame.size.width+replaySwitch.frame.origin.x+20, replayLabel.frame.origin.y, 80, 30)];
//    [self.bgView addSubview:replaySwitch];
    replaySwitch.selectView.backgroundColor = [UIColor whiteColor];
    replaySwitch.selectView.frame = CGRectMake(replaySwitch.frame.size.width/2, 0, replaySwitch.frame.size.width/2, replaySwitch.frame.size.height);
    replaySwitch.mySwitchDel = self;
    replaySwitch.leftView.layer.borderColor = [UIColor clearColor].CGColor;
    replaySwitch.rightView.layer.borderColor = [UIColor clearColor].CGColor;
    replaySwitch.selectView.layer.borderColor = [UIColor clearColor].CGColor;
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    leftLabel.text = @"YES";
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.textColor = [UIColor whiteColor];
    [replaySwitch.leftView addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    rightLabel.text = @"NO";
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    [replaySwitch.rightView addSubview:rightLabel];
    
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.frame = CGRectMake(SCREEN_WIDTH-60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [sendButton setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendnotice) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:sendButton];
    
    UIButton *sendButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton1.backgroundColor = [UIColor clearColor];
    [sendButton1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    sendButton1.frame = CGRectMake((SCREEN_WIDTH-300)/2, inputImageView.frame.size.height+inputImageView.frame.origin.y+10, 300, 42);
    [sendButton1 setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton1 addTarget:self action:@selector(sendnotice) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:sendButton1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    [contentTextView resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)myBack
{
    if ([self.updel respondsToSelector:@selector(update:)])
    {
        [self.updel update:NO];
    }
    [self .navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *objectCell = @"objectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:objectCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objectCell];
    }
    cell.textLabel.text = [objectsArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = TITLE_COLOR;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    objectString = [objectsArray objectAtIndex:indexPath.row];
    objectsValueString = [objectsValues objectAtIndex:indexPath.row];
    objectString = [objectsArray objectAtIndex:indexPath.row];
//    [objectButton setTitle:objectString forState:UIControlStateNormal];
    objectOpen = NO;
    [objectsTableView reloadData];
}

-(void)openObjectTableView
{
    objectOpen = !objectOpen;
    [objectsTableView reloadData];
}

#pragma mark - mySwitchDelegate
-(void)switchStateChanged:(MySwitchView *)mySwitchView
{
    if ([mySwitchView isOpen])
    {
        replay = 0;
        DDLOG(@"replaySwitch--on===%ld",(long)replay);
    }
    else
    {
        replay = 1;
        DDLOG(@"replaySwitch--off==%ld",(long)replay);
    }
}

-(void)sendnotice
{
    if ([contentTextView.text length] <= 0)
    {
        [Tools showAlertView:@"请输入公告内容" delegateViewController:nil];
        return ;
    }

    if (!fromClass)
    {
        ClassesListViewController *classelistVC = [[ClassesListViewController alloc] init];
        classelistVC.selectClassdel = self;
        [self.navigationController pushViewController:classelistVC animated:YES];
        return ;
    }
    [self addNotification:classID];
}

-(void)selectClasses:(NSArray *)selectClassesArray
{
    if ([selectClassesArray count] > 0)
    {
        [self addNotification:[selectClassesArray firstObject]];
    }
}

-(void)addNotification:(NSString *)classid
{
    
    if(fromClass && [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] <= 0)
    {
        [Tools showAlertView:@"您没有权限" delegateViewController:nil];
        return ;
    }
    
    if ([contentTextView.text length] <= 0)
    {
        [Tools showAlertView:@"请输入公告内容" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classid,
                                                                      @"content":contentTextView.text,
                                                                      @"view":objectsValueString,
                                                                      @"c_read":[NSNumber numberWithInteger:replay]
//                                                                      @"role":[[NSUserDefaults standardUserDefaults] objectForKey:@"role"]
                                                                      } API:ADDNOTIFICATION];
        [request setCompletionBlock:^{
            sendButton.enabled = YES;
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addNoti===%@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.updel respondsToSelector:@selector(update:)])
                {
                    [self.updel update:YES];
                }
                [Tools showAlertView:@"班级通知发布成功" delegateViewController:nil];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                if ([[ud objectForKey:FROMWHERE] isEqualToString:FROMCLASS])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools hideProgress:self.bgView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            sendButton.enabled = YES;
        }];
        [Tools showProgress:self.bgView];
        sendButton.enabled = NO;
        [request startAsynchronous];
    }
}

-(void)readNotice:(NSString *)noticeID andClassid:(NSString *)classid
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":noticeID,
                                                                      @"c_id":classid
                                                                      } API:READNTICES];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                DDLOG(@"read success!");
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


#pragma mark - textview
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 0)
    {
        contentHolder.text = @"";
    }
    else
    {
        contentHolder.text = @"请填写公告内容";
    }
    if ([textView.text length] > 200)
    {
        
        [Tools showAlertView:@"公告内容不能超多200字" delegateViewController:nil];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length] > 200)
    {
        textView.text = [textView.text substringToIndex:200];
        return NO;
    }
    return YES;
}
@end
