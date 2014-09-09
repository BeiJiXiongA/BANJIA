//
//  CreateSchoolViewController.m
//  BANJIA
//
//  Created by TeekerZW on 4/8/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "CreateSchoolViewController.h"
#import "Header.h"
#import "CreateClassViewController.h"
#import "SelectCityViewController.h"
#import "AreasViewController.h"
#import "TrendsCell.h"
#import "SelectSchoolLevelViewController.h"
#import "SchoolInfoViewController.h"
@interface CreateSchoolViewController ()<
UITableViewDataSource,
UITableViewDelegate,
SelectCitydelegate,
SelectAreaDelegate,
SelectSchoolLevelDel,
UITextFieldDelegate>
{
    MyTextField *schoolNameTextField;
    NSArray *schoolLevelArray;
    NSArray *valueArray;
    
    UITableView *levelTableView;
    UIButton *openLevelButton;
    
    NSString *levelStr;
    NSString *levelValue;
    
    BOOL levelOpen;
    UIButton *createClassButton;
    
    NSMutableArray *areaArray;
    
    UITableView *searchSchoolTableView;
    NSArray *cellNameArray;
    
    BOOL firstGetArea;
}
@end

@implementation CreateSchoolViewController
@synthesize schoolName,classID,areaId,prID,areaname,schoolLevel;
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
    self.titleLabel.text = @"创建学校";
    
    areaArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    cellNameArray = [[NSArray alloc] initWithObjects:@"城市",@"地区",@"学校类别",@"学校名称", nil];
    
    schoolLevelArray = SCHOOLLEVELARRAY;
    valueArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6", nil];
    if ([schoolLevel integerValue] >=0)
    {
        levelStr = [schoolLevelArray objectAtIndex:[schoolLevel integerValue]];
        levelValue = schoolLevel;
    }
    else
    {
        levelStr = @"学校类别";
        levelValue = @"";
    }
    levelOpen = YES;
    firstGetArea = YES;
    
    if ([areaId length] <= 0)
    {
        self.areaname = @"选择区域";
    }
    
    searchSchoolTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 220) style:UITableViewStylePlain];
    searchSchoolTableView.delegate = self;
    searchSchoolTableView.dataSource = self;
    searchSchoolTableView.bounces = NO;
    searchSchoolTableView.scrollEnabled = NO;
    searchSchoolTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:searchSchoolTableView];
    
    if ([searchSchoolTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchSchoolTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([prID length] > 0)
    {
        [self getAreasWith:prID];
    }
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

#pragma mark - aboutregions
-(void)selectCity
{
    SelectCityViewController *selectCityViewController = [[SelectCityViewController alloc] init];
    selectCityViewController.selectCityDel = self;
    [self.navigationController pushViewController:selectCityViewController animated:YES];
}
-(void)selectRegion
{
    AreasViewController *areaViewController = [[AreasViewController alloc] init];
    areaViewController.areaArray = areaArray;
    areaViewController.selectAreaDel = self;
    [self.navigationController pushViewController:areaViewController animated:YES];
}

-(void)updateAreaWithId:(NSString *)areaID areaName:(NSString *)areaName
{
    areaId = areaID;
    self.areaname = areaName;
    [searchSchoolTableView reloadData];
}

-(void)updateSchoolLevelWith:(NSString *)schoolLevelName andId:(NSString *)schoolId
{
    levelValue = schoolId;
    levelStr = schoolLevelName;
    [searchSchoolTableView reloadData];
}
-(void)selectCityWithDict:(NSDictionary *)cityDict
{
    [areaArray removeAllObjects];
    self.prname = [cityDict objectForKey:@"cityname"];
    self.prID = [cityDict objectForKey:@"cityid"];
    [self getAreasWith:[cityDict objectForKey:@"cityid"]];
}

-(void)selectAreaWithDict:(NSDictionary *)dict
{
    areaId = [dict objectForKey:@"_id"];
    self.areaname = [dict objectForKey:@"name"];
    [searchSchoolTableView reloadData];
}

-(void)getAreasWith:(NSString *)cityid
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"r_id":cityid
                                                                      } API:CITYLIST];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"citylist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [areaArray removeAllObjects];
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    [areaArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
                    
                    if (firstGetArea)
                    {
                        firstGetArea = NO;
                        if ([areaId length] <= 0)
                        {
                            self.areaname = @"选择区域";
                            self.areaId = @"";
                        }
                    }
                    else
                    {
                        self.areaname = @"选择区域";
                        self.areaId = @"";
                    }
                    [searchSchoolTableView reloadData];
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



-(void)openlevel
{
    if (levelOpen)
    {
        [UIView animateWithDuration:0.2 animations:^{
            levelTableView.frame = CGRectMake(openLevelButton.frame.origin.x, openLevelButton.frame.size.height+openLevelButton.frame.origin.y, 100, [schoolLevelArray count]*40);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            levelTableView.frame = CGRectMake(openLevelButton.frame.origin.x, openLevelButton.frame.size.height+openLevelButton.frame.origin.y, 100, 0);
        }];
    }
    levelOpen = !levelOpen;
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 1;
    }
    if ([areaArray count] > 0 || [areaId length] > 5)
    {
        searchSchoolTableView.frame = CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 220);
    }
    else
    {
        searchSchoolTableView.frame = CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 180);
    }
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 20;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 10)];
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 40;
    }
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if ([areaArray count] > 0 || [areaId length] > 5)
        {
            return 40;
        }
        return 0;
    }
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"searchSchoolCell";
    TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil)
    {
        cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    cell.praiseButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cell.praiseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.praiseButton.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 40);
    cell.praiseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.contentLabel.textColor = CONTENTCOLOR;
    
    if(indexPath.section == 0)
    {
        cell.nameLabel.frame  = CGRectMake(10, 5, 80, 30);
        cell.nameLabel.hidden = NO;
        cell.nameLabel.text = [cellNameArray objectAtIndex:indexPath.row];
        
        cell.contentLabel.frame = CGRectMake(110, 0, 200, 40);
        cell.contentLabel.hidden = NO;
        cell.contentLabel.font = [UIFont systemFontOfSize:18];
        if (indexPath.row == 0)
        {
            cell.contentLabel.text = self.prname;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.contentLabel.text = levelStr;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 3)
        {
            cell.bgView.frame = CGRectMake(0, 0, 80, 40);
            cell.bgView.layer.borderWidth = 0;
            cell.nameTextField.frame = CGRectMake(90, 5, 180, 30);
            cell.nameTextField.hidden = NO;
            cell.nameTextField.background = nil;
            cell.nameTextField.backgroundColor = [UIColor whiteColor];
            cell.nameTextField.placeholder = @"请输入学校名称";
            cell.nameTextField.tag = 3333;
            cell.nameTextField.delegate = self;
            cell.nameTextField.textColor = CONTENTCOLOR;
            cell.nameTextField.returnKeyType = UIReturnKeyDone;
            cell.contentLabel.frame = CGRectMake(0, 0, 0, 0);
            cell.nameTextField.text = schoolName;
        }
        else if(indexPath.row == 1)
        {
            if ([areaArray count] > 0  || [areaId length] > 5)
            {
                cell.nameLabel.text = [cellNameArray objectAtIndex:indexPath.row];
                cell.contentLabel.text = self.areaname;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.nameLabel.hidden = YES;
                cell.praiseButton.hidden = YES;
                cell.nameTextField.hidden = YES;
                cell.contentLabel.hidden = YES;
            }
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.praiseButton.hidden = NO;
            [cell.praiseButton setTitle:@"创建" forState:UIControlStateNormal];
            [cell.praiseButton addTarget:self action:@selector(createClassClick) forControlEvents:UIControlEventTouchUpInside];
            [cell.praiseButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
            cell.bgView.frame = cell.praiseButton.frame;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((MyTextField *)[searchSchoolTableView viewWithTag:3333]) resignFirstResponder];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            SelectCityViewController *selectCityViewController = [[SelectCityViewController alloc] init];
            selectCityViewController.selectCityDel = self;
            [self.navigationController pushViewController:selectCityViewController animated:YES];
        }
        else if (indexPath.row == 1)
        {
            AreasViewController *areaViewController = [[AreasViewController alloc] init];
            areaViewController.areaArray = areaArray;
            areaViewController.selectAreaDel = self;
            areaViewController.fromCreate = YES;
            [self.navigationController pushViewController:areaViewController animated:YES];
        }
        else if(indexPath.row == 2)
        {
            SelectSchoolLevelViewController *selectSchoolLevel = [[SelectSchoolLevelViewController alloc] init];
            selectSchoolLevel.selectSchoolLevelDel = self;
            selectSchoolLevel.fromCreate = YES;
            [self.navigationController pushViewController:selectSchoolLevel animated:YES];
        }
    }
    else if(indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            //附近的学校
        }
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            //搜索学校
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    schoolName = textField.text;
}

