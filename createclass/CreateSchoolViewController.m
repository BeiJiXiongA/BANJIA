//
//  CreateSchoolViewController.m
//  BANJIA
//
//  Created by TeekerZW on 4/8/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "CreateSchoolViewController.h"
#import "Header.h"
#import "CreateClassViewController.h"

@interface CreateSchoolViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    MyTextField *schoolNameTextField;
    NSArray *schoolLevelArray;
    NSArray *valueArray;
    
    UITableView *levelTableView;
    UIButton *openLevelButton;
    
    NSString *levelStr;
    NSString *levelValue;
    
    BOOL levelOpen;
    UIButton *createClassButton;
}
@end

@implementation CreateSchoolViewController
@synthesize schoolName,classID;
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
    self.titleLabel.text = @"创建学校";
    
    levelStr = @"中学";
    levelValue = @"2";
    levelOpen = YES;
    
    schoolNameTextField = [[MyTextField alloc] init];
    schoolNameTextField.placeholder = @"请输入学校名称";
    schoolNameTextField.text = schoolName;
    schoolNameTextField.font = [UIFont systemFontOfSize:16];
    schoolNameTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    schoolNameTextField.textColor = TITLE_COLOR;
    schoolNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    schoolNameTextField.frame = CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH - 20, 35);
    schoolNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:schoolNameTextField];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(30, schoolNameTextField.frame.size.height+schoolNameTextField.frame.origin.y+30, 140, 40);
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.text = @"学校类别";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:tipLabel];
    
    openLevelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openLevelButton.frame = CGRectMake(150,schoolNameTextField.frame.size.height+schoolNameTextField.frame.origin.y+30, 100, 35);
    [openLevelButton setTitle:levelStr forState:UIControlStateNormal];
    [openLevelButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)] forState:UIControlStateNormal];
    [openLevelButton addTarget:self action:@selector(openlevel) forControlEvents:UIControlEventTouchUpInside];
    [openLevelButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [self.bgView addSubview:openLevelButton];
    
    schoolLevelArray = [NSArray arrayWithObjects:@"幼儿园",@"小学",@"中学",@"中专技校",@"培训机构",@"其他", nil];
    valueArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5", nil];
    
    
    levelTableView = [[UITableView alloc] initWithFrame:CGRectMake(170, openLevelButton.frame.size.height+openLevelButton.frame.origin.y, 100, 0) style:UITableViewStylePlain];
    levelTableView.dataSource  = self;
    levelTableView.delegate = self;
    
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    createClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createClassButton setTitle:@"创建学校" forState:UIControlStateNormal];
    createClassButton.frame = CGRectMake(SCREEN_WIDTH/2-60, levelTableView.frame.size.height+levelTableView.frame.origin.y+40, 120, 40);
    [createClassButton addTarget:self action:@selector(createClassClick) forControlEvents:UIControlEventTouchUpInside];
    [createClassButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.bgView addSubview:createClassButton];
    
    [self.bgView addSubview:levelTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openlevel
{
    if (levelOpen)
    {
        [UIView animateWithDuration:0.2 animations:^{
            levelTableView.frame = CGRectMake(openLevelButton.frame.origin.x, openLevelButton.frame.size.height+openLevelButton.frame.origin.y, 100, [schoolLevelArray count]*40);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            levelTableView.frame = CGRectMake(openLevelButton.frame.origin.x, openLevelButton.frame.size.height+openLevelButton.frame.origin.y, 100, 0);
        }];
    }
    levelOpen = !levelOpen;
}

#pragma mark - tableView
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
    static NSString *levelCell = @"levelCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:levelCell];
    if (cell == nil)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:levelCell];
    }
    cell.textLabel.text = [schoolLevelArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = TITLE_COLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    levelStr = [schoolLevelArray objectAtIndex:indexPath.row];
    levelValue = [valueArray objectAtIndex:indexPath.row];
    [openLevelButton setTitle:levelStr forState:UIControlStateNormal];
    levelValue = [valueArray objectAtIndex:indexPath.row];
    [self openlevel];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)createClassClick
{
    
    if (![schoolNameTextField.text length] > 0)
    {
        [Tools showAlertView:@"请确定学校名称" delegateViewController:nil];
        return;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"name":[NSString stringWithFormat:@"%@（%@）",[schoolNameTextField text],[schoolLevelArray objectAtIndex:[levelValue integerValue]]],
                                                                      @"level":levelValue} API:CREATESCHOOL];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *schoolID = [responseDict objectForKey:@"data"];
                CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
                createClassViewController.schoolName = schoolNameTextField.text;
                createClassViewController.schoolLevel = levelValue;
                createClassViewController.schoollID = schoolID;
                [createClassViewController showSelfViewController:self];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
