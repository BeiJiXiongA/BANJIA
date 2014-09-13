//
//  SettingRelateViewController.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SettingRelateViewController.h"

#define StudentsTableViewTag 1000
#define RelateTableViewTag  2000

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
    NSString *re_id;
    
    UIButton *studentButton;
    
    UIImageView *arrowImageView;
    UIImageView *arrowImageView2;
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
    
    OperatDB *db = [[OperatDB alloc] init];
    NSDictionary *parentDict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":parentID} andTableName:CLASSMEMBERTABLE] firstObject];
    studentName = [parentDict objectForKey:@"re_name"];
    re_id = @"";
    
    studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(32, UI_NAVIGATION_BAR_HEIGHT + 30, SCREEN_WIDTH-54, 30)];
    tipLabel1.text = [NSString stringWithFormat:@"设置%@为哪位学生的家长:",parentName];
    tipLabel1.font = [UIFont systemFontOfSize:18];
    tipLabel1.textColor = COMMENTCOLOR;
    tipLabel1.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel1];
    
    studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    studentButton.frame = CGRectMake(tipLabel1.frame.origin.x, tipLabel1.frame.size.height+tipLabel1.frame.origin.y+10, SCREEN_WIDTH-62, 42);
    studentButton.backgroundColor = [UIColor whiteColor];
    studentButton.layer.cornerRadius = 5;
    studentButton.clipsToBounds = YES;
    [studentButton setTitle:@"请选择" forState:UIControlStateNormal];
    studentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [studentButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [studentButton addTarget:self action:@selector(showStudents) forControlEvents:UIControlEventTouchUpInside];
    [studentButton setTitle:[NSString stringWithFormat:@"   %@",studentName] forState:UIControlStateNormal];
    [self.bgView addSubview:studentButton];
    
    arrowImageView = [[UIImageView alloc] init];
    arrowImageView.frame = CGRectMake(studentButton.frame.size.width+studentButton.frame.origin.x-30, studentButton.frame.origin.y+studentButton.frame.size.height/2-5, 15, 10);
    [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    [self.bgView addSubview:arrowImageView];
    
    studentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(studentButton.frame.origin.x, studentButton.frame.size.height+studentButton.frame.origin.y, studentButton.frame.size.width, 0) style:UITableViewStylePlain];
    studentsTableView.delegate = self;
    studentsTableView.dataSource = self;
    studentsTableView.tag = StudentsTableViewTag;
    studentsTableView.layer.cornerRadius = 5;
    studentsTableView.clipsToBounds = YES;
    studentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    studentsTableView.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(tipLabel1.frame.origin.x, studentButton.frame.size.height+studentButton.frame.origin.y+10, SCREEN_WIDTH-64, 30)];
    tipLabel2.text = [NSString stringWithFormat:@"设置%@与学生的关系为:",parentName];
    tipLabel2.font = [UIFont systemFontOfSize:18];
    tipLabel2.textColor = COMMENTCOLOR;
    tipLabel2.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:tipLabel2];
    
    relateArray = RELATEARRAY;
    
    relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relateButton.backgroundColor = [UIColor whiteColor];
    relateButton.layer.cornerRadius = 5;
    [relateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    relateButton.clipsToBounds = YES;
    [relateButton setTitle:[NSString stringWithFormat:@"   %@",[title substringFromIndex:[title rangeOfString:@"."].location+1]] forState:UIControlStateNormal];
    
    re_type = [title substringFromIndex:[title rangeOfString:@"."].location+1];
    relateButton.frame = CGRectMake(studentButton.frame.origin.x, tipLabel2.frame.origin.y+tipLabel2.frame.size.height, 134, studentButton.frame.size.height);
    [relateButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [relateButton addTarget:self action:@selector(selectRelate) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:relateButton];
    
    arrowImageView2 = [[UIImageView alloc] init];
    arrowImageView2.frame = CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x-30, relateButton.frame.origin.y+relateButton.frame.size.height/2-5, 15, 10);
    [arrowImageView2 setImage:[UIImage imageNamed:@"arrow_down"]];
    [self.bgView addSubview:arrowImageView2];
    
    relateTableView = [[UITableView alloc] initWithFrame:CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0) style:UITableViewStylePlain];
    relateTableView.delegate = self;
    relateTableView.dataSource = self;
    relateTableView.tag = RelateTableViewTag;
    relateTableView.layer.cornerRadius = 5;
    relateTableView.clipsToBounds = YES;
    relateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    relateTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:relateTableView];
    
    relatextField = [[MyTextField alloc] initWithFrame:CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+20, relateButton.frame.origin.y, 90, 40)];
    relatextField.background = nil;
    relatextField.enabled = NO;
    relatextField.backgroundColor = [UIColor whiteColor];
    relatextField.layer.cornerRadius = 5;
    relatextField.clipsToBounds = YES;
    relatextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    relatextField.placeholder = @"输入";
    relatextField.font = [UIFont systemFontOfSize:16];
    relatextField.hidden = YES;
    [self.bgView addSubview:relatextField];
    
    [self.bgView addSubview:studentsTableView];
    
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [submitButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
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
            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, [relateArray count]*40);
            [arrowImageView2 setImage:[UIImage imageNamed:@"arrow_up"]];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0);
            [arrowImageView2 setImage:[UIImage imageNamed:@"arrow_down"]];
        }];
    }
    showRelate = !showRelate;
}

