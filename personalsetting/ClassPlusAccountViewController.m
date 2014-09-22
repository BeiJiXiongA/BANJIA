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
    
    array = [[NSArray alloc] initWithObjects:@"班家账号",@"注册方式",@"修改密码", nil];
    
    UITableView *accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+30, SCREEN_WIDTH-40, 100) style:UITableViewStylePlain];
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
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==1?20:0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 10)];
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    return headerLabel;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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
    cell.nameLabel.font = [UIFont systemFontOfSize:15];
    cell.objectsLabel.font = [UIFont systemFontOfSize:15];
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.nameLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH-40, 40);
    cell.nameLabel.backgroundColor = [UIColor whiteColor];
    cell.nameLabel.layer.cornerRadius = 5;
    cell.nameLabel.clipsToBounds = YES;
    cell.nameLabel.textColor = COMMENTCOLOR;
    
    cell.objectsLabel.textColor = CONTENTCOLOR;
    cell.objectsLabel.frame = CGRectMake(100, 10, SCREEN_WIDTH-150, 20);
    cell.objectsLabel.backgroundColor = [UIColor whiteColor];
    cell.objectsLabel.textAlignment = NSTextAlignmentRight;
    cell.nameLabel.text = [NSString stringWithFormat:@"    %@",[array objectAtIndex:indexPath.section *2+indexPath.row]];
    cell.accessoryView = nil;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.objectsLabel.text = [Tools phone_num];
        }
        else if(indexPath.row == 1)
        {
            cell.objectsLabel.text = @"手机注册";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            UIImageView *accImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discovery_arrow"]];
            accImageView.backgroundColor = [UIColor whiteColor];
            cell.accessoryView = accImageView;
            cell.accessoryView.backgroundColor = [UIColor whiteColor];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 55.5, 10, 15)];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.backgroundColor = self.bgView.backgroundColor;
    cell.contentView.backgroundColor = self.bgView.backgroundColor;
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
