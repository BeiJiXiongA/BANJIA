//
//  ClassesViewController.m
//  School
//
//  Created by TeekerZW on 14-2-19.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassesViewController.h"
#import "Header.h"
#import "CreateClassViewController.h"
#import "ClassZoneViewController.h"

@interface ClassesViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *classTableView;
    NSMutableArray *tmpArray;
    NSDictionary *tmpDict;
    
    UILabel *tipLabel;
    UIButton *createClassButton;
    int openSection;
    
    BOOL sectionOpen;
}
@end

@implementation ClassesViewController
@synthesize schoollID,schoolName,schoolLevel;
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
    
    self.titleLabel.text = @"查找班级";
    
    openSection = 10000;
    sectionOpen = YES;
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+50, SCREEN_WIDTH, 30)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.text = [NSString stringWithFormat:@"%@还没有班级哦！",schoolName];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:tipLabel];
    
    UIImage *btnImag = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    createClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
    [createClassButton setBackgroundImage:btnImag forState:UIControlStateNormal];
    createClassButton.frame = CGRectMake(SCREEN_WIDTH/2-40, tipLabel.frame.size.height+tipLabel.frame.origin.y+40, 80, 30);
    [createClassButton addTarget:self action:@selector(createClassClick) forControlEvents:UIControlEventTouchUpInside];
    createClassButton.backgroundColor = [UIColor greenColor];
    [self.bgView addSubview:createClassButton];
    
    UIButton *createClassButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [createClassButton1 setTitle:@"创建" forState:UIControlStateNormal];
    createClassButton1.frame = CGRectMake(SCREEN_WIDTH-70, 5, 60, UI_NAVIGATION_BAR_HEIGHT-10);
    [createClassButton1 setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [createClassButton1 addTarget:self action:@selector(createClassClick) forControlEvents:UIControlEventTouchUpInside];
    createClassButton1.backgroundColor = [UIColor clearColor];
    [self.navigationBarView addSubview:createClassButton1];
    
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    [self.bgView addSubview:classTableView];

    [self getSchoolClasses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getClasses
-(void)getSchoolClasses
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"s_id":schoollID} API:CLASSESOFSCHOOL];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict1 = [responseDict objectForKey:@"data"];
                NSDictionary *dict2 = [dict1 objectForKey:@"classes"];
                NSArray *array = [dict2 allValues];
                for (int i=0; i<[array count]; ++i)
                {
                    NSDictionary *dict1 = [array objectAtIndex:i];
                    if (![self isExistInTmpArray:[dict1 objectForKey:@"enter_t"]])
                    {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSString *enterTime1 = [NSString stringWithFormat:@"%@",[dict1 objectForKey:@"enter_t"]];
                        [dict setObject:enterTime1 forKey:@"enter_t"];
                        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
                        for (int m=0; m<[array count]; ++m)
                        {
                            NSString *enterTime2 = [NSString stringWithFormat:@"%@",[[array objectAtIndex:m] objectForKey:@"enter_t"]];
                            if ([enterTime2 isEqualToString:enterTime1])
                            {
                                [array2 addObject:[array objectAtIndex:m]];
                            }
                        }
                        [dict setObject:array2 forKey:@"classes"];
                        [tmpArray addObject:dict];
                    }
                }
                [classTableView reloadData];
                
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
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(BOOL)isExistInTmpArray:(NSString *)enterTime
{
    NSString *enter_t = [NSString stringWithFormat:@"%@",enterTime];
    for (int i=0; i<[tmpArray count]; ++i)
    {
        if ([enter_t isEqualToString:[[tmpArray objectAtIndex:i] objectForKey:@"enter_t"]])
        {
            return YES;
        }
    }
    return NO;
}

-(void)createClassClick
{
    CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
    createClassViewController.schoolName = schoolName;
    createClassViewController.schoolLevel = schoolLevel;
    createClassViewController.schoollID = schoollID;
    [createClassViewController showSelfViewController:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tmpArray count]>0)
    {
        tipLabel.hidden = YES;
        createClassButton.hidden = YES;
        classTableView.hidden = NO;
        return [tmpArray count];
    }
    tipLabel.hidden = NO;
    createClassButton.hidden = NO;
    classTableView.hidden = YES;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (sectionOpen)
    {
        if (openSection == section)
        {
            NSDictionary *dict = [tmpArray objectAtIndex:section];
            return [[dict objectForKey:@"classes"] count];
        }
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [tmpArray objectAtIndex:section];
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.frame = CGRectMake(0, 5, SCREEN_WIDTH, 20);
    headerButton.backgroundColor = [UIColor lightGrayColor];
    headerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [headerButton setTitle:[NSString stringWithFormat:@"%@",[dict objectForKey:@"enter_t"]] forState:UIControlStateNormal];
    headerButton.tag = 2000+section;
    [headerButton addTarget:self action:@selector(headerBbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return headerButton;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classCell = @"classCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classCell];
    }
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:@"classes"];
    cell.textLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:@"classes"];
    ClassZoneViewController *classZoneViewController = [[ClassZoneViewController alloc] init];
    classZoneViewController.classID = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
    classZoneViewController.className = [[array objectAtIndex:indexPath.row] objectForKey:@"name"];
    classZoneViewController.schoolID = schoollID;
    classZoneViewController.schoolName = schoolName;
    classZoneViewController.fromClasses = YES;
    [classZoneViewController showSelfViewController:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)headerBbuttonClick:(UIButton *)button
{
    if (button.tag%1000 == openSection)
    {
        sectionOpen = !sectionOpen;
    }
    else
    {
        openSection = button.tag%1000;
    }
    [classTableView reloadData];
}

@end
