//
//  ClassesListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ClassesListViewController.h"
#import "ClassCell.h"

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
    doneButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    doneButton.backgroundColor = [UIColor clearColor];
    [doneButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.navigationBarView addSubview:doneButton];
    
    classesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classesTableView.delegate = self;
    classesTableView.dataSource = self;
    classesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classesTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:classesTableView];
    
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
    return 83;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classname = @"homeselectclasscell";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:classname];
    if (cell == nil)
    {
        cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classname];
    }
    NSDictionary *classDict = [classArray objectAtIndex:indexPath.row];
    cell.headerImageView.frame = CGRectMake(10, 10, 50, 50);
    cell.headerImageView.layer.cornerRadius = 3;
    cell.headerImageView.clipsToBounds =YES;
    if (![[classDict objectForKey:@"img_icon"] isEqual:[NSNull null]] && [[classDict objectForKey:@"img_icon"] length] > 10)
    {
        [Tools fillImageView:cell.headerImageView withImageFromURL:[classDict objectForKey:@"img_icon"] andDefault:@"3100"];
    }
    else
    {
        [cell.headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    }
    cell.nameLabel.frame = CGRectMake(70, 12.5, SCREEN_WIDTH-95, 25);
    cell.nameLabel.text = [classDict objectForKey:@"name"];
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    
    int studentNum = 0;
    if(![[classDict objectForKey:@"students_num"] isEqual:[NSNull null]])
    {
        studentNum = [[classDict objectForKey:@"students_num"] integerValue];
    }
    int parentNum = 0;
    if(![[classDict objectForKey:@"parents_num"] isEqual:[NSNull null]])
    {
        parentNum = [[classDict objectForKey:@"parents_num"] integerValue];
    }
    
    [cell.timeLabel cnv_setUILabelText:[NSString stringWithFormat:@"%d名学生",studentNum]
                            andKeyWord:[NSString stringWithFormat:@"%d",studentNum]];
    cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.origin.x, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height+3, [cell.timeLabel.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]*6.5, 20);
    cell.timeLabel.font = [UIFont systemFontOfSize:16];
    [cell.timeLabel cnv_setUIlabelTextColor:TIMECOLOR andKeyWordColor:RGB(51, 204, 102, 0.8)];
    
    cell.timeLabel2.frame = CGRectMake(cell.timeLabel.frame.origin.x+cell.timeLabel.frame.size.width, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height+3, 110, 20);
    [cell.timeLabel2 cnv_setUILabelText:[NSString stringWithFormat:@"%d名家长已加入",parentNum]
                             andKeyWord:[NSString stringWithFormat:@"%d",parentNum]];
    cell.timeLabel2.font = [UIFont systemFontOfSize:16];
    [cell.timeLabel2 cnv_setUIlabelTextColor:TIMECOLOR andKeyWordColor:RGB(51, 204, 102, 0.8)];
    
    cell.bgView.frame = CGRectMake(10, 6.5, SCREEN_WIDTH-20, 70);
    
    NSString *classid = [classDict objectForKey:@"_id"];
    if ([selectedClassids containsObject:classid])
    {
        [cell.arrowImageView setImage:[UIImage imageNamed:@"selectBtn"]];
    }
    else
    {
        [cell.arrowImageView setImage:[UIImage imageNamed:@"unselectBtn"]];
    }
    cell.arrowImageView.tag = indexPath.row;
    UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapclass:)];
    cell.arrowImageView.userInteractionEnabled = YES;
    [cell.arrowImageView addGestureRecognizer:selectTap];
    
    cell.arrowImageView.frame = CGRectMake(cell.bgView.frame.size.width-35, 22.5, 25, 25);
    cell.arrowImageView.backgroundColor = [UIColor whiteColor];
    
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.bgView.layer.cornerRadius = 5;
    cell.bgView.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = self.bgView.backgroundColor;
    return cell;

}

-(void)tapclass:(UITapGestureRecognizer *)tap
{
    int selectViewTag = tap.view.tag;
    NSDictionary *dict = [classArray objectAtIndex:selectViewTag];
    [selectedClassids removeAllObjects];
    [selectedClassids addObject:[dict objectForKey:@"_id"]];
    [classesTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [classArray objectAtIndex:indexPath.row];
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
