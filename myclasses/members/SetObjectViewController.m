//
//  SetObjectViewController.m
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SetObjectViewController.h"
#import "Header.h"
#import "OjectCell.h"
#import "KLSwitch.h"
#import "InfoCell.h"
#import "AddObjectViewController.h"

@interface SetObjectViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
AddObjectDel>
{
    NSMutableDictionary *selectDict;
    UITableView *objectTabelView;
    KLSwitch *noticeSwitch;
    NSMutableArray *objectArray;
    
    MyTextField *addObjectTextField;
    UIButton *addButton;
    int alert;
    
    NSMutableArray *titleArray;
    OperatDB *db;
}
@end

@implementation SetObjectViewController
@synthesize name,userid,classID,title;
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
    
    self.titleLabel.text = @"设置班级角色";
    
    db = [[OperatDB alloc] init];
    
    //    [self.backButton setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
    //    self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.backButton.frame.origin.y, [name length]*18, self.backButton.frame.size.height);
    titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    if ([title length] > 0)
    {
        [titleArray addObjectsFromArray:[title componentsSeparatedByString:@","]];
    }
    
    alert = 0;
    
    objectArray = [[NSMutableArray alloc] initWithArray:OBJECTARRAY];
    for (int i=0; i<[titleArray count]; i++)
    {
        if (![objectArray containsObject:[titleArray objectAtIndex:i]])
        {
            [objectArray addObject:[titleArray objectAtIndex:i]];
        }
    }
    selectDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+20, 150, 20)];
    tipLabel.text = [NSString stringWithFormat:@"您想更改%@为",name];
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.textColor = UIColorFromRGB(0x727171);
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    objectTabelView = [[UITableView alloc] initWithFrame:CGRectMake( 0, UI_NAVIGATION_BAR_HEIGHT+ 50, SCREEN_WIDTH, 175.5) style:UITableViewStylePlain];
    objectTabelView.delegate = self;
    objectTabelView.dataSource =self;
    objectTabelView.backgroundColor = self.bgView.backgroundColor;
    objectTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:objectTabelView];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(31, objectTabelView.frame.size.height+objectTabelView.frame.origin.y, 40, 40);
    [addButton setImage:[UIImage imageNamed:@"set_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addObjectToObjects) forControlEvents:UIControlEventTouchUpInside];
    //    [self.bgView addSubview:addButton];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    addObjectTextField = [[MyTextField alloc] initWithFrame:CGRectMake(71, objectTabelView.frame.size.height+objectTabelView.frame.origin.y+5, SCREEN_WIDTH-62-40, 30)];
    addObjectTextField.background = inputImage;
    addObjectTextField.delegate = self;
    addObjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    addObjectTextField.placeholder = @"添加其他班级角色";
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [submit setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:submit];
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

-(void)valueChange
{
    if ([noticeSwitch isOn])
    {
        alert = 1;
    }
    else
    {
        alert = 0;
    }
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat maxhei = SCREEN_HEIGHT-100-UI_NAVIGATION_BAR_HEIGHT;
    int row = ([objectArray count]+1)%2 == 0 ? (((int)[objectArray count]+1)/2):(((int)[objectArray count]+1)/2+1);
    CGFloat height = 58.5 * row > maxhei ? maxhei : (58.5*row);
    objectTabelView.frame = CGRectMake(objectTabelView.frame.origin.x, objectTabelView.frame.origin.y, SCREEN_WIDTH, height);
    if (([objectArray count]+1)%2 == 0)
    {
        return ([objectArray count]+1)/2;
    }
    else
    {
        return ([objectArray count]+1)/2+1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *objcetCell = @"objectcell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:objcetCell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objcetCell
                ];
    }
    
    cell.button1.frame = CGRectMake(23.5, 6.5, 135, 52);
    cell.button1.layer.cornerRadius = 5;
    cell.button1.clipsToBounds = YES;
    cell.button1.tag = indexPath.row*2;
    [cell.button1 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    DDLOG(@"setstu object row %ld",(long)indexPath.row);
    
    if (indexPath.row * 2 > [objectArray count]-1)
    {
        [cell.button1 setTitle:@"+添加" forState:UIControlStateNormal];
        [cell.button1 setTitleColor:RGB(51, 204, 204, 1) forState:UIControlStateNormal];
        cell.button1.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        NSString *objectName1 = [objectArray objectAtIndex:indexPath.row*2];
        if ([titleArray containsObject:objectName1])
        {
            [cell.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.button1 setBackgroundImage:[UIImage imageNamed:@"selectobject"] forState:UIControlStateNormal];
            cell.button1.backgroundColor = self.bgView.backgroundColor;
        }
        else
        {
            [cell.button1 setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.button1 setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
            cell.button1.backgroundColor = [UIColor whiteColor];
        }
        [cell.button1 setTitle:[objectArray objectAtIndex:indexPath.row*2] forState:UIControlStateNormal];
    }
    
    cell.button2.hidden = YES;
    cell.button2.frame = CGRectMake(165.5, 6.5, 135, 52);
    [cell.button2 setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    cell.button2.layer.cornerRadius = 5;
    cell.button2.backgroundColor = [UIColor whiteColor];
    cell.button2.clipsToBounds = YES;
    cell.button2.tag = indexPath.row * 2 + 1;
    
    [cell.button2 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row*2+1 < ([objectArray count]+1))
    {
        cell.button2.hidden = NO;
        if (indexPath.row * 2 + 1 == [objectArray count])
        {
            [cell.button2 setTitle:@"+添加" forState:UIControlStateNormal];
            [cell.button2 setTitleColor:RGB(51, 204, 204, 1) forState:UIControlStateNormal];
            cell.button2.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            NSString *objectName2 = [objectArray objectAtIndex:indexPath.row*2+1];
            if ([titleArray containsObject:objectName2])
            {
                [cell.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cell.button2 setBackgroundImage:[UIImage imageNamed:@"selectobject"] forState:UIControlStateNormal];
                cell.button2.backgroundColor = self.bgView.backgroundColor;
            }
            else
            {
                [cell.button2 setBackgroundImage:nil forState:UIControlStateNormal];
                [cell.button2 setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
                cell.button2.backgroundColor = [UIColor whiteColor];
            }
            
            
            
            [cell.button2 setTitle:[objectArray objectAtIndex:indexPath.row*2+1] forState:UIControlStateNormal];
        }
    }
    
    cell.backgroundColor = self.bgView.backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)cellButtonClick:(UIButton *)button
{
    if (button.tag == [objectArray count])
    {
        AddObjectViewController *addObject = [[AddObjectViewController alloc] init];
        addObject.addobjectDel = self;
        [self.navigationController pushViewController:addObject animated:YES];
    }
    else
    {
        NSString *objectname = [objectArray objectAtIndex:button.tag];
        if ([titleArray containsObject:objectname])
        {
            [titleArray removeObject:objectname];
        }
        else
        {
            [titleArray addObject:objectname];
        }
        
        [objectTabelView reloadData];
    }
}
-(void)addObject:(NSString *)objectName
{
    [objectArray addObject:objectName];
    [titleArray addObject:objectName];
    [objectTabelView reloadData];
}

-(void)submit
{
    if ([titleArray count] == 0)
    {
        [Tools showAlertView:@"请选择班级角色" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        NSString *objectString;
        if ([titleArray count] > 0)
        {
            objectString = [titleArray componentsJoinedByString:@","];
        }
        else
        {
            objectString = @"";
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":userid,
                                                                      @"c_id":classID,
                                                                      @"role":@"teachers",
                                                                      @"onduty":[noticeSwitch isOn]?@"1":@"0",
                                                                      @"title":objectString
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"title" toValue:objectString withParaDict:@{@"uid":userid,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"title updata success!");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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
}

-(void)addObjectToObjects
{
    if ([addObjectTextField.text length] > 0)
    {
        
        [objectArray addObject:addObjectTextField.text];
        [objectTabelView reloadData];
        objectTabelView.scrollEnabled = YES;
        if ([objectArray count] < 8)
        {
            objectTabelView.frame = CGRectMake(31, UI_NAVIGATION_BAR_HEIGHT+63, SCREEN_WIDTH-62, 34*[objectArray count]);
            addButton.frame = CGRectMake(31, objectTabelView.frame.size.height+objectTabelView.frame.origin.y, 40, 40);
            addObjectTextField.frame = CGRectMake(addButton.frame.size.width+addButton.frame.origin.x, objectTabelView.frame.size.height+objectTabelView.frame.origin.y+5, SCREEN_WIDTH-62-50, 30);
        }
        else
        {
            objectTabelView.contentOffset = CGPointMake(0, objectTabelView.contentSize.height - objectTabelView.frame.size.height);
        }
        [addObjectTextField setText:nil];
        
    }
    else
    {
        [Tools showAlertView:@"请输入角色名称" delegateViewController:nil];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [addObjectTextField resignFirstResponder];
    addObjectTextField.text = nil;
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location>20)
    {
        [Tools showAlertView:@"请将字数限制在20个以内" delegateViewController:nil];
        return NO;
    }
    return YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [addObjectTextField resignFirstResponder];
}

@end
