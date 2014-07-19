//
//  DemoViewController.m
//  HtmlDemo
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "DemoViewController.h"
#define PROVINCETAG  1000
#define CITYTAG       2000
#define AREATAG      3000
#define CELLHEIGHT   40


@interface DemoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    OperatDB *db;
    
    NSMutableString *citiesString;
    
    NSMutableArray *provinceArray;
    UITableView *provinceTableView;
    BOOL provinceOpen;
    NSInteger provinceIndex;
    UILabel *provinceLabel;
    
    NSMutableArray *cityArray;
    UITableView *cityTableView;
    BOOL cityOpen;
    NSInteger cityIndex;
    UILabel *cityLabel;
    
    NSMutableArray *areaArray;
    UITableView *areaTableView;
    BOOL areaOpen;
    NSInteger areaIndex;
    UILabel *areaLabel;
}
@end

@implementation DemoViewController
@synthesize selectArea;
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
    
    self.titleLabel.text = @"选择区域";
    
    db = [[OperatDB alloc] init];
    if ([[db findSetWithDictionary:@{} andTableName:CITYTABLE] count] <= 0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"citys" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        [self dealCity:dict];
    }
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"完成" forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"navbtn"] forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [sendButton addTarget:self action:@selector(selectAreaDone) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:sendButton];
    
    
    provinceArray = [[NSMutableArray alloc] initWithCapacity:0];
    provinceOpen = NO;
    provinceIndex = 0;
    provinceTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH-20, CELLHEIGHT) style:UITableViewStylePlain];
    provinceTableView.tag = PROVINCETAG;
    provinceTableView.delegate = self;
    provinceTableView.dataSource = self;
    provinceTableView.bounces = NO;
    provinceTableView.backgroundColor = [UIColor whiteColor];
    
    cityArray = [[NSMutableArray alloc] initWithCapacity:0];
    cityOpen = NO;
    cityIndex = 0;
    cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+50, SCREEN_WIDTH-20, CELLHEIGHT) style:UITableViewStylePlain];
    cityTableView.tag = CITYTAG;
    cityTableView.bounces = NO;
    cityTableView.delegate = self;
    cityTableView.dataSource = self;
    cityTableView.backgroundColor = [UIColor whiteColor];
    
    areaArray = [[NSMutableArray alloc] initWithCapacity:0];
    areaOpen = NO;
    areaIndex = 0;
    areaTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+90, SCREEN_WIDTH-20, CELLHEIGHT) style:UITableViewStylePlain];
    areaTableView.tag = AREATAG;
    areaTableView.bounces = NO;
    areaTableView.delegate = self;
    areaTableView.dataSource = self;
    areaTableView.backgroundColor = [UIColor whiteColor];
    
    [self.bgView addSubview:areaTableView];
    [self.bgView addSubview:cityTableView];
    [self.bgView addSubview:provinceTableView];
    
    [provinceArray addObjectsFromArray:[db findSetWithDictionary:@{@"citylevel":@"1"} andTableName:CITYTABLE]];
    [provinceTableView reloadData];
    
    NSDictionary *dict = [provinceArray firstObject];
    [cityArray addObjectsFromArray:[db findSetWithDictionary:@{@"citylevel":@"2",@"pid":[dict objectForKey:@"cityid"]} andTableName:CITYTABLE]];
    [cityTableView reloadData];
    
    NSDictionary *cityDict = [cityArray firstObject];
    [self getAreasWith:[cityDict objectForKey:@"cityid"]];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == PROVINCETAG)
    {
        if (!provinceOpen)
        {
                provinceTableView.frame = CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH-20, CELLHEIGHT);
                cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, CELLHEIGHT);
            return 0;
        }
            CGFloat height = (CELLHEIGHT*[provinceArray count]>200?200:(CELLHEIGHT*[provinceArray count]+CELLHEIGHT));
            provinceTableView.frame = CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH-20, height);
            cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, CELLHEIGHT);
        return [provinceArray count];
    }
    else if(tableView.tag == CITYTAG)
    {
        if (!cityOpen)
        {
                cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, CELLHEIGHT);
            return 0;
        }
            CGFloat height = (CELLHEIGHT*[cityArray count]>200?200:(CELLHEIGHT*[cityArray count]+CELLHEIGHT));
            cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, height);
        return [cityArray count];
    }
    else if(tableView.tag == AREATAG)
    {
        if (!areaOpen)
        {
            areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, CELLHEIGHT);
            return 0;
        }
        CGFloat height = (CELLHEIGHT*[areaArray count]>200?200:(CELLHEIGHT*[areaArray count]+CELLHEIGHT));
        areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, height);
        return [areaArray count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, CELLHEIGHT)];
    headerView.backgroundColor = [UIColor whiteColor];
    if (tableView.tag == PROVINCETAG)
    {
        if ([provinceArray count] > 0)
        {
            NSDictionary *dict = [provinceArray objectAtIndex:provinceIndex];
            provinceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, CELLHEIGHT)];
            provinceLabel.backgroundColor = [UIColor whiteColor];
            provinceLabel.text = [NSString stringWithFormat:@"  %@",[dict objectForKey:@"cityname"]];
            [headerView addSubview:provinceLabel];
        }
    }
    else if (tableView.tag == CITYTAG)
    {
        if ([cityArray count] > 0)
        {
            NSDictionary *dict = [cityArray objectAtIndex:cityIndex];
            cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, CELLHEIGHT)];
            cityLabel.backgroundColor = [UIColor clearColor];
            cityLabel.text = [NSString stringWithFormat:@"  %@",[dict objectForKey:@"cityname"]];
            [headerView addSubview:cityLabel];
        }
    }
    else if(tableView.tag == AREATAG)
    {
        if ([areaArray count] > 0)
        {
            NSDictionary *dict = [areaArray objectAtIndex:areaIndex];
            areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, CELLHEIGHT)];
            areaLabel.backgroundColor = [UIColor clearColor];
            areaLabel.text = [NSString stringWithFormat:@"  %@",[dict objectForKey:@"name"]];
            [headerView addSubview:areaLabel];
        }
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, SCREEN_WIDTH-50, CELLHEIGHT);
    button.backgroundColor = [UIColor clearColor];
    button.tag = tableView.tag;
    [button addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == PROVINCETAG)
    {
        static NSString *proviceName = @"province";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:proviceName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:proviceName];
        }
        NSDictionary *dict = [provinceArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"cityname"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else if(tableView.tag == CITYTAG)
    {
        static NSString *cityName = @"city";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityName];
        }
        NSDictionary *dict = [cityArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"cityname"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else if(tableView.tag == AREATAG)
    {
        static NSString *cityName = @"area";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityName];
        }
        NSDictionary *dict = [areaArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"name"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == PROVINCETAG)
    {
        provinceIndex = indexPath.row;
        cityIndex = 0;
        [cityArray removeAllObjects];
        NSDictionary *dict = [provinceArray objectAtIndex:indexPath.row];
        [cityArray addObjectsFromArray:[db findSetWithDictionary:@{@"citylevel":@"2",@"pid":[dict objectForKey:@"cityid"]} andTableName:CITYTABLE]];
        NSDictionary *citydict = [cityArray firstObject];
        [self getAreasWith:[citydict objectForKey:@"cityid"]];
    }
    else if(tableView.tag == CITYTAG)
    {
        cityIndex = indexPath.row;
        NSDictionary *dict = [cityArray objectAtIndex:indexPath.row];
        [self getAreasWith:[dict objectForKey:@"cityid"]];
    }
    else if(tableView.tag == AREATAG)
    {
        areaIndex = indexPath.row;
    }
    provinceOpen = NO;
    cityOpen = NO;
    areaOpen = NO;
    [self updateData];
}
-(void)headerButtonClick:(UIButton *)button
{
    if (button.tag == PROVINCETAG)
    {
        provinceOpen = !provinceOpen;
        cityOpen = NO;
    }
    else if (button.tag == CITYTAG)
    {
        provinceOpen = NO;
        cityOpen = !cityOpen;
    }
    else if (button.tag == AREATAG)
    {
        areaOpen = !areaOpen;
        
    }
    [self updateData];
}

