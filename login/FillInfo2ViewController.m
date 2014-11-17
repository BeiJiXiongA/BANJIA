//
//  FillInfo2ViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-29.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "FillInfo2ViewController.h"
#import "Header.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"
#import "UIImageView+WebCache.h"
#import "HomeViewController.h"
#import "WelcomeViewController.h"

#define NAMETFTAG   1000
#define HEADERTAG   2000
#define SEXTAG      3000

@interface FillInfo2ViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
{
    NSString *sex;
    UIImage *fullScreenImage;
    UIImagePickerController *imagePickerController;
    
    MyTextField *pwdTextField;
    MyTextField *nameTextField;
    
    BOOL defaultHeaderIcon;
}
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *headerTapTgr;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@end

@implementation FillInfo2ViewController
@synthesize headerIcon,nickName,accountID,accountType,account,fromRoot,token,userid;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT+YSTART)/2);
    }completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-height+100);
    }completion:^(BOOL finished) {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (fromRoot)
    {
        self.titleLabel.text = @"完善信息";
        self.returnImageView.hidden = YES;
        self.backButton.hidden = YES;
        
        
        UIButton *loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginOutButton.frame = self.backButton.frame;
        [loginOutButton setTitle:@"退出" forState:UIControlStateNormal];
        [loginOutButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [loginOutButton addTarget:self action:@selector(loginOutClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:loginOutButton];
    }
    else
    {
        self.titleLabel.text = @"注册成功";
    }
    
    defaultHeaderIcon = NO;
    
    DDLOG(@"%@--%@",nickName,headerIcon);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    sex = @"1";
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;

    self.headerImageView.layer.cornerRadius = 5;
    self.headerImageView.clipsToBounds = YES;
    self.headerLabel.frame = CGRectMake(self.headerLabel.frame.origin.y, self.headerImageView.frame.size.height+self.headerImageView.frame.origin.y+10, 80, 30);
    self.headerLabel.textColor = COMMENTCOLOR;
    self.nameLabel.textColor = COMMENTCOLOR;
    
    if ([headerIcon length] > 0)
    {
        [Tools fillImageView:self.headerImageView withImageFromFullURL:headerIcon andDefault:@""];
        defaultHeaderIcon = YES;
    }
    
    
    
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(102, self.nameLabel.frame.origin.y-10.5, 200, 42)];
    nameTextField.background = nil;
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.placeholder = @"15个字符以内";
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.textColor = COMMENTCOLOR;
    nameTextField.font = [UIFont systemFontOfSize:16];
    nameTextField.text = nickName;
    
    [self.sexButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
    self.sexButton.layer.cornerRadius = 5;
    self.sexButton.clipsToBounds = YES;
    [self.sexButton setTitle:@" 男" forState:UIControlStateNormal];
    self.sexButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.sexButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
    self.sexLabel.textColor = COMMENTCOLOR;
    
    self.pwdLabel.textColor = COMMENTCOLOR;
    pwdTextField = [[MyTextField alloc] initWithFrame:CGRectMake(102, self.pwdLabel.frame.origin.y-10.5, 200, 42)];
    pwdTextField.background = nil;
    pwdTextField.layer.cornerRadius = 5;
    pwdTextField.clipsToBounds = YES;
    pwdTextField.textColor = COMMENTCOLOR;
    pwdTextField.placeholder = @"密码长度不能少于6位";
    pwdTextField.backgroundColor = [UIColor whiteColor];
    pwdTextField.font = [UIFont systemFontOfSize:16];
    
    pwdTextField.secureTextEntry = YES;
    [self.startButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    
    CGFloat originY = self.sexButton.frame.size.height+self.sexButton.frame.origin.y+27;
    if ([[Tools client_token] length] > 0)
    {
        originY = pwdTextField.frame.size.height+pwdTextField.frame.origin.y+27;
    }
    else
    {
        pwdTextField.hidden = YES;
        self.pwdLabel.hidden = YES;
    }
    
    self.startButton.frame = CGRectMake(self.startButton.frame.origin.x, originY, self.sexButton.frame.size.width, self.sexButton.frame.size.height);
    
    self.headerTapTgr.numberOfTapsRequired = 1;
    [self.headerTapTgr addTarget:self action:@selector(headerTap:)];
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addGestureRecognizer:self.headerTapTgr];
    [self.bgView addSubview:self.headerLabel];
    [self.bgView addSubview:self.headerImageView];
    [self.bgView addSubview:nameTextField];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.sexButton];
    [self.bgView addSubview:self.sexImageView];
    [self.bgView addSubview:self.sexLabel];
    [self.bgView addSubview:self.pwdLabel];
    [self.bgView addSubview:pwdTextField];
    [self.bgView addSubview:self.startButton];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}
-(void)loginOutClick
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认退出", nil];
    al.tag = 1000;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 1)
        {
            [self logOut];
        }
    }
}

