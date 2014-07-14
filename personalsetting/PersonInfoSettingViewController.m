//
//  PersonSettingViewController.m
//  School
//
//  Created by TeekerZW on 14-2-15.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "PersonInfoSettingViewController.h"
#import "Header.h"
#import "UIImage+Blur.h"
#import "RelatedCell.h"
#import "OperatDB.h"
#import "EditNameViewController.h"

#define SEXTAG 6666

@interface PersonInfoSettingViewController ()<UIScrollViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
EditNameDone>
{
    UIImagePickerController *imagePickerController;
    
    NSString *imageUsed;
    
    UITableView *personInfoTableView;
    
    NSMutableArray *objectArray;
    
    NSArray *cellNameArray;
    
    UIView *dateView;
    UIDatePicker *datePicker;
    
    UIImage *bgImage;
    UIImage *iconImage;
    OperatDB *db;
    
    NSString *sex;
    NSString *birth;
    UIImage *headerImage;
    
    NSString *userName;
    
    NSString *uidNum;
    
    NSMutableDictionary *userInfoDict;
    
    UIButton *dateDoneButton;
    UIButton *dateCancelButton;
}
@end

@implementation PersonInfoSettingViewController

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
    
    self.titleLabel.text = @"我";
    
    imageUsed = @"";
    sex = [Tools user_sex];
    birth = [Tools user_birth];
    userName = [Tools user_name];
    
    if ([[Tools header_image] isKindOfClass:[NSString class]])
    {
        headerImage = [UIImage imageNamed:[Tools header_image]];
    }
    
    cellNameArray = @[@"我的头像",@"姓名",@"生日",@"性别",@"手机号"];
    
    userInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    bgImage = nil;
    iconImage = nil;
    
    db = [[OperatDB alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    objectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"保存" forState:UIControlStateNormal];
    [inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(submitChange) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    personInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+14, SCREEN_WIDTH, 243) style:UITableViewStylePlain];
    personInfoTableView.delegate = self;
    personInfoTableView.dataSource = self;
    personInfoTableView.backgroundColor = [UIColor whiteColor];
    personInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    personInfoTableView.scrollEnabled = NO;
    [self.bgView addSubview:personInfoTableView];
    
    
    dateView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
    dateView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-210, SCREEN_WIDTH-100, 150)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    [dateView addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.frame = CGRectMake(0, SCREEN_HEIGHT-290, SCREEN_WIDTH, 45);
    [dateView addSubview:toolBar];
    
    UIImage *btnBgImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    dateCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dateCancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [dateCancelButton setBackgroundImage:btnBgImage forState:UIControlStateNormal];
    [dateCancelButton addTarget:self action:@selector(dateCancel) forControlEvents:UIControlEventTouchUpInside];
    dateCancelButton.frame = CGRectMake(10, 5, 60, 35);
    
    [toolBar addSubview:dateCancelButton];
    
    dateDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dateDoneButton setTitle:@"完成" forState:UIControlStateNormal];
    [dateDoneButton setBackgroundImage:btnBgImage forState:UIControlStateNormal];
    [dateDoneButton addTarget:self action:@selector(dateDone) forControlEvents:UIControlEventTouchUpInside];
    dateDoneButton.frame = CGRectMake(SCREEN_WIDTH-70, 5, 60, 35);
    [toolBar addSubview:dateDoneButton];
    
    
    UITapGestureRecognizer *dateTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateCancel)];
    dateView.userInteractionEnabled = YES;
    [dateView addGestureRecognizer:dateTgr];
    
    [self.bgView addSubview:dateView];
    
    [self getUserInfo];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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

