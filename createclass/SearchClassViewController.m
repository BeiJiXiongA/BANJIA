//
//  SearchClassViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "SearchClassViewController.h"
#import "RelatedCell.h"
#import "SearchSchoolViewController.h"
#import "ClassZoneViewController.h"

@interface SearchClassViewController ()<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate>
{
    UITableView *searchClassTableView;
}
@end

@implementation SearchClassViewController

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
    
    self.titleLabel.text = @"查找班级";
    
    searchClassTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 158) style:UITableViewStylePlain];
    searchClassTableView.delegate = self;
    searchClassTableView.dataSource  = self;
    searchClassTableView.scrollEnabled = NO;
    [self.bgView addSubview:searchClassTableView];
    
    if ([searchClassTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        searchClassTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        return 35;
    }
    
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *name = @"searchclasscell";
    RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (cell == nil)
    {
        cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
    }
    cell.contentLabel.hidden = YES;
    cell.nametf.hidden = YES;
    cell.iconImageView.hidden = YES;
    cell.relateButton.hidden = YES;
    
    if (indexPath.row == 1)
    {
        cell.nametf.hidden = NO;
        cell.nametf.tag = 4444;
        cell.nametf.delegate = self;
        cell.nametf.background = nil;
        cell.nametf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        cell.nametf.returnKeyType = UIReturnKeySearch;
        
        cell.nametf.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        cell.nametf.textAlignment = NSTextAlignmentLeft;
        cell.nametf.placeholder = @"请输入班号";
    }
    else if(indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = self.bgView.backgroundColor;
        if (indexPath.row == 0)
        {
            cell.contentLabel.frame = CGRectMake(10, 5, 100, 25);
            cell.contentLabel.hidden = NO;
            cell.contentLabel.text = @"  输入班号";
        }
    }
    else
    {
        cell.contentLabel.hidden = NO;
        cell.iconImageView.hidden = NO;
        
        cell.iconImageView.frame = CGRectMake(15, 7, 30, 30);
        cell.iconImageView.backgroundColor = [UIColor greenColor];
        cell.iconImageView.layer.cornerRadius = 3;
        cell.iconImageView.clipsToBounds = YES;
        
        cell.contentLabel.frame = CGRectMake(60, 10, 100, 24);
        if (indexPath.row == 3)
        {
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_school"]];
            cell.contentLabel.text = @"按学校搜索";
        }
        else if (indexPath.row == 5)
        {
            cell.contentLabel.text = @"扫一扫";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 11)
    {
        //扫一扫
    }
    else if(indexPath.row == 3)
    {
        //按学校搜索
        SearchSchoolViewController *searchSchoolVC = [[SearchSchoolViewController alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:searchSchoolVC animated:YES];
    }
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DDLOG(@"class number %@",textField.text);
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
    [self searchClass:((UITextField *)[searchClassTableView viewWithTag:4444]).text];
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
}

-(void)searchClass:(NSString *)searchContent
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":@"",
                                                                      @"number":[NSString stringWithFormat:@"%d",[searchContent integerValue]]
                                                                      } API:SEARCHCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                    {
                        NSString *classID = [[responseDict objectForKey:@"data"] objectForKey:@"_id"];
                        NSString *className = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                        
                        OperatDB *db = [[OperatDB alloc] init];
                        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"classid":classID} andTableName:CLASSMEMBERTABLE] count]> 0)
                        {
                            [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
                            return ;
                        }
                        
                        NSString *schoolName;
                        if (![[[responseDict objectForKey:@"data"] objectForKey:@"school"] isEqual:[NSNull null]])
                        {
                            schoolName = [[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
                        }
                        else
                        {
                            schoolName = @"未指定学校";
                        }
                        
                        ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
                        classZone.fromClasses = YES;
                        [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
                        [[NSUserDefaults standardUserDefaults] setObject:className forKey:@"classname"];
                        [[NSUserDefaults standardUserDefaults] setObject:schoolName forKey:@"schoolname"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.navigationController pushViewController:classZone animated:YES];
                    }
                    
                    else
                    {
                        [Tools showTips:@"未找到任何班级" toView:self.bgView];
                    }
                }
                else
                {
                    [Tools showTips:@"未找到任何班级" toView:self.bgView];
                }
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
