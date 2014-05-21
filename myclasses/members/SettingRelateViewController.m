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
    MyTextField *relatextField;
    
    CGFloat yyy;
    
    NSString *studentName;
    NSString *re_type;
    NSString *studentID;
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
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    
    showStudents = YES;
    showRelate = YES;
    
    studentName = @"";
    studentID = @"";
    
    studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    yyy = 140;
    UIImageView *bg1 = [[UIImageView alloc] initWithFrame:CGRectMake(27, yyy, SCREEN_WIDTH-124, 40)];
    [bg1 setImage:inputImage];
    [self.bgView addSubview:bg1];
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(32, yyy-30, SCREEN_WIDTH-54, 30)];
    tipLabel1.text = [NSString stringWithFormat:@"设置%@为哪位学生的家长:",parentName];
    tipLabel1.font = [UIFont systemFontOfSize:16];
    tipLabel1.textColor = [UIColor grayColor];
    tipLabel1.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel1];
    
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    studentButton.frame = bg1.frame;
    studentButton.backgroundColor = [UIColor clearColor];
//    [studentButton setImage:[UIImage imageNamed:@"icon_peo"] forState:UIControlStateNormal];
    [studentButton addTarget:self action:@selector(showStudents) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:studentButton];
    
    studentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, yyy+40, SCREEN_WIDTH-124, 0) style:UITableViewStylePlain];
    studentsTableView.delegate = self;
    studentsTableView.dataSource = self;
    studentsTableView.tag = 1000;
    studentsTableView.backgroundColor = [UIColor whiteColor];
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
    tipLabel2.font = [UIFont systemFontOfSize:16];
    tipLabel2.textColor = [UIColor grayColor];
    tipLabel2.backgroundColor = [UIColor clearColor];
    [bg2 addSubview:tipLabel2];
    
    relateArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"输入", nil];
    
    relateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, bg2.frame.size.width-40, 30)];
    relateLabel.backgroundColor = [UIColor clearColor];
    relateLabel.font = [UIFont systemFontOfSize:16];
    relateLabel.textColor = TITLE_COLOR;
    relateLabel.text = [relateArray firstObject];
    [bg2 addSubview:relateLabel];
    
    
    relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relateButton.backgroundColor = [UIColor clearColor];
    relateButton.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.origin.y, 134, bg2.frame.size.height);
    [relateButton addTarget:self action:@selector(selectRelate) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:relateButton];
    
    relateTableView = [[UITableView alloc] initWithFrame:CGRectMake(bg2.frame.origin.x, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, 0) style:UITableViewStylePlain];
    relateTableView.delegate = self;
    relateTableView.dataSource = self;
    relateTableView.tag = 2000;
    relateTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:relateTableView];
    
    relatextField = [[MyTextField alloc] initWithFrame:CGRectMake(bg2.frame.size.width+bg2.frame.origin.x+30, bg2.frame.origin.y, 90, 40)];
    relatextField.background = inputImage;
    relatextField.enabled = NO;
    relatextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    relatextField.placeholder = @"输入";
    relatextField.font = [UIFont systemFontOfSize:16];
    relatextField.hidden = YES;
    [self.bgView addSubview:relatextField];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
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

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectRelate
{
    if (showRelate)
    {
        [UIView animateWithDuration:0.2 animations:^{
            relateTableView.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, [relateArray count]*40);
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
            studentsTableView.frame = CGRectMake(27, yyy+40, SCREEN_WIDTH-124, [studentsArray count]*40);
            bg2.frame = CGRectMake(27, studentsTableView.frame.size.height+studentsTableView.frame.origin.y+40, 134, 40);
            relateButton.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.origin.y, 134, 40);
            relatextField.frame = CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+30, relateButton.frame.origin.y, 90, 40);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            studentsTableView.frame = CGRectMake(27, yyy+40, SCREEN_WIDTH-124, 0);
            bg2.frame = CGRectMake(27, yyy+90, 134, 40);
            relateButton.frame = CGRectMake(bg2.frame.origin.x, bg2.frame.origin.y, 134, 40);
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
        cell.textLabel.font = [UIFont systemFontOfSize:16];
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
        cell.textLabel.font = [UIFont systemFontOfSize:16];
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
        studentName = [[studentsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        [self showStudents];
    }
    else if(tableView.tag == 2000)
    {
        if (indexPath.row == [relateArray count]-1)
        {
            relateLabel.text = nil;
            relatextField.enabled = YES;
            relatextField.hidden = NO;
            [relatextField becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self selectRelate];
        }
        else
        {
            relateLabel.text = [relateArray objectAtIndex:indexPath.row];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            relatextField.enabled = NO;
            relatextField.hidden = YES;
            relatextField.text = nil;
            [self selectRelate];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(void)getStudents
{
    OperatDB *db = [[OperatDB alloc] init];
    [studentsArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE]];
    [studentsTableView reloadData];
}

-(void)submitChange
{
    if ([Tools NetworkReachable])
    {
        if ([studentName length] <= 0)
        {
            [Tools showAlertView:@"请选择学生" delegateViewController:nil];
            return ;
        }
        if ([relateLabel.text length] > 0)
        {
            re_type = relateLabel.text;
        }
        else if([relatextField.text length] >0)
        {
            re_type = relatextField.text;
        }
        else
        {
            [Tools showAlertView:@"请确定您的孩子的关系" delegateViewController:nil];
            return ;
        }
        title = [NSString stringWithFormat:@"%@.%@",studentName,re_type];
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":parentID,
                                                                      @"c_id":classID,
                                                                      @"title":title,
                                                                      @"role":@"parents",
                                                                      @"re_name":studentName,
                                                                      @"re_type":re_type,
                                                                      @"re_id":@""
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setRelate responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.setRelate respondsToSelector:@selector(changePareTitle:)])
                {
                    [self.setRelate changePareTitle:title];
                }
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
