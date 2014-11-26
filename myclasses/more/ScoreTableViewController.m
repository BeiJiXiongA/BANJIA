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
#import "EGORefreshTableHeaderView.h"
#import "FooterView.h"
#import "ScoreMemListViewController.h"

@interface ScoreTableViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
EGORefreshTableDelegate>
{
    NSMutableArray *gradesArray;
    UITableView *gradeTableView;
    int page;
    
    NSString *classid;
    
    EGORefreshTableHeaderView *pullRefreshView;
    FooterView *footerView;
    BOOL _reloading;
    
    NSString *role;
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
    page = 0;
    classid = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    role = [[NSUserDefaults standardUserDefaults] objectForKey:@"role"];
    
//    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
//    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
//    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:moreButton];
    
    gradeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    gradeTableView.delegate = self;
    gradeTableView.dataSource = self;
    gradeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    gradeTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:gradeTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:gradeTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    [self getScoreList];
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

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = 0;
    [self getScoreList];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self getScoreList];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullRefreshView egoRefreshScrollViewDidScroll:gradeTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:gradeTableView];
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:gradeTableView];
    [footerView egoRefreshScrollViewDidEndDragging:gradeTableView];
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
    cell.nameLabel.frame = CGRectMake(20, 10, 200, 30);
    
    cell.contentLable.frame = CGRectMake(12, 20, 12, 12);
    cell.contentLable.layer.cornerRadius = 6;
    cell.contentLable.clipsToBounds = YES;
    cell.contentLable.backgroundColor = RGB(201, 49, 49, 1);
    cell.contentLable.hidden = YES;
    cell.timeLabel.frame = CGRectMake(20, 44, 150, 20);
    
    NSDictionary *dict = [gradesArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [dict objectForKey:@"name"];
    
    
    if ([role isEqualToString:@"teachers"])
    {
        [cell.timeLabel cnv_setUILabelText:[NSString stringWithFormat:@"共有%ld人参加考试",(long)[[dict objectForKey:@"members_num"] integerValue]] andKeyWord:[NSString stringWithFormat:@"%ld",(long)[[dict objectForKey:@"members_num"] integerValue]]];
    }
    else
    {
        
        [cell.timeLabel cnv_setUILabelText:[NSString stringWithFormat:@"总成绩%ld分",(long)[[dict objectForKey:@"total"] integerValue]] andKeyWord:[NSString stringWithFormat:@"%ld",(long)[[dict objectForKey:@"total"] integerValue]]];
    }
    cell.timeLabel.font = [UIFont systemFontOfSize:12];
    [cell.timeLabel cnv_setUIlabelTextColor:TIMECOLOR andKeyWordColor:RGB(51, 204, 102, 0.8)];
    
    cell.arrowImageView.hidden = NO;
    [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 27.5, 10, 15)];
    [cell.arrowImageView setImage:[UIImage imageNamed:@"discovery_arrow"]];
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [gradesArray objectAtIndex:indexPath.row];
    if ([role isEqualToString:@"teachers"])
    {
        ScoreMemListViewController *memlist = [[ScoreMemListViewController alloc] init];
        memlist.scoreid = [dict objectForKey:@"_id"];
        [self.navigationController pushViewController:memlist animated:YES];
    }
    else
    {
        ScoreDetailViewController *scoreDetailViewController = [[ScoreDetailViewController alloc] init];
        scoreDetailViewController.scoreId = [dict objectForKey:@"_id"];
        scoreDetailViewController.testName = [dict objectForKey:@"name"];
        
        [self.navigationController pushViewController:scoreDetailViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)getScoreList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classid,
                                                                      @"page":[NSString stringWithFormat:@"%d",page],
                                                                      @"role":[[NSUserDefaults standardUserDefaults] objectForKey:@"role"]
                                                                      } API:SCORELIST];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"score list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                if (page == 0)
                {
                    [gradesArray removeAllObjects];
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETNOTIFICATIONS,[Tools user_id],classid];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                }
                [gradesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"exams"]];
                
                [gradeTableView reloadData];
                if (footerView)
                {
                    [footerView removeFromSuperview];
                    footerView = [[FooterView alloc] initWithScrollView:gradeTableView];
                    footerView.delegate = self;
                }
                else
                {
                    footerView = [[FooterView alloc] initWithScrollView:gradeTableView];
                    footerView.delegate = self;
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:gradeTableView];
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:gradeTableView];
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
