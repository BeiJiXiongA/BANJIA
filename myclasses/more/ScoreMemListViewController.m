//
//  ScoreMemListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 8/8/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ScoreMemListViewController.h"
#import "ClassCell.h"
#import "ScoreDetailViewController.h"

@interface ScoreMemListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *memListTableView;
    NSString *pubTime;
    NSString *pubName;
    NSString *testName;
}
@end

@implementation ScoreMemListViewController
@synthesize memListArray,scoreid;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        memListArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"考试成员";
    
    memListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT,SCREEN_WIDTH,SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    memListTableView.delegate = self;
    memListTableView.dataSource = self;
    memListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:memListTableView];
    
    [self getScoreDetail];
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

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [memListArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"gradecell";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.nameLabel.frame = CGRectMake(20, 5, 200, 20);
    cell.nameLabel.font = [UIFont systemFontOfSize:16];
    cell.timeLabel.frame = CGRectMake(20, 25, 180, 20);

    cell.contentLable.frame = CGRectMake(12, 7, 12, 12);
    cell.contentLable.layer.cornerRadius = 6;
    cell.contentLable.clipsToBounds = YES;
    cell.contentLable.backgroundColor = RGB(201, 49, 49, 1);
    cell.contentLable.hidden = YES;
    
    NSDictionary *dict = [memListArray objectAtIndex:indexPath.row];
    NSString *name = @"";
    NSString *stunum = @"";
    NSRange range = [[dict objectForKey:@"index"] rangeOfString:@"|"];
    if (range.length > 0)
    {
        name = [[dict objectForKey:@"index"] substringToIndex:range.location];
        stunum = [[dict objectForKey:@"index"] substringFromIndex:range.location+1];
        if ([stunum length] > 0)
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",name,stunum];
        }
        else
        {
            cell.nameLabel.text = name;
        }
    }
    
    
    int total = 0;
    NSArray *scoreArray = [dict objectForKey:@"scores"];
    for(NSDictionary *dict in scoreArray)
    {
        if ([dict objectForKey:@"score"] && ![[dict objectForKey:@"score"] isEqual:[NSNull null]])
        {
            total += [[dict objectForKey:@"score"] integerValue];
        }
    }
    [cell.timeLabel cnv_setUILabelText:[NSString stringWithFormat:@"总成绩%d分",total] andKeyWord:[NSString stringWithFormat:@"%d",total]];
    cell.timeLabel.font = [UIFont systemFontOfSize:12];
    [cell.timeLabel cnv_setUIlabelTextColor:COMMENTCOLOR andKeyWordColor:RGB(51, 204, 102, 0.8)];

    
    cell.arrowImageView.hidden = NO;
    [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 17.5, 10, 15)];
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
    NSDictionary *dict = [memListArray objectAtIndex:indexPath.row];
    ScoreDetailViewController *scoreDetailViewController = [[ScoreDetailViewController alloc] init];
    scoreDetailViewController.objectArray = [dict objectForKey:@"scores"];
    scoreDetailViewController.testName = testName;
    scoreDetailViewController.pubName = pubName;
    scoreDetailViewController.pubTime = pubTime;
    NSString *name = @"";
    NSString *stunum = @"";
    NSRange range = [[dict objectForKey:@"index"] rangeOfString:@"|"];
    if (range.length > 0)
    {
        name = [[dict objectForKey:@"index"] substringToIndex:range.location];
        stunum = [[dict objectForKey:@"index"] substringFromIndex:range.location+1];
        if ([stunum length] > 0)
        {
            scoreDetailViewController.stuName = [NSString stringWithFormat:@"%@(%@)",name,stunum];
        }
        else
        {
            scoreDetailViewController.stuName = name;
        }
    }

    [self.navigationController pushViewController:scoreDetailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)getScoreDetail
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"e_id":scoreid,
                                                                      } API:SCOREDETAIL];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"score detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [memListArray removeAllObjects];
                [memListArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"details"]];
                pubTime = [[[responseDict objectForKey:@"data"] objectForKey:@"pTime"] objectForKey:@"sec"];
                pubName = [[[responseDict objectForKey:@"data"] objectForKey:@"publishedBy"] objectForKey:@"name"];
                testName = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                [memListTableView reloadData];
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
