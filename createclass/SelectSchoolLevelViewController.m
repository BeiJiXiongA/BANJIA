//
//  SelectSchoolLevelViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/13/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SelectSchoolLevelViewController.h"

@interface SelectSchoolLevelViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *schoolLevelArray;
    NSDictionary *schoolLevelDict;
}
@end

@implementation SelectSchoolLevelViewController
@synthesize selectSchoolLevelDel,fromCreate;
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
    
    if (fromCreate)
    {
        schoolLevelArray = SCHOOLLEVELARRAY;
        schoolLevelDict = SCHOOLLEVELDICT;
    }
    else
    {
        schoolLevelArray = SEARCHSCHOOLLEVELARRAY;
        schoolLevelDict = SEARCHSCHOOLLEVELDICT;
    }
    
    CGFloat maxHeight = SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-10;
    if ([schoolLevelArray count] * 40 > maxHeight)
    {
        maxHeight = maxHeight/40 * 40;
    }
    else
    {
        maxHeight = [schoolLevelArray count] * 40;
    }
    
    UITableView *schoolLevelTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, UI_NAVIGATION_BAR_HEIGHT + 10, SCREEN_WIDTH-10, maxHeight) style:UITableViewStylePlain];
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
    return [schoolLevelArray count];
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
    cell.textLabel.text = [schoolLevelDict objectForKey:[schoolLevelArray objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectSchoolLevelDel respondsToSelector:@selector(updateSchoolLevelWith:andId:)])
    {
        [self.selectSchoolLevelDel updateSchoolLevelWith:[schoolLevelDict objectForKey:[schoolLevelArray objectAtIndex:indexPath.row]] andId:[schoolLevelArray objectAtIndex:indexPath.row]];
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
