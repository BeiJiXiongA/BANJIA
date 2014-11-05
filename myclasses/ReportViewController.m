//
//  ReportViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-3.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ReportViewController.h"
#import "InfoCell.h"

@interface ReportViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSArray *reportTypes;
    NSArray *repotrTypesSim;
    NSInteger selectIndex;
    UIButton *submitButton;
    UITableView *reportTableView;
    UILabel *tipLabel;
    MyTextField *contentTf;
}
@end

@implementation ReportViewController
@synthesize reportUserid,reportContentID,reportType;
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
    self.titleLabel.text = @"举报";
    
    selectIndex = 2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, 100, 30)];
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    tipLabel.text = @"举报类型";
    tipLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:tipLabel];
    
    
    if ([reportType isEqualToString:@"notice"] ||
        [reportType isEqualToString:@"diary"])
    {
        reportTypes = [NSArray arrayWithObjects:@"色情",@"暴力",@"广告",@"反动",@"侵犯版权",@"其他", nil];
        repotrTypesSim = [NSArray arrayWithObjects:@"SeQing",@"BaoLi",@"GuangGao",@"FanDong",@"QinFanBanQuan",@"QiTa", nil];
    }
    else if([reportType isEqualToString:@"people"])
    {
        reportTypes = [NSArray arrayWithObjects:@"传播色情",@"传播暴力",@"广告骚扰",@"欺诈骗钱",@"其他", nil];
        repotrTypesSim = [NSArray arrayWithObjects:@"SeQing",@"BaoLi",@"GuangGao",@"ZhaPian",@"QiTa", nil];
    }

    reportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+50, SCREEN_WIDTH, [reportTypes count] * 40) style:UITableViewStylePlain];
    reportTableView.delegate = self;
    reportTableView.dataSource = self;
    [self.bgView addSubview:reportTableView];
    reportTableView.scrollEnabled = NO;
    
    if ([reportTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [reportTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    contentTf = [[MyTextField alloc] init];
    contentTf.frame = CGRectMake(0, reportTableView.frame.origin.y+reportTableView.frame.size.height+20, SCREEN_WIDTH, 40);
    contentTf.textColor = TITLE_COLOR;
    contentTf.placeholder = @"问题描述";
    contentTf.delegate = self;
    contentTf.background = nil;
    contentTf.text = @"";
    contentTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    contentTf.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:contentTf];
    
    submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(30, contentTf.frame.origin.y+contentTf.frame.size.height+20, SCREEN_WIDTH-60, 40);
    [submitButton setTitle:@"确定" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitReport) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:submitButton];
    [submitButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    
}
#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    
    [UIView animateWithDuration:0.25 animations:^{
        
        
        if ([reportType isEqualToString:@"notice"] ||
            [reportType isEqualToString:@"diary"])
        {
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-140);
        }
        else if([reportType isEqualToString:@"people"])
        {
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-80);
        }
        
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reportTypes count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reportcell = @"reporttypecell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reportcell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reportcell];
    }
    cell.nameLabel.frame = CGRectMake(20, 5, 100, 30);
    cell.nameLabel.text = [reportTypes objectAtIndex:indexPath.row];
    cell.nameLabel.textColor = TITLE_COLOR;
    
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    
    if (selectIndex == indexPath.row)
    {
        cell.headerImageView.hidden = NO;
        cell.headerImageView.frame = CGRectMake(SCREEN_WIDTH-50, 7, 25, 25);
        [cell.headerImageView setImage:[UIImage imageNamed:@"selectBtn"]]; //gou2
    }
    else
    {
        cell.headerImageView.hidden = YES;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contentTf resignFirstResponder];
    selectIndex = indexPath.row;
    [tableView reloadData];
}

-(void)submitReport
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":reportContentID,
                                                                      @"p_id":reportUserid,
                                                                      @"type":[NSString stringWithFormat:@"%@-%@",reportType,[repotrTypesSim objectAtIndex:selectIndex]],
                                                                      @"content":contentTf.text}
                                                                API:MB_ADVISE];

        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"report== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                reportTableView.hidden = YES;
                submitButton.hidden = YES;
                contentTf.hidden = YES;
                tipLabel.frame = CGRectMake(30, SCREEN_HEIGHT/2-30, SCREEN_WIDTH-60, 60);
                tipLabel.numberOfLines = 2;
                tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
                tipLabel.textAlignment = NSTextAlignmentCenter;
                tipLabel.text = @"举报成功，我们会尽快查看您的举报！";
                
                [contentTf resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
