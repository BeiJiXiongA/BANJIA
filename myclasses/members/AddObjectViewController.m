//
//  AddObjectViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-29.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "AddObjectViewController.h"

@interface AddObjectViewController ()<UITextFieldDelegate>
{
    MyTextField *addObjectTextField;
}
@end

@implementation AddObjectViewController
@synthesize fromTeacher;
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
    
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, UI_NAVIGATION_BAR_HEIGHT+20, 180, 20)];
    
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.textColor = UIColorFromRGB(0x727171);
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tipLabel];
    
    addObjectTextField = [[MyTextField alloc] initWithFrame:CGRectMake( 0, UI_NAVIGATION_BAR_HEIGHT + 53, SCREEN_WIDTH, 50)];
    addObjectTextField.delegate = self;
    addObjectTextField.background = nil;
    addObjectTextField.textColor = CONTENTCOLOR;
    addObjectTextField.backgroundColor = [UIColor whiteColor];
    addObjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.bgView addSubview:addObjectTextField];
    
    
    if (fromTeacher)
    {
        self.titleLabel.text = @"添加班级角色";
        tipLabel.text = [NSString stringWithFormat:@"请输入班级角色名称"];
        addObjectTextField.placeholder = @"添加其他班级角色";
    }
    else
    {
        self.titleLabel.text = @"任命班干部";
        tipLabel.text = [NSString stringWithFormat:@"请输入班干部职位名称"];
        addObjectTextField.placeholder = @"添加其他班干部名称";
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(editDone) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(41.5, UI_NAVIGATION_BAR_HEIGHT + 120, SCREEN_WIDTH-83, 42.5);
    [self.bgView addSubview:doneButton];
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

-(void)editDone
{
    if ([addObjectTextField.text length] == 0)
    {
        if (fromTeacher)
        {
            [Tools showAlertView:@"请输入角色名称" delegateViewController:nil];
        }
        else
        {
            [Tools showAlertView:@"请输入职位名称" delegateViewController:nil];
        }
        return ;
    }
    if ([addObjectTextField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 21)
    {
        [Tools showAlertView:@"字数控制在7个汉字以内" delegateViewController:nil];
        return;
    }
    if ([self.addobjectDel respondsToSelector:@selector(addObject:)])
    {
        [self.addobjectDel addObject:addObjectTextField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
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
