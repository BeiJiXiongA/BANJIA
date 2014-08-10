//
//  ScoreDetailViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/30/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ScoreDetailViewController.h"
#import "LogOutCell.h"
#import "BlankCell.h"

@interface ScoreDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *objectTableView;
}
@end

@implementation ScoreDetailViewController
@synthesize testName,pubName,pubTime,scoreId,objectArray,stuName;
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
    
    self.titleLabel.text = @"成绩单";
    
    objectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    objectTableView.delegate = self;
    objectTableView.dataSource = self;
    objectTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:objectTableView];
    
    objectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [objectTableView reloadData];
    
    if (scoreId)
    {
        [self getScoreDetail];
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

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 46.5;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.bgView.backgroundColor;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 300, 20)];
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    if (stuName)
    {
         headerLabel.text = [NSString stringWithFormat:@"%@的成绩", stuName];
    }
    else
    {
         headerLabel.text = @"我的成绩";
    }
   
    headerLabel.textColor = COMMENTCOLOR;
    [headerView addSubview:headerLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    return [objectArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 100;
    }
    return 42;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *headerider = @"scoredetailcell";
        BlankCell *cell = [tableView dequeueReusableCellWithIdentifier:headerider];
        if (cell == nil)
        {
            cell = [[BlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerider];
        }
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, SCREEN_WIDTH, 100)];
        bgImageView.backgroundColor = self.bgView.backgroundColor;
        [bgImageView setImage:[UIImage imageNamed:@"scoretable"]];
        [cell.contentView addSubview:bgImageView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(16, 15, 220, 30);
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
        nameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLabel];
        nameLabel.text = testName;
        
        UILabel *pubLabel = [[UILabel alloc] init];
        pubLabel.frame = CGRectMake(16, nameLabel.frame.size.height+nameLabel.frame.origin.y+5, 220, 20);
        pubLabel.textColor = [UIColor whiteColor];
        pubLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:pubLabel];
        pubLabel.backgroundColor = [UIColor clearColor];
        pubLabel.text = [NSString stringWithFormat:@"发布人:%@",pubName];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.frame = CGRectMake(16, pubLabel.frame.size.height+pubLabel.frame.origin.y, 220, 20);
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:timeLabel];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = [NSString stringWithFormat:@"发布时间:%@",[Tools showTime:pubTime andFromat:@"yyyy-MM-dd"]];
        return cell;

    }
    static NSString *identifier = @"gradecell";
    LogOutCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[LogOutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dict = [objectArray objectAtIndex:indexPath.row];
    cell.setLabel.frame = CGRectMake(16, 6, 200, 30);
    cell.setLabel.textColor = CONTENTCOLOR;
    cell.setLabel.font = [UIFont systemFontOfSize:16];
    
    cell.markLabel.frame = CGRectMake(SCREEN_WIDTH-70, 11, 60, 20);
    cell.markLabel.backgroundColor = [UIColor whiteColor];
    cell.markLabel.font = [UIFont systemFontOfSize:16];
    
    cell.setLabel.text = [dict objectForKey:@"name"];
    
    if ([dict objectForKey:@"score"] && ![[dict objectForKey:@"score"] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:@"score"] isKindOfClass:[NSString class]])
        {
            cell.markLabel.text = [dict objectForKey:@"score"];
        }
        else
        {
            cell.markLabel.text = [NSString stringWithFormat:@"%.1f",[[dict objectForKey:@"score"] floatValue]];
        }
    }
    
    
    cell.markLabel.textColor = RGB(51, 204, 102, 0.8);
    
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)getScoreDetail
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"e_id":scoreId,
                                                                      } API:SCOREDETAIL];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"score detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                pubTime = [[[responseDict objectForKey:@"data"] objectForKey:@"pTime"] objectForKey:@"sec"];
                pubName = [[[responseDict objectForKey:@"data"] objectForKey:@"publishedBy"] objectForKey:@"name"];
                NSDictionary *details = [[[responseDict objectForKey:@"data"] objectForKey:@"details"] firstObject];
                objectArray = [details objectForKey:@"scores"];
                
                NSString *stunum = @"";
                NSString *name = @"";
                NSString *role = [[NSUserDefaults standardUserDefaults]objectForKey:@"role"];
                if (role && [role isEqualToString:@"parents"])
                {
                    NSRange range = [[details objectForKey:@"index"] rangeOfString:@"|"];
                    if (range.length > 0)
                    {
                        name = [[details objectForKey:@"index"] substringToIndex:range.location];
                        stunum = [[details objectForKey:@"index"] substringFromIndex:range.location+1];
                        if ([stunum length] > 0)
                        {
                            stuName = [NSString stringWithFormat:@"%@(%@)",name,stunum];
                        }
                        else
                        {
                            stuName = name;
                        }
                    }
                }
                [objectTableView reloadData];
                
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