-(void)updateData
{
    [provinceTableView reloadData];
    [cityTableView reloadData];
    [areaTableView reloadData];
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
                [areaArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
                areaIndex = 0;
                [areaTableView reloadData];
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

-(void)selectAreaDone
{
    if ([self.selectArea respondsToSelector:@selector(updateAreaWithId:areaName:)])
    {
        [self.selectArea updateAreaWithId:[[areaArray objectAtIndex:areaIndex] objectForKey:@"_id"] areaName:[[areaArray objectAtIndex:areaIndex] objectForKey:@"name"]];
    }
    [self unShowSelfViewController];
}

-(void)dealCity:(NSDictionary *)dict
{
    NSArray *array = [dict allValues];
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict = [array objectAtIndex:i];
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [tmpDict setObject:[dict objectForKey:@"_id"] forKey:@"cityid"];
        [tmpDict setObject:[dict objectForKey:@"name"] forKey:@"cityname"];
        [tmpDict setObject:[dict objectForKey:@"level"] forKey:@"citylevel"];
        [tmpDict setObject:[dict objectForKey:@"p_id"] forKey:@"pid"];
        if ([db insertRecord:tmpDict  andTableName:CITYTABLE])
        {
            DDLOG(@"insert city success!");
        }
    }
}
@end