-(void)logOut
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]}
                                                                API:MB_LOGOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"logout== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools exit];
                WelcomeViewController *welcomeViewCOntroller = [[WelcomeViewController alloc]init];
                KKNavigationController *welNav = [[KKNavigationController alloc] initWithRootViewController:welcomeViewCOntroller];
                [self.navigationController presentViewController:welNav animated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sexClick:(id)sender
{
    [nameTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"性别选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", @"保密",nil];
    ac.tag = SEXTAG;
    [ac showInView:self.bgView];
}
- (IBAction)startClick:(id)sender
{
    if ([nameTextField.text length] == 0)
    {
        [Tools showAlertView:@"请输入您的姓名！" delegateViewController:nil];
        return;
    }
    if ([nameTextField.text length] < 2)
    {
        [Tools showAlertView:@"名字的长度应该大于1个字符" delegateViewController:nil];
        return;
    }
    
    if ([nameTextField.text length] > 15)
    {
        [Tools showAlertView:@"名字的长度应该小于15个字符" delegateViewController:nil];
        return;
    }
    
    NSString *userStr;
    if ([[APService registrationID] length] > 0)
    {
        userStr = [APService registrationID];
        //            [Tools showAlertView:userStr delegateViewController:nil];
    }
    else
    {
        userStr = @"";
    }

    
    NSDictionary *paraDict;
    NSString *url;
    if ([token length] > 0)
    {
        if([pwdTextField.text length] == 0)
        {
            [Tools showAlertView:@"请输入您的密码！" delegateViewController:nil];
            return;
        }
        if (![Tools isPassWord:pwdTextField.text])
        {
            [Tools showAlertView:@"密码由6-20位字母或数字组成" delegateViewController:nil];
            return ;
        }
        paraDict = @{@"u_id":userid,
                     @"token":token,
                     @"pwd":pwdTextField.text,
                     @"c_ver":[Tools client_ver],
                     @"d_name":[Tools device_name],
                     @"d_imei":[Tools device_uid],
                     @"c_os":[Tools device_os],
                     @"c_version":[Tools client_ver],
                     @"d_type":@"iOS",
                     @"registrationID":userStr,
                     @"r_name":nameTextField.text,
                     @"sex":sex,
                     };
        url = NEWREGIST;
    }
    else
    {
        if ([accountID length] > 0)
        {
            NSString *userStr = @"";
            if ([[APService registrationID] length] > 0)
            {
                userStr = [APService registrationID];
            }
            
            paraDict = @{@"a_id":accountID,
                         @"a_type":accountType,
                         @"c_ver":[Tools client_ver],
                         @"d_name":[Tools device_name],
                         @"d_imei":[Tools device_uid],
                         @"c_os":[Tools device_os],
                         @"d_type":@"iOS",
                         @"registrationID":userStr,
                         @"r_name":nameTextField.text,
                         @"n_name":nickName,
                         @"sex":sex,
                         @"reg":@"1"
                         };
            url = LOGINBYAUTHOR;
        }
        else
        {
            paraDict = @{@"sex":sex,
                         @"r_name":nameTextField.text,
                         @"u_id":[Tools user_id],
                         @"token":[Tools client_token]
                         };
            url = MB_SUBINFO;
        }

    }
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:url];
        
        [request setCompletionBlock:^{
            
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:nameTextField.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] setObject:sex forKey:USERSEX];
                [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"number"] forKey:BANJIANUM];
                if ([accountID length]>0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"token"] forKey:CLIENT_TOKEN];
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"u_id"] forKey:USERID];
                    
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (fullScreenImage)
                {
                    [self uploadImage:fullScreenImage];
                }
                if (defaultHeaderIcon)
                {
                    [self uploadImage:self.headerImageView.image];
                }
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
                [self.navigationController presentViewController:sideMenu animated:YES completion:^{
                    
                }];
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

- (IBAction)headerTap:(UITapGestureRecognizer *)sender
{
    [nameTextField resignFirstResponder];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    ac.tag = HEADERTAG;
    [ac showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == HEADERTAG)
    {
        imagePickerController.allowsEditing = YES;
        if (buttonIndex == 0)
        {
            //相册
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
        else if (buttonIndex == 1)
        {
            //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
            else
            {
                [Tools showAlertView:@"相机不可用" delegateViewController:nil];
            }
        }
    }
    else
    {
        if(buttonIndex == 0)
        {
            //
            sex = @"1";
            [self.sexButton setTitle:@" 男" forState:UIControlStateNormal];
        }
        else if(buttonIndex == 1)
        {
            //
            sex = @"0";
            [self.sexButton setTitle:@" 女" forState:UIControlStateNormal];
        }
        else if(buttonIndex == 2)
        {
            //
            sex = @"-1";
            [self.sexButton setTitle:@" 保密" forState:UIControlStateNormal];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    fullScreenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    fullScreenImage = [ImageTools getNormalImageFromImage:fullScreenImage];
    
    if (fullScreenImage.size.width>SCREEN_WIDTH*1.5 || fullScreenImage.size.height>SCREEN_HEIGHT*2)
    {
        CGFloat imageHeight = 0.0f;
        CGFloat imageWidth = 0.0f;
        if (fullScreenImage.size.width>SCREEN_WIDTH*1.5)
        {
            imageWidth = SCREEN_WIDTH*1.5;
            imageHeight = imageWidth*fullScreenImage.size.height/fullScreenImage.size.width;
        }
        else
        {
            imageHeight = SCREEN_HEIGHT*1.5;
            imageWidth = imageHeight*fullScreenImage.size.width/fullScreenImage.size.height;
        }
        fullScreenImage = [Tools thumbnailWithImageWithoutScale:fullScreenImage size:CGSizeMake(imageWidth, imageHeight)];
    }
    defaultHeaderIcon = NO;
    [self.headerImageView setImage:fullScreenImage];
}

-(void)uploadImage:(UIImage *)image
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if ([token length] > 0)
        {
            paraDict = @{@"u_id":userid,@"token":token,@"img_type":@"img_icon"};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":@"img_icon"};
        }
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETUSERIMAGE andParaDict:paraDict];
        
        [request setCompletionBlock:^{
            
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:HEADERIMAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
@end
