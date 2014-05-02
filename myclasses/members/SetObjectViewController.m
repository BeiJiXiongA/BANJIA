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

@interface SetObjectViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableDictionary *selectDict;
    UITableView *objectTabelView;
    UISwitch *noticeSwitch;
    NSMutableArray *objectArray;
    
    UITextField *addObjectTextField;
    UIButton *addButton;
}
@end

@implementation SetObjectViewController
@synthesize name,userid,classID;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    objectArray = [[NSMutableArray alloc] initWithArray:@[@"数学老师",@"英语老师",@"语文老师",@"物理老师"]];
    selectDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, UI_NAVIGATION_BAR_HEIGHT+38, 150, 20)];
    tipLabel.text = [NSString stringWithFormat:@"您想任命%@为",name];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textColor = UIColorFromRGB(0x727171);
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    objectTabelView = [[UITableView alloc] initWithFrame:CGRectMake(31, tipLabel.frame.size.height+tipLabel.frame.origin.y+7, SCREEN_WIDTH-62, 34*4) style:UITableViewStylePlain];
    objectTabelView.delegate = self;
    objectTabelView.dataSource =self;
    objectTabelView.backgroundColor = [UIColor clearColor];
    objectTabelView.scrollEnabled = NO;
    [self.bgView addSubview:objectTabelView];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(31, objectTabelView.frame.size.height+objectTabelView.frame.origin.y, 40, 40);
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addObjectToObjects) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:addButton];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    addObjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(addButton.frame.size.width+addButton.frame.origin.x, objectTabelView.frame.size.height+objectTabelView.frame.origin.y+5, SCREEN_WIDTH-62-50, 30)];
    addObjectTextField.background = inputImage;
    addObjectTextField.delegate = self;
    addObjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    addObjectTextField.placeholder = @"  添加其他班级角色";
    [self.bgView addSubview:addObjectTextField];
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-70, SCREEN_WIDTH, 50)];
    buttomView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:buttomView];
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(33, 10, 170, 30)];
    tipLabel2.text = @"这位老师正在任职";
    tipLabel2.backgroundColor = [UIColor clearColor];
    tipLabel2.textColor = UIColorFromRGB(0x727171);
    [buttomView addSubview:tipLabel2];
    
    noticeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-81, 10, 80, 30)];
    noticeSwitch.onTintColor = LIGHT_BLUE_COLOR;
    [buttomView addSubview:noticeSwitch];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(SCREEN_WIDTH-60, 3, 40, 38);
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    submit.backgroundColor = [UIColor clearColor];
    [submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:submit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submit
{
    if ([selectDict count] == 0)
    {
        [Tools showAlertView:@"请选择班级角色" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        NSMutableString *jobTitle = [[NSMutableString alloc] initWithCapacity:0];
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
                                                                      @"title":[jobTitle substringToIndex:[jobTitle length]-1]
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self unShowSelfViewController];
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
            objectTabelView.frame = CGRectMake(31, UI_NAVIGATION_BAR_HEIGHT+63, SCREEN_WIDTH-62, 34*[objectArray count]);
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
    return 34;
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
    cell.nameLabel.frame = CGRectMake(18, 2.5, 180, 31.5);
    cell.nameLabel.text = [objectArray objectAtIndex:indexPath.row];
    cell.selectButton.tag = indexPath.row*1000;
    [cell.selectButton addTarget:self action:@selector(operateObject:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectButton.backgroundColor = [UIColor clearColor];
    if ([[selectDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] length] > 0)
    {
        cell.selectButton.layer.contentsGravity = kCAGravityResize;
        cell.selectButton.layer.contents = (__bridge id)([UIImage imageNamed:@"icon_sel_sel"].CGImage);
    }
    else
    {
        cell.selectButton.layer.contentsGravity = kCAGravityResize;
        cell.selectButton.layer.contents = (__bridge id)([UIImage imageNamed:@"icon_sel"].CGImage);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
    if (range.location>7)
    {
        [Tools showAlertView:@"请将字数限制在8个以内" delegateViewController:nil];
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
        if ([objectArray count]>4 || FOURS)
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