-(void)submitChange
{
//    if (![((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:@"请选择"] && ![[((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
//    {
//        [self dateDone];
//    }
    
    [self dateDone];
    if (!bgImage && !iconImage && [((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
    {
        [Tools showAlertView:@"没做任何更改哦！" delegateViewController:nil];
        return;
    }
    
    if (bgImage)
    {
        [self uploadImage:bgImage andkey:@"img_kb"];
    }
    if (headerImage)
    {
        [self uploadImage:headerImage andkey:@"img_icon"];
    }
    
    if ([((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
    {
        
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"birth":birth,
                                                                      @"sex":sex,
                                                                      @"r_name":userName}
                                                                API:MB_SETUSERINFO];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setusetInfo== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10] forKey:BIRTH];
                [[NSUserDefaults standardUserDefaults] setObject:sex forKey:USERSEX];
                [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEHEADERICON object:nil];
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

#pragma mark - tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 54;
    }
    else
    {
        return 48;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *personInfoCell = @"personInfoCell";
    RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:personInfoCell];
    if (cell == nil)
    {
        cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personInfoCell];
    }
    cell.iconImageView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [cellNameArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = TITLE_COLOR;
    
    UITapGestureRecognizer *iconTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editInfo:)];
    cell.iconImageView.userInteractionEnabled = YES;
    [cell.iconImageView addGestureRecognizer:iconTag];
    cell.iconImageView.hidden = YES;
    cell.nametf.hidden = YES;
    
    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 180, 10, 150, 28);
    cell.nametf.textColor = TITLE_COLOR;
    cell.nametf.textAlignment = NSTextAlignmentRight;
    cell.nametf.font = [UIFont systemFontOfSize:16];
    cell.nametf.enabled = NO;
    cell.nametf.tag = indexPath.row+3000;
    cell.nametf.delegate = self;
    
    if (indexPath.row == 0)
    {
        cell.iconImageView.hidden = NO;
        cell.iconImageView.frame = CGRectMake(SCREEN_WIDTH-80, 7, 40, 40);
        cell.iconImageView.backgroundColor = [UIColor yellowColor];
        if (headerImage)
        {
            [cell.iconImageView setImage:headerImage];
        }
        else
        {
//            [SetImageTools fillHeaderImage:cell.iconImageView withUserid:[Tools user_id] imageType:@"img_icon" defultImage:HEADERICON];
            [Tools fillImageView:cell.iconImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        }
        UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectoo)];
        cell.iconImageView.userInteractionEnabled = YES;
        [cell.iconImageView addGestureRecognizer:iconTap];
    }
    else if(indexPath.row == 1)
    {
        cell.nametf.hidden = NO;
        
        if ([userName length] > 0)
        {
            cell.nametf.text = userName;
        }
        else
        {
            cell.nametf.text = @"";
        }
        
    }
    else if(indexPath.row == 2)
    {
        cell.nametf.hidden = NO;
        if (birth)
        {
            cell.nametf.text = birth;
        }
        else
        {
            cell.nametf.text = @"请设置生日";
        }
        
    }
    else if (indexPath.row == 3)
    {
        cell.nametf.hidden = NO;
        if ([sex integerValue] == 1)
        {
            cell.nametf.text = @"男";
        }
        else
        {
            cell.nametf.text = @"女";
        }
    }
    else if (indexPath.row == 4)
    {
        cell.nametf.hidden = NO;
        cell.nametf.text = [Tools phone_num];
    }
    cell.relateButton.frame = CGRectMake(45, 15, 40, 26);
    cell.relateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cell.relateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.relateButton.tag = indexPath.row+333;
    
    [cell.bgImageView setImage:[UIImage imageNamed:@"line3"]];
    
    if (indexPath.row < 4)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        //头像
        [self selectoo];
    }
    else if (indexPath.row == 1)
    {
        //姓名
        EditNameViewController *editNameViewController = [[EditNameViewController alloc] init];
        editNameViewController.name = userName;
        editNameViewController.editnameDoneDel = self;
        [self.navigationController pushViewController:editNameViewController animated:YES];
        
    }
    else if (indexPath.row == 2)
    {
        //生日
        [self editInfo1:indexPath.row+333];
    }
    else if (indexPath.row == 3)
    {
        //性别
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女", nil];
        al.tag = SEXTAG;
        [al show];
        
    }
    else if (indexPath.row == 3)
    {
        //手机号
        
    }
    
}

-(void)editNameDone:(NSString *)name
{
    userName = name;
    [personInfoTableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SEXTAG)
    {
        if (buttonIndex ==1)
        {
            sex = @"1";
        }
        else if(buttonIndex == 2)
        {
            sex = @"0";
        }
        [personInfoTableView reloadData];
    }
}


-(void)editInfo:(UITapGestureRecognizer *)tap
{
    if (tap.view.tag-333<1)
    {
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            dateView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
        }];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for(UIView *v in personInfoTableView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            [v resignFirstResponder];
        }
    }
}

