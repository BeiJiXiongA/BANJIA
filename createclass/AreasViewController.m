//
//  AreasViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/16/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "AreasViewController.h"

@interface AreasViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AreasViewController
@synthesize areaArray,selectAreaDel,fromCreate;
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
    
    self.titleLabel.text = @"选择地区";
    CGFloat height = [areaArray count]*40>(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-20)?(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-20):([areaArray count]*40);
    UITableView *schoolLevelTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, UI_NAVIGATION_BAR_HEIGHT + 10, SCREEN_WIDTH-10, height) style:UITableViewStylePlain];
    schoolLevelTableView.delegate  = self;
    schoolLevelTableView.dataSource = self;
    schoolLevelTableView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:schoolLevelTableView];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(fromCreate)
    {
        return [areaArray count];
    }
    return [areaArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *schoolLevel = @"schoollevelcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolLevel];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolLevel];
    }
    if (fromCreate)
    {
        cell.textLabel.text = [[areaArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"全部";
        }
        else
        {
            cell.textLabel.text = [[areaArray objectAtIndex:indexPath.row-1] objectForKey:@"name"];
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectAreaDel respondsToSelector:@selector(selectAreaWithDict:)])
    {
        if (fromCreate)
        {
            [self.selectAreaDel selectAreaWithDict:[areaArray objectAtIndex:indexPath.row]];
        }
        else
        {
            if (indexPath.row > 0)
            {
                [self.selectAreaDel selectAreaWithDict:[areaArray objectAtIndex:indexPath.row-1]];
            }
            else
            {
                [self.selectAreaDel selectAreaWithDict:@{@"_id":@"",@"name":@"全部"}];
            }
        }
    }
    [self unShowSelfViewController];
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
