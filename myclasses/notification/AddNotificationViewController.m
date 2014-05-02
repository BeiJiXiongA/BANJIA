
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

@interface AddNotificationViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextViewDelegate,
MySwitchDel,
UITextViewDelegate>
{
    UITextView *contentHolder;
    UITextView *contentTextView;
    UITableView *objectsTableView;
    NSArray *objectsArray;
    NSArray *objectsValues;
    
    UIButton *objectButton;
    
    UILabel *replayLabel;
    MySwitchView *replaySwitch;
    NSInteger replay;
    
    BOOL objectOpen;
    
    NSString *objectString;
    NSString *objectsValueString;
}
@end

@implementation AddNotificationViewController
@synthesize classID;
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
    
    self.titleLabel.text = @"发布公告";
    replay = 1;
    
    [self.backButton addTarget:self action:@selector(myBack) forControlEvents:UIControlEventTouchUpInside];
    
    objectsArray = [[NSArray alloc] initWithObjects:@"全体师生和家长",@"全体家长",@"全体老师",@"全体学生", nil];
    objectsValues = [[NSArray alloc] initWithObjects:@"all",@"parents",@"teachers", @"students",nil];
    
    objectString = [objectsArray objectAtIndex:0];
    objectsValueString = [objectsValues objectAtIndex:0];
    
    objectOpen = NO;
    
    objectString = @"全体家长和学生";
    objectsValueString = @"all";
    
    contentHolder = [[UITextView alloc] initWithFrame:CGRectMake(18, UI_NAVIGATION_BAR_HEIGHT+8, 200, 30)];
    contentHolder.text = @"请填写公告内容";
    contentHolder.font = [UIFont systemFontOfSize:16];
    contentHolder.textColor = [UIColor lightGrayColor];
    contentHolder.backgroundColor = [UIColor clearColor];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, contentHolder.frame.origin.y-2, SCREEN_WIDTH-30, 120)];
    [inputImageView setImage:inputImage];
    [self.bgView addSubview:inputImageView];
    
    [self.bgView addSubview:contentHolder];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, contentHolder.frame.origin.y, SCREEN_WIDTH-40, 110)];
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.delegate = self;
    contentTextView.textColor = TITLE_COLOR;
    contentTextView.font = [UIFont systemFontOfSize:17];
    [self.bgView addSubview:contentTextView];
    
    UILabel *objectLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, contentTextView.frame.size.height+contentTextView.frame.origin.y+20, 80, 30)];
    objectLabel.text = @"发送对象";
    objectLabel.textColor = TITLE_COLOR;
    objectLabel.font = [UIFont systemFontOfSize:16];
    objectLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:objectLabel];
    
    objectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    objectButton.frame = CGRectMake(objectLabel.frame.size.width+contentHolder.frame.origin.x+10, objectLabel.frame.origin.y, 150, 30);
    [objectButton setBackgroundImage:[UIImage imageNamed:@"objectBg"] forState:UIControlStateNormal];
    [objectButton setTitle:objectString forState:UIControlStateNormal];
    [objectButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    objectButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [objectButton addTarget:self action:@selector(openObjectTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:objectButton];
    
    objectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(objectLabel.frame.size.width+contentHolder.frame.origin.x+10, objectLabel.frame.origin.y+30, 150, 0) style:UITableViewStylePlain];
    objectsTableView.delegate = self;
    objectsTableView.dataSource = self;
    [self.bgView addSubview:objectsTableView];
    
    replayLabel = [[UILabel alloc] init];
    replayLabel.frame = CGRectMake(15, objectsTableView.frame.size.height+objectsTableView.frame.origin.y+30, 200, 30);
    replayLabel.text = @"需要回执";
    replayLabel.textColor = TITLE_COLOR;
    replayLabel.font = [UIFont systemFontOfSize:16];
    replayLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:replayLabel];
    
    replaySwitch = [[MySwitchView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-200, replayLabel.frame.origin.y, 80, 30)];
    replaySwitch.selectView.frame = CGRectMake(replaySwitch.frame.size.width/2, 0, 40, replaySwitch.frame.size.height);
    replaySwitch.mySwitchDel = self;
    [self.bgView addSubview:replaySwitch];
    
    replaySwitch.leftView.layer.borderColor = [UIColor clearColor].CGColor;
    replaySwitch.rightView.layer.borderColor = [UIColor clearColor].CGColor;
    replaySwitch.selectView.layer.borderColor = [UIColor clearColor].CGColor;
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    leftLabel.text = @"YES";
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.backgroundColor = [UIColor colorWithRed:22.00/255.00 green:157.00/255.00 blue:195.00/255.00 alpha:1.0f];
    [replaySwitch.leftView addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    rightLabel.text = @"NO";
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = [UIColor colorWithRed:22.00/255.00 green:157.00/255.00 blue:195.00/255.00 alpha:1.0f];
    [replaySwitch.rightView addSubview:rightLabel];
    
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 35);
    [sendButton setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(addNOtification) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:sendButton];
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
    [self unShowSelfViewController];
}

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (objectOpen)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            objectsTableView.frame = CGRectMake(objectsTableView.frame.origin.x, objectsTableView.frame.origin.y, objectsTableView.frame.size.width, [objectsArray count]*30);
            replayLabel.frame = CGRectMake(15, objectsTableView.frame.size.height+objectsTableView.frame.origin.y+10, 200, 30);
            replaySwitch.frame = CGRectMake(SCREEN_WIDTH-200, replayLabel.frame.origin.y, 80, 30);
        }];
        return [objectsArray count];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            objectsTableView.frame = CGRectMake(objectsTableView.frame.origin.x, objectsTableView.frame.origin.y, objectsTableView.frame.size.width, 0);
            replayLabel.frame = CGRectMake(15, objectsTableView.frame.size.height+objectsTableView.frame.origin.y+10, 200, 30);
            replaySwitch.frame = CGRectMake(SCREEN_WIDTH-200, replayLabel.frame.origin.y, 80, 30);
        }];
    }
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
    [objectButton setTitle:objectString forState:UIControlStateNormal];
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
        replay = 1;
        DDLOG(@"replaySwitch--on===%ld",(long)replay);
    }
    else
    {
        replay = 0;
        DDLOG(@"replaySwitch--off==%ld",(long)replay);
    }
}

-(void)addNOtification
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] <= 0)
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
                                                                      @"c_id":classID,
                                                                      @"content":contentTextView.text,
                                                                      @"view":objectsValueString,
                                                                      @"c_read":[NSNumber numberWithInteger:replay]
                                                                      } API:ADDNOTIFICATION];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addNOti===%@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.updel respondsToSelector:@selector(update:)])
                {
                    [self.updel update:YES];
                }
                [self unShowSelfViewController];
            }
            else
            {
                [responseString writeToFile:@"/Users/tike/Desktop/Schools/error.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length] > 200)
    {
        [Tools showAlertView:@"公告内容不能超多200字" delegateViewController:nil];
        return NO;
    }
    return YES;
}
@end
