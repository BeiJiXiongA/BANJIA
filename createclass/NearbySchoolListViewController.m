//
//  NearbySchoolListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/14/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "NearbySchoolListViewController.h"

@interface NearbySchoolListViewController ()<BMKMapViewDelegate,
BMKSearchDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    BMKSearch *_search;
    CLLocationManager *locationManager;
    CLLocation *nowLocation;
    
    NSMutableArray *nearbySchoolArray;
    UITableView *nearbyTableView;
    
    NSString *radius;
}
@end

@implementation NearbySchoolListViewController

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
            
        }
    }];
    if (nowLocation.coordinate.latitude > 0)
    {
        [self getNeatbySchools:radius];
    }
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
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
}

-(void)getNeatbySchools:(NSString *)radiu
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"lat":[NSString stringWithFormat:@"%f",nowLocation.coordinate.latitude],
                                                                      @"lng":[NSString stringWithFormat:@"%f",nowLocation.coordinate.longitude],
                                                                      @"radius":radiu
                                                                      } API:SEARCHNEARBYSCHOOL];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"nearby school responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [nearbySchoolArray removeAllObjects];
                [nearbySchoolArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"results"]];
                [nearbyTableView reloadData];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"附近的学校";
    
    nearbySchoolArray = [[NSMutableArray alloc] initWithCapacity:0];
    radius = @"3000";
    
    _search = [[BMKSearch alloc] init];
    _search.delegate = self;
    [self setupLocationManager];
    
    nearbyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    nearbyTableView.delegate = self;
    nearbyTableView.dataSource = self;
    [self.bgView addSubview:nearbyTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _search.delegate = nil;
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = TITLE_COLOR;
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(10, 5, 80, 30);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:18];
    headerLabel.backgroundColor = TITLE_COLOR;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = @"搜索范围";
    [headerView addSubview:headerLabel];
    
    NSArray *radiusArray = @[@"3公里",@"5公里",@"10公里"];
    for (int i = 0; i<[radiusArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(100+70*i, 5, 60, 30);
        [button setTitle:[radiusArray objectAtIndex:i] forState:UIControlStateNormal];
        button.tag = 1000+i;
        if (([radius isEqualToString:@"3000"] && i==0) || ([radius isEqualToString:@"5000"] && i==1)  || ([radius isEqualToString:@"10000"] && i==2) )
        {
            button.layer.cornerRadius = 5;
            button.clipsToBounds = YES;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        [button addTarget:self action:@selector(searchNearby:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
    }
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nearbySchoolArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classCell = @"classCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:classCell];
    }
    NSDictionary *dict = [nearbySchoolArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.textLabel.textColor = TITLE_COLOR;
    cell.detailTextLabel.text = [dict objectForKey:@"address"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = [nearbySchoolArray objectAtIndex:indexPath.row];
    DDLOG(@"detail %@",dict);
}
-(void)searchNearby:(UIButton *)button
{
        switch (button.tag) {
        case 1000:
            radius = @"3000";
            [self getNeatbySchools:@"3000"];
            break;
        case 1001:
            radius = @"5000";
            [self getNeatbySchools:@"5000"];
            break;
        case 1002:
            radius = @"10000";
            [self getNeatbySchools:@"10000"];
            break;
        default:
            break;
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