-(void)editInfo1:(NSInteger)tag
{
    DDLOG(@"buttontag==%d",tag-333);
    if (tag-333<1)
    {
//        ((UITextField *)[personInfoTableView viewWithTag:tag-330]).backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
//        ((UITextField *)[personInfoTableView viewWithTag:tag-330]).enabled = YES;
//        [((UITextField *)[personInfoTableView viewWithTag:tag-330]) becomeFirstResponder];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            dateView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
        }];
    }
}
-(void)dateDone
{
    DDLOG(@"%@",[[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10]);
    [UIView animateWithDuration:0.2 animations:^{
        dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        birth = [[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10];
        [personInfoTableView reloadData];
    }];
}
-(void)dateCancel
{
    [UIView animateWithDuration:0.2 animations:^{
        dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    }];
}

#pragma mark - getUserInfo
-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":[Tools user_id]
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[db findSetWithDictionary:@{@"userid":[Tools user_id]} andTableName:USERINFO] count] > 0)
                {
                    if ([db deleteRecordWithDict:@{@"userid":[Tools user_id]} andTableName:USERINFO])
                    {
                        DDLOG(@"delete user info success!");
                    }
                }
                
                NSDictionary *dataDict = [responseDict objectForKey:@"data"];
                [userInfoDict setObject:[Tools user_id] forKey:@"userid"];
                
                if (![[dataDict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    if ([[dataDict objectForKey:@"img_icon"] isKindOfClass:[NSString class]])
                    {
                        [userInfoDict setObject:[dataDict objectForKey:@"img_icon"] forKey:@"img_icon"];
                    }
//                    else
//                    {
//                        uidNum = [NSString stringWithFormat:@"%d",[[dataDict objectForKey:@"img_icon"] integerValue]];
//                    }
                }
                
                if (![[dataDict objectForKey:@"img_kb"] isEqual:[NSNull null]])
                {
                    if ([[dataDict objectForKey:@"img_kb"] isKindOfClass:[NSString class]])
                    {
                        [userInfoDict setObject:[dataDict objectForKey:@"img_kb"] forKey:@"img_kb"];
                    }
                }
                
                if ([dataDict objectForKey:@"birth"])
                {
                    [userInfoDict setObject:[dataDict objectForKey:@"birth"] forKey:@"birth"];
                }
                else
                {
                    ((UITextField *)[personInfoTableView viewWithTag:3002]).text = @"请设置生日";
                }
                
                if ([[dataDict objectForKey:@"classes"] isKindOfClass:[NSDictionary class]])
                {
                    [userInfoDict setObject:[dataDict objectForKey:@"classes"] forKey:@"classes"];
                }
                
                if ([dataDict objectForKey:@"sex"])
                {
                    [userInfoDict setObject:[dataDict objectForKey:@"sex"] forKey:@"sex"];
                }
                if ([db insertRecord:userInfoDict andTableName:USERINFO])
                {
                    DDLOG(@"insert userinfo success!");
                }
                 [personInfoTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }

}

-(void)changeTopImage
{
    imageUsed = @"img_kb";
    [self selectoo];
}
-(void)changeHeaderImage
{
    imageUsed = @"img_icon";
    [self selectoo];
}

-(void)selectoo
{
    imageUsed = @"img_icon";
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    [ac showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self selectPicture:1001];
    }
    else if(buttonIndex == 1)
    {
        [self selectPicture:1000];
    }
}

-(void)selectPicture:(NSInteger)selectIndex
{
    imagePickerController.allowsEditing = YES;
    if (selectIndex == 1000)
    {
        //拍照
        if ([Tools captureEnable])
        {
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
    else if(selectIndex == 1001)
    {
        //相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *fullScreenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (fullScreenImage.size.width>SCREEN_WIDTH*2 || fullScreenImage.size.height>SCREEN_HEIGHT*2)
    {
        CGFloat imageHeight = 0.0f;
        CGFloat imageWidth = 0.0f;
        if (fullScreenImage.size.width>SCREEN_WIDTH*2)
        {
            imageWidth = SCREEN_WIDTH*2;
            imageHeight = imageWidth*fullScreenImage.size.height/fullScreenImage.size.width;
        }
        else
        {
            imageHeight = SCREEN_HEIGHT*2;
            imageWidth = imageHeight*fullScreenImage.size.width/fullScreenImage.size.height;
        }
        fullScreenImage = [Tools thumbnailWithImageWithoutScale:fullScreenImage size:CGSizeMake(imageWidth, imageHeight)];
    }
    if ([imageUsed isEqualToString:@"img_kb"])
    {
        bgImage = fullScreenImage;
    }
    else if([imageUsed isEqualToString:@"img_icon"])
    {
        headerImage = fullScreenImage;
        [personInfoTableView reloadData];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadImage:(UIImage *)image andkey:(NSString *)imageKey
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETUSERIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":imageKey}];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([imageKey isEqualToString:@"img_kb"])
                {
                    NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                    [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:TOPIMAGE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else if ([imageKey isEqualToString:@"img_icon"])
                {
                    NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                    [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:HEADERIMAGE];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEHEADERICON object:nil];
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

#pragma mark - textfield
- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    int height = keyboardRect.size.height;

    [UIView animateWithDuration:0.25 animations:^{
//        if (iPhone5)
//        {
//            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+100);
//        }
//        else
//        {
//            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+50);
//        }

    }completion:^(BOOL finished) {
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == [personInfoTableView numberOfRowsInSection:0]+[personInfoTableView numberOfRowsInSection:1]-1)
    {
        if([[textField text] length]>0 && ![[textField text] isEqualToString:@"添加任课科目"])
        {
            [objectArray addObject:textField.text];
            [personInfoTableView reloadData];
            personInfoTableView.contentOffset = CGPointMake(0, personInfoTableView.contentSize.height-personInfoTableView.frame.size.height);
        }
    }
    textField.backgroundColor = [UIColor clearColor];
    [personInfoTableView reloadData];
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    DDLOG(@"===%d",textField.tag);
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-textField.tag*25);
    }];
}
@end
