//
//  SchoolListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/14/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SchoolListViewController.h"
#import "ClassesViewController.h"
#import "CreateSchoolViewController.h"

@interface SchoolListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *createSchoolView;
}
@end

@implementation SchoolListViewController
@synthesize schoolArray,name,areaName,areaId,pr_Id,prname,schoolLevel;
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
    
    self.titleLabel.text = @"选择学校";
    
    CGFloat height = [schoolArray count]*40>(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-20-40)?(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-20-40):([schoolArray count]*40+40);
    
    UITableView *schoolListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT + 10, SCREEN_WIDTH, height) style:UITableViewStylePlain];
    schoolListTableView.delegate = self;
    schoolListTableView.dataSource = self;
    schoolListTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:schoolListTableView];
    
    createSchoolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    createSchoolView.backgroundColor = RGB(254, 249, 198, 1);
    [self.bgView addSubview:createSchoolView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.text = @"您搜索的学校不存在？";
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = RGB(254, 124, 0, 1);
    [createSchoolView addSubview:tipLabel];
    
    UIButton *createSchoolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createSchoolButton.frame = CGRectMake(SCREEN_WIDTH-10-110, 5, 100, 30);
    [createSchoolButton setTitle:@"创建新学校" forState:UIControlStateNormal];
    [createSchoolButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [createSchoolButton addTarget:self action:@selector(createSchool) forControlEvents:UIControlEventTouchUpInside];
    [createSchoolView addSubview:createSchoolButton];
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(30,UI_NAVIGATION_BAR_HEIGHT+70, SCREEN_WIDTH-60, 60)];
    tipLabel1.font = [UIFont systemFontOfSize:17];
    tipLabel1.numberOfLines = 3;
    tipLabel1.textColor = TITLE_COLOR;
    tipLabel1.textAlignment = NSTextAlignmentCenter;
    tipLabel1.backgroundColor = [UIColor clearColor];
    tipLabel1.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel1.text = @"抱歉，我们没有找到您所在的学校，如果您知道学校的确切名称，也可以直接创建学校。";
    if ([schoolArray count] <= 0)
    {
        [self.bgView addSubview:tipLabel1];
    }
    
    UIButton *createSchoolButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    createSchoolButton1.frame = CGRectMake(SCREEN_WIDTH/2-60, UI_NAVIGATION_BAR_HEIGHT+150, 120, 40);
    [createSchoolButton1 setTitle:@"创建新学校" forState:UIControlStateNormal];
    [createSchoolButton1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [createSchoolButton1 addTarget:self action:@selector(createSchool) forControlEvents:UIControlEventTouchUpInside];
    if ([schoolArray count] <= 0)
    {
        [self.bgView addSubview:createSchoolButton1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createSchool
{
    CreateSchoolViewController *createSchool = [[CreateSchoolViewController alloc] init];
    createSchool.schoolName = name;
    createSchool.areaId = areaId;
    createSchool.areaname = areaName;
    createSchool.prname = prname;
    createSchool.prID = pr_Id;
    createSchool.schoolLevel = schoolLevel;
    [self.navigationController pushViewController:createSchool animated:YES];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([schoolArray count] == 0)
    {
        createSchoolView.hidden = YES;
    }
    else
    {
        createSchoolView.hidden = NO;
    }
    return [schoolArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:18];
    headerLabel.backgroundColor = TITLE_COLOR;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = [NSString stringWithFormat:@"区域：%@     关键字：%@",areaName,name];
    return headerLabel;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *schoolLevelcell = @"schoollevelcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolLevelcell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolLevelcell];
    }
    cell.textLabel.text = [[schoolArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClassesViewController *classesViewController = [[ClassesViewController alloc] init];
    classesViewController.schoolLevel = [NSString stringWithFormat:@"%d",[[[schoolArray objectAtIndex:indexPath.row] objectForKey:@"level"] integerValue]];
    classesViewController.schoollID = [[schoolArray objectAtIndex:indexPath.row] objectForKey:@"_id"];
    classesViewController.schoolName = [[schoolArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[schoolArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"schoolname"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController pushViewController:classesViewController animated:YES];
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
