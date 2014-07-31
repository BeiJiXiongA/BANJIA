//
//  ScoreTableViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/23/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ScoreTableViewController.h"
#import "ClassCell.h"
#import "ScoreDetailViewController.h"

@interface ScoreTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *gradesArray;
    UITableView *gradeTableView;
}
@end

@implementation ScoreTableViewController

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
    
    self.titleLabel.text = @"成绩簿";
    gradesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    gradeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    gradeTableView.delegate = self;
    gradeTableView.dataSource = self;
    gradeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    gradeTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:gradeTableView];
    
    [gradesArray addObjectsFromArray:[NSArray arrayWithObjects:@{@"name":@"3年级第2学期期中考",@"score":@"395",@"checked":@"0"},@{@"name":@"3年级第2学期期中考",@"score":@"395",@"checked":@"0"},@{@"name":@"3年级第2学期期中考",@"score":@"395",@"checked":@"1"}, nil]];
    
    [gradeTableView reloadData];
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

-(void)moreClick
{
    
}
#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gradesArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"gradecell";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.nameLabel.frame = CGRectMake(30, 10, 200, 30);
    
    cell.contentLable.frame = CGRectMake(12, 20, 12, 12);
    cell.contentLable.layer.cornerRadius = 6;
    cell.contentLable.clipsToBounds = YES;
    cell.contentLable.backgroundColor = RGB(201, 49, 49, 1);
    
    cell.timeLabel.frame = CGRectMake(30, 44, 150, 20);
    
    NSDictionary *dict = [gradesArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [dict objectForKey:@"name"];
    
    [cell.timeLabel cnv_setUILabelText:[NSString stringWithFormat:@"总成绩%d分",[[dict objectForKey:@"score"] integerValue]] andKeyWord:[dict objectForKey:@"score"]];
    cell.timeLabel.font = [UIFont systemFontOfSize:12];
    [cell.timeLabel cnv_setUIlabelTextColor:TIMECOLOR andKeyWordColor:RGB(51, 204, 102, 0.8)];
    
    if ([[dict objectForKey:@"checked"] integerValue] == 0)
    {
        cell.contentLable.hidden = NO;
    }
    else
    {
        cell.contentLable.hidden = YES;
    }
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [gradesArray objectAtIndex:indexPath.row];
    ScoreDetailViewController *scoreDetailViewController = [[ScoreDetailViewController alloc] init];
    scoreDetailViewController.testName = [dict objectForKey:@"name"];
    scoreDetailViewController.pubName = @"张晓伟(数学老师)";
    scoreDetailViewController.pubTime = @"2014-08-01";
    [self.navigationController pushViewController:scoreDetailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)getScoreList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
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
