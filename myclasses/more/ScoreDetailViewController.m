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
    NSMutableArray *objectArray;
    UITableView *objectTableView;
}
@end

@implementation ScoreDetailViewController
@synthesize testName,pubName,pubTime;
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
    
    objectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    objectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    objectTableView.delegate = self;
    objectTableView.dataSource = self;
    objectTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:objectTableView];
    
    objectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [objectArray addObjectsFromArray:[NSArray arrayWithObjects:@{@"name":@"语文",@"score":@"97"},@{@"name":@"数学",@"score":@"97"},@{@"name":@"英语",@"score":@"111"},@{@"name":@"总分",@"score":@"305"}, nil]];
    
    [objectTableView reloadData];
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
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 100, 20)];
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    headerLabel.text = @"我的成绩";
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
        [cell.contentView addSubview:nameLabel];
        nameLabel.text = testName;
        
        UILabel *pubLabel = [[UILabel alloc] init];
        pubLabel.frame = CGRectMake(16, nameLabel.frame.size.height+nameLabel.frame.origin.y+5, 220, 20);
        pubLabel.textColor = [UIColor whiteColor];
        pubLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:pubLabel];
        pubLabel.text = [NSString stringWithFormat:@"发布人:%@",pubName];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.frame = CGRectMake(16, pubLabel.frame.size.height+pubLabel.frame.origin.y, 220, 20);
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:timeLabel];
        timeLabel.text = [NSString stringWithFormat:@"发布时间:%@",pubTime];
        
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
    
    cell.markLabel.frame = CGRectMake(SCREEN_WIDTH-50, 11, 40, 20);
    cell.markLabel.backgroundColor = [UIColor whiteColor];
    cell.markLabel.font = [UIFont systemFontOfSize:16];
    
    cell.setLabel.text = [dict objectForKey:@"name"];
    
    cell.markLabel.text = [dict objectForKey:@"score"];
    
    cell.markLabel.textColor = RGB(51, 204, 102, 0.8);
    
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
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
