//
//  InviteStuPareViewController.m
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "InviteStuPareViewController.h"
#import "Header.h"

@interface InviteStuPareViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView *parentsTableView;
    NSArray *parentArray;
    UITextField *parentTextField;
    UILabel *parentLabel;
    UIImageView *bg2;
    
    UIView *buttonView;
    
    BOOL open;
    
    UILabel *tipLabel;
}
@end

@implementation InviteStuPareViewController
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
    
    open = YES;
    
    self.titleLabel.text = @"邀请学生家长";
    NSString *tipStr = [NSString stringWithFormat:@"您正在邀请%@的",name];
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, UI_NAVIGATION_BAR_HEIGHT+45, [tipStr length]*18, 30)];
    tipLabel.text = tipStr;
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    CGFloat yyy = tipLabel.frame.size.height+tipLabel.frame.origin.y;
    
    bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(27, yyy+20, 134, 30)];
    [bg2 setImage:inputImage];
    [self.bgView addSubview:bg2];
    
    parentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, bg2.frame.size.height+bg2.frame.origin.y, bg2.frame.size.width, 0) style:UITableViewStylePlain];
    parentsTableView.delegate = self;
    parentsTableView.dataSource = self;
    parentsTableView.tag = 1000;
    [self.bgView addSubview:parentsTableView];
    
    parentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 60, 20)];
    parentLabel.backgroundColor = [UIColor clearColor];
    parentLabel.textColor = [UIColor grayColor];
    parentLabel.textAlignment = NSTextAlignmentCenter;
    parentLabel.font = [UIFont systemFontOfSize:15];
    [bg2 addSubview:parentLabel];

    UIButton *parentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    parentButton.frame = CGRectMake(bg2.frame.size.width+bg2.frame.origin.x-30, yyy+20, 40, 30);
    parentButton.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    [parentButton addTarget:self action:@selector(opentableview) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:parentButton];
    
    parentArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"输入", nil];
    
    parentTextField = [[UITextField alloc] initWithFrame:CGRectMake(parentButton.frame.size.width+parentButton.frame.origin.x+20 , parentButton.frame.origin.y, 100, 30)];
    parentTextField.enabled = NO;
    parentTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    parentTextField.delegate = self;
    parentTextField.textAlignment = NSTextAlignmentCenter;
    parentTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    parentTextField.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:parentTextField];
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opentableview)];
    parentTextField.userInteractionEnabled = YES;
    [parentTextField addGestureRecognizer:tgr];
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"微博私信邀请",@"微信邀请",@"手机短信邀请",@"邀请好友", nil];
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];

    buttonView = [[UIView alloc] initWithFrame:CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+20, SCREEN_WIDTH-60, 40*[array count])];
    [self.bgView addSubview:buttonView];
    
    for (int i=0; i<[array count]; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 40*i, SCREEN_WIDTH-60, 38);
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(inviteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000+i;
        [button setBackgroundImage:btnImage forState:UIControlStateNormal];
        [buttonView addSubview:button];
    }
    
    [self.bgView addSubview:parentsTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)opentableview
{
    if (open)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            parentsTableView.frame = CGRectMake(27, parentsTableView.frame.origin.y, bg2.frame.size.width, [parentArray count]*30);
            buttonView.frame = CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+10, SCREEN_WIDTH-60, 120);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            parentsTableView.frame = CGRectMake(27, parentsTableView.frame.origin.y, bg2.frame.size.width, 0);
            buttonView.frame = CGRectMake(30, parentsTableView.frame.size.height+parentsTableView.frame.origin.y+20, SCREEN_WIDTH-60, 120);

        }];
    }
    open = !open;
    [parentsTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [parentArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *relateCell = @"relateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
    }
    cell.textLabel.text = [parentArray objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [parentArray count]-1)
    {
        parentLabel.text = nil;
        parentTextField.enabled = YES;
        [parentTextField becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self opentableview];
    }
    else
    {
        parentLabel.text = [parentArray objectAtIndex:indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        parentTextField.enabled = NO;
        parentTextField.text = nil;
        [self opentableview];
    }
}

-(void)inviteButtonClick:(UIButton *)button
{
    if (button.tag == 1000)
    {
        //微博私信邀请
    }
    else if(button.tag == 1001)
    {
        //微信邀请
    }
    else if(button.tag == 1002)
    {
        //手机短信邀请
    }
    else if(button.tag == 1003)
    {
        //邀请好友
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [parentTextField resignFirstResponder];
    return YES;
}

@end