-(void)createClassClick
{
    if ([areaId length] <= 0)
    {
        [Tools showAlertView:@"去选择学校区域" delegateViewController:nil];
        return;
    }
    if ([levelValue isEqualToString:@""])
    {
        [Tools showAlertView:@"请选择学校类型" delegateViewController:nil];
        return ;
    }
    if ([((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text length] < 4 )
    {
        [Tools showAlertView:@"学校名称应该多于4个字符哦" delegateViewController:nil];
        return;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"name":((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text,
                                                                      @"level":levelValue,
//                                                                      @"pr_id":self.prID,
                                                                      @"r_id":areaId} API:CREATESCHOOL];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                if([[[NSUserDefaults standardUserDefaults] objectForKey:SEARCHSCHOOLTYPE] isEqualToString:BINDCLASSTOSCHOOL])
                {
                    SchoolInfoViewController *schoolInfo = [[SchoolInfoViewController alloc] init];
                    schoolInfo.schoolid = [responseDict objectForKey:@"data"];
                    schoolInfo.schoolName = ((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text;
                    [self.navigationController pushViewController:schoolInfo animated:YES];
                }
                else
                {
                    NSString *schoolID = [responseDict objectForKey:@"data"];
                    CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
                    createClassViewController.schoolName = ((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text;
                    createClassViewController.schoolLevel = levelValue;
                    createClassViewController.schoollID = schoolID;
                    [self.navigationController pushViewController:createClassViewController animated:YES];
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
