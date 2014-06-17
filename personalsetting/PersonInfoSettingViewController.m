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

@interface PersonInfoSettingViewController ()<UIScrollViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    UIImagePickerController *imagePickerController;
    
    NSString *imageUsed;
    
    UITableView *personInfoTableView;
    
    NSMutableArray *objectArray;
    
    UIView *dateView;
    UIDatePicker *datePicker;
    
    UIImage *bgImage;
    UIImage *iconImage;
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
    
    self.titleLabel.text = @"个人设置";
    
    imageUsed = @"";
    
    bgImage = nil;
    iconImage = nil;
    
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
    
    personInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    personInfoTableView.delegate = self;
    personInfoTableView.dataSource = self;
    personInfoTableView.backgroundColor = [UIColor clearColor];
    personInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    personInfoTableView.scrollEnabled = NO;
    [self.bgView addSubview:personInfoTableView];
    
    
    dateView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
    dateView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-210, SCREEN_WIDTH-100, 60)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    [dateView addSubview:datePicker];
    
    UITapGestureRecognizer *dateTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateDone)];
    dateView.userInteractionEnabled = YES;
    [dateView addGestureRecognizer:dateTgr];
    
    [self.bgView addSubview:dateView];
    
    if (![Tools user_birth])
    {
        [self getUserInfo];
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

-(void)submitChange
{
//    if (![((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:@"请选择"] && ![[((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
//    {
//        [self dateDone];
//    }
    
    
    if (!bgImage && !iconImage && [((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
    {
        [Tools showAlertView:@"没做任何更改哦！" delegateViewController:nil];
        return;
    }
    
    if (bgImage)
    {
        [self uploadImage:bgImage andkey:@"img_kb"];
    }
    if (iconImage)
    {
        [self uploadImage:iconImage andkey:@"img_icon"];
    }
    
    if ([((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]])
    {
        
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"birth":[[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10]}
                                                                API:MB_SETUSERINFO];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setusetInfo== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10] forKey:BIRTH];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [Tools showTips:@"修改成功" toView:self.bgView];
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

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if(section == 1)
    {
        return [objectArray count]+1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 13;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 46;
    }
    else if(indexPath.section == 1)
    {
        return 42;
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
    
    UITapGestureRecognizer *iconTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editInfo:)];
    cell.iconImageView.userInteractionEnabled = YES;
    [cell.iconImageView addGestureRecognizer:iconTag];
    
    cell.relateButton.frame = CGRectMake(45, 15, 40, 26);
    cell.relateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cell.relateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [cell.relateButton addTarget:self action:@selector(editInfo:) forControlEvents:UIControlEventTouchUpInside];
    cell.relateButton.tag = indexPath.row+333;
    
    cell.nametf.frame = CGRectMake(100, 15, 150, 25);
    cell.nametf.textColor = [UIColor whiteColor];
    cell.nametf.font = [UIFont systemFontOfSize:16];
    cell.nametf.enabled = NO;
    cell.nametf.textAlignment = NSTextAlignmentLeft;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [cell.relateButton setTitle:@"姓名" forState:UIControlStateNormal];
            cell.nametf.text = [Tools user_name];
            [cell.bgImageView setImage:[UIImage imageNamed:@"line1"]];
        }
        else if(indexPath.row == 1)
        {
            [cell.relateButton setTitle:@"生日" forState:UIControlStateNormal];
            cell.nametf.text = [Tools user_birth]?[Tools user_birth]:@"请选择";
            [cell.bgImageView setImage:[UIImage imageNamed:@"line1"]];
        }
        cell.nametf.tag = indexPath.row+3;
        cell.nametf.delegate = self;
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == [tableView numberOfRowsInSection:1]-1)
        {
            cell.iconImageView.hidden = YES;
            [cell.bgImageView setImage:[UIImage imageNamed:@"line2"]];
            cell.relateButton.frame = CGRectMake(18, 16, 22, 22);
            [cell.relateButton setImage:[UIImage imageNamed:@"set_add"] forState:UIControlStateNormal];
            cell.nametf.frame = CGRectMake(45, 15, 130, 26);
            [cell.nametf setText:@"添加任课科目"];
            cell.nametf.delegate = self;
            cell.nametf.tag = indexPath.row+3;
//            [cell.relateButton addTarget:self action:@selector(addTeacherObject:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [cell.bgImageView setImage:[UIImage imageNamed:@"line2"]];
            cell.relateButton.frame = CGRectMake(18, 16, 22, 22);
            [cell.relateButton setImage:[UIImage imageNamed:@"set_del"] forState:UIControlStateNormal];
            cell.relateButton.tag = indexPath.row+444;
            cell.nametf.frame = CGRectMake(45, 15, 130, 26);
            cell.nametf.tag = 3+indexPath.row;
            [cell.nametf setText:[objectArray objectAtIndex:indexPath.row]];
//            [cell.relateButton addTarget:self action:@selector(delTeacherObject:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self editInfo1:indexPath.row+333];
}

-(void)editInfo:(UITapGestureRecognizer *)tap
{
    DDLOG(@"buttontag==%d",tap.view.tag-333);
    if (tap.view.tag-333<1)
    {
//        ((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]).backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
//        ((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]).enabled = YES;
//        [((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]) becomeFirstResponder];
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
        ((UITextField *)[personInfoTableView viewWithTag:4]).text = [[NSString stringWithFormat:@"%@",datePicker.date] substringToIndex:10];
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
                NSDictionary *dataDict = [responseDict objectForKey:@"data"];
                if (![[dataDict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    if ([[dataDict objectForKey:@"img_icon"] length] > 10)
                    {
                    }
                }
                if (![[dataDict objectForKey:@"img_kb"] isEqual:[NSNull null]])
                {
                    if ([[dataDict objectForKey:@"img_kb"] length] > 10)
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[dataDict objectForKey:@"img_kb"] forKey:TOPIMAGE];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                if ([dataDict objectForKey:@"birth"])
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[dataDict objectForKey:@"birth"] forKey:BIRTH];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    ((UITextField *)[personInfoTableView viewWithTag:4]).text = [dataDict objectForKey:@"birth"];
                }
                else
                {
                    ((UITextField *)[personInfoTableView viewWithTag:4]).text = @"请选择生日";
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
        iconImage = fullScreenImage;
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
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeicon" object:nil];
                }
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
