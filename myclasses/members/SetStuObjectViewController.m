//
//  SetStuObjectViewController.m
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SetStuObjectViewController.h"
#import "Header.h"
#import "OjectCell.h"
#import "KLSwitch.h"

@interface SetStuObjectViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableDictionary *selectDict;
    UITableView *objectTabelView;
    KLSwitch *noticeSwitch;
    NSMutableArray *objectArray;
    
    MyTextField *addObjectTextField;
    UIButton *addButton;
    int alert;
}
@end

@implementation SetStuObjectViewController
@synthesize name,userid,classID,setStudel;
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
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    alert = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    objectArray = [[NSMutableArray alloc] initWithArray:@[@"班长",@"生活委员",@"学习委员",@"文体委员"]];
    selectDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+20, 150, 20)];
    tipLabel.text = [NSString stringWithFormat:@"您想任命%@为",name];
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.textColor = UIColorFromRGB(0x727171);
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    objectTabelView = [[UITableView alloc] initWithFrame:CGRectMake(31, 120, SCREEN_WIDTH-62, 160) style:UITableViewStylePlain];
    objectTabelView.delegate = self;
    objectTabelView.dataSource =self;
    objectTabelView.scrollEnabled = NO;
    [self.bgView addSubview:objectTabelView];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(31, objectTabelView.frame.size.height+objectTabelView.frame.origin.y, 40, 40);
    [addButton setImage:[UIImage imageNamed:@"set_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addObjectToObjects) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:addButton];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    addObjectTextField = [[MyTextField alloc] initWithFrame:CGRectMake(71, objectTabelView.frame.size.height+objectTabelView.frame.origin.y+5, SCREEN_WIDTH-62-40, 30)];
    addObjectTextField.background = inputImage;
    addObjectTextField.delegate = self;
    addObjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    addObjectTextField.placeholder = @"添加其他班级角色";
    [self.bgView addSubview:addObjectTextField];
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT-50, 170, 30)];
    tipLabel2.text = @"将任命通知班级成员";
    tipLabel2.backgroundColor = [UIColor clearColor];
    tipLabel2.textColor = UIColorFromRGB(0x727171);
    [self.bgView addSubview:tipLabel2];
    
    noticeSwitch = [[KLSwitch alloc] init];
    noticeSwitch.frame = CGRectMake(SCREEN_WIDTH-100, SCREEN_HEIGHT-50, 80, 30);
    [noticeSwitch addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
//    [noticeSwitch isOn:YES];
    [self.bgView addSubview:noticeSwitch];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [submit setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
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

-(void)submit
{
    if ([Tools NetworkReachable])
    {
        NSMutableString *jobTitle = [[NSMutableString alloc] initWithCapacity:0];
        [BPush delTag:classID];
        if ([selectDict count] >0)
        {
            for(NSString *key in selectDict)
            {
                [jobTitle insertString:[NSString stringWithFormat:@"%@,",[selectDict objectForKey:key]] atIndex:[jobTitle length]];
            }
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":userid,
                                                                      @"c_id":classID,
                                                                      @"role":@"students",
                                                                      @"alert":[NSString stringWithFormat:@"%d",alert],
                                                                      @"title":[jobTitle length]>0?[jobTitle substringToIndex:[jobTitle length]-1]:@""
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.setStudel respondsToSelector:@selector(setStuObj:)])
                {
                    [self.setStudel setStuObj:[jobTitle length]>0?[jobTitle substringToIndex:[jobTitle length]-1]:@""];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
            objectTabelView.frame = CGRectMake(31, 120, SCREEN_WIDTH-62, 40*[objectArray count]);
            addButton.frame = CGRectMake(31, objectTabelView.frame.size.height+objectTabelView.frame.origin.y, 40, 40);
            addObjectTextField.frame = CGRectMake(addButton.frame.size.width+addButton.frame.origin.x, objectTabelView.frame.size.height+objectTabelView.frame.origin.y+5, SCREEN_WIDTH-62-50, 30);
        }
        else
        {
            objectTabelView.contentOffset = CGPointMake(0, objectTabelView.contentSize.height - objectTabelView.frame.size.height);
        }
        
    }
    else
    {
        [Tools showAlertView:@"请输入角色名称" delegateViewController:nil];
    }
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *objcetCell = @"objectcell";
    OjectCell *cell = [tableView dequeueReusableCellWithIdentifier:objcetCell];
    if (cell == nil)
    {
        cell = [[OjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objcetCell
                ];
    }
    cell.nameLabel.text = [objectArray objectAtIndex:indexPath.row];
    cell.selectButton.tag = indexPath.row*1000;
    [cell.selectButton addTarget:self action:@selector(operateObject:) forControlEvents:UIControlEventTouchUpInside];
    if ([[selectDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] length] > 0)
    {
        [cell.selectButton setBackgroundImage:[UIImage imageNamed:@"icon_sel_sel"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.selectButton setBackgroundImage:[UIImage imageNamed:@"icon_sel"] forState:UIControlStateNormal];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[selectDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] length] > 0)
    {
        [selectDict removeObjectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    else
    {
        [selectDict setObject:[objectArray objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    [objectTabelView reloadData];
}

-(void)operateObject:(UIButton *)button
{
    if ([[selectDict objectForKey:[NSString stringWithFormat:@"%d",button.tag/1000]] length] > 0)
    {
        [selectDict removeObjectForKey:[NSString stringWithFormat:@"%d",button.tag/1000]];
    }
    else
    {
        [selectDict setObject:[objectArray objectAtIndex:button.tag/1000] forKey:[NSString stringWithFormat:@"%d",button.tag/1000]];
    }
    [objectTabelView reloadData];
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
        [Tools showAlertView:@"请将字数限制在18个以内" delegateViewController:nil];
        return NO;
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        //        if (height > addObjectTextField.frame.origin.y+30)
        {
            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, CENTER_POINT.y - height+(SCREEN_HEIGHT-addObjectTextField.frame.origin.y-50));
        }
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y);
    }completion:^(BOOL finished) {
        
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [addObjectTextField resignFirstResponder];
}


@end
