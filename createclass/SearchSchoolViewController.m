//
//  SearchSchoolViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/13/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SearchSchoolViewController.h"
#import "TrendsCell.h"
#import <CoreLocation/CoreLocation.h>
//#import "DemoViewController.h"
#import "SelectSchoolLevelViewController.h"
#import "SchoolListViewController.h"
#import "SelectCityViewController.h"
#import "AreasViewController.h"

@interface SearchSchoolViewController ()<
UITableViewDataSource,
UITableViewDelegate,
//SelectArea,
SelectSchoolLevelDel,
UITextFieldDelegate,
SelectCitydelegate,
SelectAreaDelegate,
CLLocationManagerDelegate>
{
    NSArray *cellNameArray;
    
    NSString *cityname;
    NSString *cityId;
    
    NSString *areaname;
    NSString *areaId;
    NSMutableArray *areaArray;
    
    NSString *schoollevelName;
    NSString *schoollevelId;
    
    UITableView *searchSchoolTableView;
    
    NSDictionary *tmpDityDict;
    
    OperatDB *db;
    
    //位置
    CLLocationManager *locationManager;
    CLLocation *nowLocation;
    UIButton *locationButton;
    BOOL locationEditing;
    UIView *locationBgView;
    MyTextField *locationTextView;
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    BOOL enableLocation;
    
}
@end