-(void)showStudents
{
    if (showStudents)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat maxH = [studentsArray count]*40>(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-150)?(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-150):([studentsArray count] * 40);
            studentsTableView.frame = CGRectMake(studentButton.frame.origin.x, studentButton.frame.size.height+studentButton.frame.origin.y, studentButton.frame.size.width, maxH);
            [arrowImageView setImage:[UIImage imageNamed:@"arrow_up"]];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            studentsTableView.frame = CGRectMake(studentButton.frame.origin.x, studentButton.frame.size.height+studentButton.frame.origin.y, studentButton.frame.size.width, 0);
            [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
        }];
    }
    showStudents = !showStudents;
}

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == StudentsTableViewTag)
    {
        return [studentsArray count];
    }
    else if(tableView.tag == RelateTableViewTag)
    {
        return [relateArray count];
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == StudentsTableViewTag)
    {
        static NSString *studentsCell = @"studentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentsCell];
        }
        NSDictionary *dict = [studentsArray objectAtIndex:indexPath.row];
        if ([dict objectForKey:@"sn"] &&
            ![[dict objectForKey:@"sn"] isEqual:[NSNull null]] &&
            [[dict objectForKey:@"sn"] length] > 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",[dict objectForKey:@"name"],[dict objectForKey:@"sn"]];
        }
        else
        {
            cell.textLabel.text = [dict objectForKey:@"name"];
        }
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        if (indexPath.row < [studentsArray count]-1)
        {
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    }
    else if(tableView.tag == RelateTableViewTag)
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
        if (indexPath.row < [relateArray count]-1)
        {
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }

        return cell;

    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == StudentsTableViewTag)
    {
        NSDictionary *dict = [studentsArray objectAtIndex:indexPath.row];
        re_id = [dict objectForKey:@"uid"];
        studentName = [[studentsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        [studentButton setTitle:[NSString stringWithFormat:@"   %@",studentName] forState:UIControlStateNormal];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showStudents];
    }
    else if(tableView.tag == RelateTableViewTag)
    {
        if (indexPath.row == [relateArray count]-1)
        {
            re_type = [relateArray objectAtIndex:indexPath.row];
            [relateButton setTitle:[NSString stringWithFormat:@"  %@",re_type] forState:UIControlStateNormal];
            relatextField.enabled = YES;
            relatextField.hidden = NO;
            [relatextField becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self selectRelate];
        }
        else
        {
            re_type = [relateArray objectAtIndex:indexPath.row];
            [relateButton setTitle:[NSString stringWithFormat:@"  %@",re_type] forState:UIControlStateNormal];
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
    [studentsArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"role":@"students",@"checked":@"1"} andTableName:CLASSMEMBERTABLE]];
    [studentsArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"role":@"unin_students",@"checked":@"1"} andTableName:CLASSMEMBERTABLE]];
    [studentsTableView reloadData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
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
        if([relatextField.text length] > 0)
        {
            re_type = relatextField.text;
        }
        else if(![re_type isEqualToString:@"其他"])
        {
            ;
        }
        else
        {
            [Tools showAlertView:@"请确定您的孩子的关系" delegateViewController:nil];
            return ;
        }
        if ([re_id length] == 0)
        {
            [Tools showAlertView:@"请选择新的学生" delegateViewController:nil];
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
                                                                      @"re_id":re_id
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setRelate responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                OperatDB *db = [[OperatDB alloc] init];
                
                if ([db updeteKey:@"re_name" toValue:studentName withParaDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"update update success");
                }
                if ([db updeteKey:@"re_type" toValue:re_type withParaDict:@{@"uid":parentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"update re_type success");
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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
@end
