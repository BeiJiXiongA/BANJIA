//
//  EditNameViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-7-3.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "EditNameViewController.h"

@interface EditNameViewController ()<UITextFieldDelegate>
{
    MyTextField *nameTextField;
}
@end

@implementation EditNameViewController
@synthesize editnameDoneDel,name;
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
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"完成" forState:UIControlStateNormal];
    [inviteButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(editDone) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH-80, 42)];
    nameTextField.background = nil;
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.text = name;
    nameTextField.delegate = self;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.textColor = COMMENTCOLOR;
    nameTextField.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:nameTextField];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)editDone
{
    if ([self.editnameDoneDel respondsToSelector:@selector(editNameDone:)])
    {
        [self.editnameDoneDel editNameDone:nameTextField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
