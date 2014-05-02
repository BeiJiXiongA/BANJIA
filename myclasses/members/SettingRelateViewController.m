//
//  SettingRelateViewController.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SettingRelateViewController.h"

@interface SettingRelateViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *studentsArray;
    UITableView *studentsTableView;
    BOOL showStudents;
    UILabel *studentNameLabel;
    
    UIImageView *bg2;
    NSArray *relateArray;
    BOOL showRelate;
    UITableView *relateTableView;
    UIButton *relateButton;
    
    UILabel *relateLabel;
    UITextField *relatextField;
    
    CGFloat yyy;
    
    NSString *studentId;
}
@end

@implementation SettingRelateViewController
@synthesize parentID,parentName,title,admin,classID;
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
    
    self.titleLabel.text = @"设置关系";
    showStudents = YES;
    showRelate = YES;
    
    studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    yyy = 140;
    UIImageView *bg1 = [[UIImageView alloc] initWithFrame:CGRectMake(27, yyy, SCREEN_WIDTH-124, 40)];
    [bg1 setImage:inputImage];
    [self.bgView addSubview:bg1];
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(32, yyy-30, SCREEN_WIDTH-54, 30)];
    tipLabel1.text = [NSString stringWithFormat:@"设置%@为哪位学生的家长:",parentName];
    tipLabel1.font = [UIFont systemFontOfSize:13];
    tipLabel1.textColor = [UIColor grayColor];
    tipLabel1.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel1];
    
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    studentButton.frame = CGRectMake(SCREEN_WIDTH-83, yyy, 40, 40);
    studentButton.backgroundColor = [UIColor clearColor];
    [studentButton setImage:[UIImage imageNamed:@"icon_peo"] forState:UIControlStateNormal];
    [studentButton addTarget:self action:@selector(showStudents) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:studentButton];
    
    studentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, yyy+40, SCREEN_WIDTH-124, 0) style:UITableViewStylePlain];
    studentsTableView.delegate = self;
    studentsTableView.dataSource = self;
    studentsTableView.tag = 1000;
    [self.bgView addSubview:studentsTableView];
    
    studentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, yyy+5, 60, 30)];
    studentNameLabel.backgroundColor = [UIColor clearColor];
    studentNameLabel.textColor = [UIColor grayColor];
    studentNameLabel.textAlignment = NSTextAlignmentCenter;
    studentNameLabel.font = [UIFont systemFontOfSize:15];
    studentNameLabel.text = @"学生姓名";
    [self.bgView addSubview:studentNameLabel];
    
    bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(27, yyy+90, 134, 40)];
    [bg2 setImage:inputImage];
    [self.bgView addSubview:bg2];
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(5, -30, SCREEN_WIDTH-54, 30)];
    tipLabel2.text = [NSString stringWithFormat:@"设置%@与同学的关系为:",parentName];
    tipLabel2.font = [UIFont systemFontOfSize:13];
    tipLabel2.textColor = [UIColor grayColor];
    tipLabel2.backgroundColor = [UIColor clearColor];
    [bg2 addSubview:tipLabel2];
    
    relateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, bg2.frame.size.width-40, 30)];
    relateLabel.backgroundColor = [UIColor clearColor];
    relateLabel.font = [UIFont systemFontOfSize:15];
    relateLabel.textColor = [UIColor grayColor];
    [bg2 addSubview:relateLabel];
    
    relateArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"输入", nil];
    
    relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relateButton.backgroundColor = [UIColor greenColor];
    relateButton.frame = CGRectMake(bg2.frame.size.width+bg2.frame.origin.x-40, bg2.frame.origin.y, 40, 35);
    [relateButton addTarget:self action:@selector(selectRelate) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:relateButton];
    
    relateTableView = [[UITableView alloc] initWithFrame:CGRectMake(bg2.frame.origin.x, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, 0) style:UITableViewStylePlain];
    relateTableView.delegate = self;
    relateTableView.dataSource = self;
    relateTableView.tag = 2000;
    [self.bgView addSubview:relateTableView];
    
    relatextField = [[UITextField alloc] initWithFrame:CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+30, relateButton.frame.origin.y, 90, 40)];
    relatextField.background = inputImage;
    relatextField.enabled = NO;
    [self.bgView addSubview:relatextField];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(SCREEN_WIDTH-50, 3, 40, 38);
    [submitButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitChange) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:submitButton];
    
    [self getStudents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectRelate
{
    if (showRelate)
    {
        [UIView animateWithDuration:0.2 animations:^{
            relateTableView.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, [relateArray count]*30);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            relateTableView.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, 0);
        }];
    }
    showRelate = !showRelate;
}

-(void)showStudents
{
    if (showStudents)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            studentsTableView.frame = CGRectMake(27, yyy+40, SCREEN_WIDTH-124, [studentsArray count]*30);
            bg2.frame = CGRectMake(27, studentsTableView.frame.size.height+studentsTableView.frame.origin.y+40, 134, 40);
            relateButton.frame = CGRectMake(bg2.frame.size.width+bg2.frame.origin.x-40, bg2.frame.origin.y, 40, 40);
            relatextField.frame = CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+30, relateButton.frame.origin.y, 90, 40);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            studentsTableView.frame = CGRectMake(27, yyy+40, SCREEN_WIDTH-124, 0);
            bg2.frame = CGRectMake(27, yyy+90, 134, 40);
            relateButton.frame = CGRectMake(bg2.frame.size.width+bg2.frame.origin.x-40, bg2.frame.origin.y, 40, 40);
            relatextField.frame = CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+30, relateButton.frame.origin.y, 90, 40);
        }];
    }
    showStudents = !showStudents;
}

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1000)
    {
        return [studentsArray count];
    }
    else if(tableView.tag == 2000)
    {
        return [relateArray count];
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000)
    {
        static NSString *studentsCell = @"studentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentsCell];
        }
        cell.textLabel.text = [[studentsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    else if(tableView.tag == 2000)
    {
        static NSString *relateCell = @"relateCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
        }
        cell.textLabel.text = [relateArray objectAtIndex:indexPath.row];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;

    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000)
    {
        studentNameLabel.text = [[studentsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        studentId = [[studentsArray objectAtIndex:indexPath.row] objectForKey:@"_id"];
        [self showStudents];
    }
    else if(tableView.tag == 2000)
    {
        if (indexPath.row == [relateArray count]-1)
        {
            relateLabel.text = nil;
            relatextField.enabled = YES;
            [relatextField becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self selectRelate];
        }
        else
        {
            relateLabel.text = [relateArray objectAtIndex:indexPath.row];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            relatextField.enabled = NO;
            relatextField.text = nil;
            [self selectRelate];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(void)getStudents
{
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"students"
                                                                      } API:GETUSERSBYCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"students mem responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] count] > 0)
                {
                    [studentsArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
                    [studentsTableView reloadData];
                }
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
        [request startAsynchronous];
    }
}

-(void)submitChange
{
    if ([Tools NetworkReachable])
    {
        if ([studentId length] <= 0)
        {
            [Tools showAlertView:@"请选择学生" delegateViewController:nil];
            return ;
        }
        if ([relateLabel.text length] == 0)
        {
            title = relatextField.text;
        }
        else if([relatextField.text length] >0)
        {
            title = relateLabel.text;
        }
        else
        {
            [Tools showAlertView:@"请确定您的孩子的关系" delegateViewController:nil];
            return ;
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":parentID,
                                                                      @"c_id":classID,
                                                                      @"title":title
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setRelate responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self unShowSelfViewController];
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

@end
