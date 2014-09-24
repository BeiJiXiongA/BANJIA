//
//  ClassPlusAccountViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/13/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ClassPlusAccountViewController.h"
#import "PersonalSettingCell.h"
#import "ResetPwdViewController.h"

@interface ClassPlusAccountViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *array;
}
@end

@implementation ClassPlusAccountViewController
@synthesize reg_method,banjia_number;
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
    
    self.titleLabel.text = @"班家账号";
    
    array = [[NSArray alloc] initWithObjects:@"班家账号",@"注册方式", nil];
    
    UITableView *accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+30, SCREEN_WIDTH, 80) style:UITableViewStylePlain];
    accountTableView.delegate = self;
    accountTableView.dataSource = self;
    accountTableView.tableHeaderView = nil;
    accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    accountTableView.backgroundColor = [UIColor whiteColor];
    accountTableView.scrollEnabled = NO;
    [self.bgView addSubview:accountTableView];
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

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        return 40;
    }
    else if (indexPath.row == 2 && [[Tools phone_num] length] > 0)
    {
        return 40;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classInfoCell = @"classInfoCell";
    PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:classInfoCell];
    if (cell == nil)
    {
        cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classInfoCell];
    }
    cell.headerImageView.hidden = YES;
    cell.nameLabel.font = [UIFont systemFontOfSize:16];
    cell.objectsLabel.font = [UIFont systemFontOfSize:16];
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.nameLabel.frame = CGRectMake(15, 0, SCREEN_WIDTH-40, 40);
    cell.nameLabel.backgroundColor = [UIColor whiteColor];
    cell.nameLabel.layer.cornerRadius = 5;
    cell.nameLabel.clipsToBounds = YES;
    cell.nameLabel.textColor = TITLE_COLOR;
    
    cell.objectsLabel.textColor = TITLE_COLOR;
    cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-115, 10, 100, 20);
    cell.objectsLabel.backgroundColor = [UIColor whiteColor];
    cell.objectsLabel.textAlignment = NSTextAlignmentRight;
    
    if (indexPath.row == 0)
    {
        cell.nameLabel.text = @"班家账号";
        cell.objectsLabel.text = banjia_number;
    }
    else if(indexPath.row == 1)
    {
        cell.nameLabel.text = @"注册方式";
        if ([reg_method isEqualToString:@"phone"])
        {
            cell.objectsLabel.text = @"手机";
        }
        else if([reg_method isEqualToString:@"sw"])
        {
            cell.objectsLabel.text = @"新浪微博";
        }
        else if ([reg_method isEqualToString:@"qq"])
        {
            cell.objectsLabel.text = @"QQ";
        }
        else if ([reg_method isEqualToString:@"rr"])
        {
            cell.objectsLabel.text = @"人人";
        }
    }
    else
    {
        cell.nameLabel.text = @"";
        cell.objectsLabel.text = @"";
    }
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    cell.lineImageView.backgroundColor = LineBackGroudColor;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            ResetPwdViewController *resetPwdViewController = [[ResetPwdViewController alloc] init];
            
            [self.navigationController pushViewController:resetPwdViewController animated:YES];
        }
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