@implementation SearchSchoolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - location

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    nowLocation = newLocation;
    //do something else
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array,NSError *error){
        if ([array count]>0) {
            CLPlacemark * placemark = [array objectAtIndex:0];
            NSDictionary *addDict = placemark.addressDictionary;
            NSString *tmpCityName = [addDict objectForKey:@"State"];
            NSRange range = [tmpCityName rangeOfString:@"市"];
            if (range.length > 0)
            {
                cityname = [tmpCityName substringToIndex:range.location];
            }
            else
            {
                cityname = tmpCityName;
            }
            NSArray *cityArray = [db findSetWithDictionary:@{@"cityname":cityname,@"citylevel":@"2"} andTableName:CITYTABLE];
            if ([cityArray count] > 0)
            {
                for (NSDictionary *dict in cityArray)
                {
                    cityId = [dict objectForKey:@"cityid"];
                    if ([cityname length] > 0 && [cityId length] > 0)
                    {
                        [self getAreasWith:cityId];
                    }
                    break ;
                }
            }
            
            
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    DDLOG(@"Error:%@",[error localizedDescription]);
    switch ([error code])
    {
        case kCLErrorDenied:
            errorString = @"定位服务被禁止，请到设置->隐私->定位服务里打开这个应用的定位服务";
            break;
        case kCLErrorLocationUnknown:
            errorString = @"定位信息不可用";
        default:
            errorString = @"位置错误";
            break;
    }
    [Tools showAlertView:errorString delegateViewController:nil];
}

- (void) setupLocationManager {
    if (![Tools NetworkReachable])
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
        return ;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    if (SYSVERSION >= 8)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    db = [[OperatDB alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.titleLabel.text = @"搜索学校";
    cityname = @"请选择城市";
    schoollevelName = @"请选择学校类别";
    
    areaname = @"全部";
    areaId = @"";
    
    schoollevelName = @"全部";
    schoollevelId = @"-1";
    
    [self setupLocationManager];
    
    cellNameArray = [[NSArray alloc] initWithObjects:@"城市",@"地区",@"学校类别",@"学校名称", nil];
    areaArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    searchSchoolTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 280) style:UITableViewStylePlain];
    searchSchoolTableView.delegate = self;
    searchSchoolTableView.dataSource = self;
    searchSchoolTableView.bounces = NO;
    searchSchoolTableView.layer.cornerRadius = 5;
    searchSchoolTableView.clipsToBounds = YES;
    searchSchoolTableView.scrollEnabled = NO;
    searchSchoolTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:searchSchoolTableView];
    if ([searchSchoolTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchSchoolTableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
//获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;

    [UIView animateWithDuration:0.25 animations:^{
        if (FOURS)
        {
            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+150);
        }
    }completion:^(BOOL finished) {
    }];
}


-(void)updateAreaWithId:(NSString *)areaID areaName:(NSString *)areaName
{
    areaId = areaID;
    areaname = areaName;
    [searchSchoolTableView reloadData];
}

-(void)updateSchoolLevelWith:(NSString *)schoolLevelName andId:(NSString *)schoolId
{
    schoollevelName = schoolLevelName;
    schoollevelId = schoolId;
    [searchSchoolTableView reloadData];
}

-(void)selectCityWithDict:(NSDictionary *)cityDict
{
    [areaArray removeAllObjects];
    tmpDityDict  = cityDict;
    [searchSchoolTableView reloadData];
    [self getAreasWith:[cityDict objectForKey:@"cityid"]];
}
-(void)selectAreaWithDict:(NSDictionary *)dict
{
    areaId = [dict objectForKey:@"_id"];
    areaname = [dict objectForKey:@"name"];
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
                    areaname = @"全部";
                    areaId = @"";
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
    if ([areaArray count] > 0)
    {
        searchSchoolTableView.frame = CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 280-60);
    }
    else
    {
        searchSchoolTableView.frame = CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 240-60);
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
    if (indexPath.section == 2)
    {
        return 40;
    }
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if ([areaArray count] > 0)
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
    
    cell.contentLabel.textColor = TITLE_COLOR;
    
    if(indexPath.section == 0)
    {
        cell.nameLabel.frame  = CGRectMake(10, 5, 80, 30);
        cell.nameLabel.hidden = NO;
        cell.nameLabel.textColor = CONTENTCOLOR;
        cell.nameLabel.text = [cellNameArray objectAtIndex:indexPath.row];
        
        cell.contentLabel.frame = CGRectMake(110, 0, 200, 40);
        cell.contentLabel.hidden = NO;
        cell.contentLabel.textColor = CONTENTCOLOR;
        cell.contentLabel.font = [UIFont systemFontOfSize:18];
        if (indexPath.row == 0)
        {
            if ([tmpDityDict count] > 0)
            {
                cityname = [tmpDityDict objectForKey:@"cityname"];
                cityId = [tmpDityDict objectForKey:@"cityid"];
            }
            cell.contentLabel.text = cityname;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.contentLabel.text = schoollevelName;
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
            cell.nameTextField.placeholder = @"请输入关键字";
            cell.nameTextField.tag = 3333;
            cell.nameTextField.delegate = self;
            cell.nameTextField.textColor = CONTENTCOLOR;
            cell.nameTextField.returnKeyType = UIReturnKeyDone;
            cell.contentLabel.frame = CGRectMake(0, 0, 0, 0);
        }
        else if(indexPath.row == 1)
        {
            if ([areaArray count] > 0)
            {
                cell.nameLabel.text = [cellNameArray objectAtIndex:indexPath.row];
                cell.contentLabel.text = areaname;
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
            [cell.praiseButton setTitle:@"搜索" forState:UIControlStateNormal];
            [cell.praiseButton addTarget:self action:@selector(searchSchool) forControlEvents:UIControlEventTouchUpInside];
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
            [self.navigationController pushViewController:areaViewController animated:YES];
        }
        else if(indexPath.row == 2)
        {
            SelectSchoolLevelViewController *selectSchoolLevel = [[SelectSchoolLevelViewController alloc] init];
            selectSchoolLevel.selectSchoolLevelDel = self;
            selectSchoolLevel.fromCreate = NO;
            [self.navigationController pushViewController:selectSchoolLevel animated:YES];
        }
    }
//    else if(indexPath.section == 0)
//    {
//        if (indexPath.row == 0)
//        {
//            //附近的学校
//        }
//    }
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

-(void)searchSchool
{
    [((MyTextField *)[searchSchoolTableView viewWithTag:3333]) resignFirstResponder];
    
    if (!cityId || [cityId length] == 0)
    {
        [Tools showAlertView:@"请选择城市" delegateViewController:nil];
        return ;
    }
    
    if ([schoollevelId length] <= 0)
    {
        [Tools showAlertView:@"请选择学校类别" delegateViewController:nil];
        return ;
    }
    
    NSString *name = ((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text;
    if ([name length] <= 0)
    {
        [Tools showAlertView:@"请输入搜索关键字" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"r_id":areaId,
                                                                      @"level":schoollevelId,
                                                                      @"name":name,
                                                                      @"pr_id":cityId
                                                                      } API:SEARCHSCHOOLBYCITY];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchschool responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                SchoolListViewController *schoolListViewController = [[SchoolListViewController alloc] init];
                
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    schoolListViewController.schoolArray = [[responseDict objectForKey:@"data"] allValues];
                }
                schoolListViewController.areaId = areaId;
                schoolListViewController.pr_Id = cityId;
                schoolListViewController.name = name;
                schoolListViewController.prname = cityname;
                schoolListViewController.areaName = areaname;
                schoolListViewController.schoolLevel = schoollevelId;
                [self.navigationController pushViewController:schoolListViewController animated:YES];
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

-(void)searchSchoolByBaidu
{
    [((MyTextField *)[searchSchoolTableView viewWithTag:3333]) resignFirstResponder];
    
    NSString *name = ((MyTextField *)[searchSchoolTableView viewWithTag:3333]).text;
    if ([name length] <= 0)
    {
        [Tools showAlertView:@"请输入搜索关键字" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        if ([cityname isEqualToString:@"请选择地区"])
        {
            cityname = @"全国";
        }
        NSString *searchContent = [areaname isEqualToString:@"全部"]?name:[NSString stringWithFormat:@"%@$%@",name,areaname];
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"region":cityname,
                                                                      @"name":searchContent
                                                                      } API:SEARCHSCHOOLBYBAIDU];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchschool responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                SchoolListViewController *schoolListViewController = [[SchoolListViewController alloc] init];
                schoolListViewController.schoolArray = [responseDict objectForKey:@"data"];
                schoolListViewController.name = name;
                schoolListViewController.areaName = cityname;
                [self.navigationController pushViewController:schoolListViewController animated:YES];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [((MyTextField *)[searchSchoolTableView viewWithTag:3333]) resignFirstResponder];
    return YES;
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
