//
//  ClassesListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ClassesListViewController.h"
#import "RelatedCell.h"

@interface ClassesListViewController ()<
UITableViewDataSource,
UITableViewDelegate>
{
    UITableView *classesTableView;
    NSMutableArray *classArray;
    NSMutableArray *selectedClassids;
}
@end

@implementation ClassesListViewController
@synthesize selectClassdel;
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
    classArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    selectedClassids = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(SCREEN_WIDTH - 60, 4, 50, 36);
    doneButton.backgroundColor = [UIColor clearColor];
    [doneButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.navigationBarView addSubview:doneButton];
    
    classesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classesTableView.delegate = self;
    classesTableView.dataSource = self;
    [self.bgView addSubview:classesTableView];
    
    if ([classesTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classesTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self getClassesByUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneClick
{
    if ([selectedClassids count] == 0)
    {
        [Tools showAlertView:@"您还未选择任何班级哦!" delegateViewController:nil];
        return ;
    }
    if ([self.selectClassdel respondsToSelector:@selector(selectClasses:)])
    {
        [self.selectClassdel selectClasses:selectedClassids];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [classArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"waittingselectclasscell";
    //mlgb i'm so cold in the aircondition room
    RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    NSDictionary *dict = [classArray objectAtIndex:indexPath.row];
    
    cell.contentLabel.frame = CGRectMake(10, 10, 250, 30);
    cell.contentLabel.text = [dict objectForKey:@"name"];
    cell.nametf.hidden = YES;
    [cell.relateButton setTitle:@"" forState:UIControlStateNormal];
    cell.relateButton.frame = CGRectMake(SCREEN_WIDTH-60, 10, 30, 30);
    cell.relateButton.backgroundColor = [UIColor whiteColor];
    if ([selectedClassids containsObject:[dict objectForKey:@"_id"]])
    {
        [cell.relateButton setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.relateButton setImage:[UIImage imageNamed:@"unselectBtn"] forState:UIControlStateNormal];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [classArray objectAtIndex:indexPath.row];
//    if ([selectedClassids containsObject:[dict objectForKey:@"_id"]])
//    {
//        [selectedClassids removeObject:[dict objectForKey:@"_id"]];
//    }
//    else
//    {
//        [selectedClassids addObject:[dict objectForKey:@"_id"]];
//    }
    [selectedClassids removeAllObjects];
    [selectedClassids addObject:[dict objectForKey:@"_id"]];
    [classesTableView reloadData];
}

-(void)getClassesByUser
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:GETCLASSESBYUSER];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classesByUser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [classArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"classes"]];
                [classesTableView reloadData];
                
                CGFloat height = [classArray count]*50>(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)?(SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT):([classArray count] *50);
                classesTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, height);
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);

        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
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
