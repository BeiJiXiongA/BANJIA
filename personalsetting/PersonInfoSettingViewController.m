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
    UIImageView *topicImageView;
    UIImageView *headerImageView;
    UIImagePickerController *imagePickerController;
    
    NSString *imageUsed;
    
    NSMutableArray *imageArray;
    
    UITableView *personInfoTableView;
    
    NSMutableArray *objectArray;
    
    UIView *dateView;
    UIDatePicker *datePicker;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    objectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"保存" forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(submitChange) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *topImage = [UIImage imageNamed:@"toppic.jpg"];
    topImage = [topImage blurredImage:2];
    
    topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 113)];
    topicImageView.backgroundColor = [UIColor whiteColor];
    topicImageView.image = topImage;
    [self.bgView addSubview:topicImageView];
    
    UITapGestureRecognizer *topGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTopImage)];
    topicImageView.userInteractionEnabled = YES;
    [topicImageView addGestureRecognizer:topGestureRecognizer];
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, UI_NAVIGATION_BAR_HEIGHT + 69, 88, 88)];
    headerImageView.backgroundColor = [UIColor whiteColor];
    headerImageView.layer.cornerRadius = 44;
    headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerImageView.layer.borderWidth = 3;
    [Tools fillImageView:headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERDEFAULT];
    headerImageView.layer.masksToBounds = YES;
    headerImageView.image = [UIImage imageNamed:@"headpic"];
    
    
    UITapGestureRecognizer *headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeaderImage)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:headerGestureRecognizer];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topicImageView.frame.size.height+topicImageView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT-topicImageView.frame.size.height-UI_NAVIGATION_BAR_HEIGHT)];
    [bgImageView  setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self.bgView addSubview:bgImageView];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    personInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topicImageView.frame.size.height+topicImageView.frame.origin.y+43, SCREEN_WIDTH, SCREEN_HEIGHT-topicImageView.frame.size.height-UI_NAVIGATION_BAR_HEIGHT-70) style:UITableViewStylePlain];
    personInfoTableView.delegate = self;
    personInfoTableView.dataSource = self;
    personInfoTableView.backgroundColor = [UIColor clearColor];
    personInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:personInfoTableView];
    
    
    dateView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
    dateView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-210, SCREEN_WIDTH-100, 60)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    [dateView addSubview:datePicker];
    
    UITapGestureRecognizer *dateTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateDone)];
    dateView.userInteractionEnabled = YES;
    [dateView addGestureRecognizer:dateTgr];
    
    [self.bgView addSubview:headerImageView];
    [self.bgView addSubview:dateView];
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submitChange
{
    DDLOG(@"====%@",((UITextField *)[personInfoTableView viewWithTag:3]).text);
    DDLOG(@"====%@",((UITextField *)[personInfoTableView viewWithTag:4]).text);
//    DDLOG(@"====%@",((UITextField *)[personInfoTableView viewWithTag:5]).text);
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
    cell.iconImageView.frame = CGRectMake(18, 16, 22, 22);
    cell.iconImageView.backgroundColor = [UIColor clearColor];
    [cell.iconImageView setImage:[UIImage imageNamed:@"set_del"]];
    cell.iconImageView.tag = indexPath.row+333;
    
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
//        else if(indexPath.row == 1)
//        {
//            [cell.relateButton setTitle:@"电话" forState:UIControlStateNormal];
//            cell.nametf.text = [Tools phone_num];
//            [cell.bgImageView setImage:[UIImage imageNamed:@"line1"]];
//        }
        else if(indexPath.row == 1)
        {
            [cell.relateButton setTitle:@"生日" forState:UIControlStateNormal];
            cell.nametf.text = @"请选择";
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

-(void)editInfo:(UITapGestureRecognizer *)tap
{
    DDLOG(@"buttontag==%d",tap.view.tag-333);
    if (tap.view.tag-333<1)
    {
        ((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]).backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
        ((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]).enabled = YES;
        [((UITextField *)[personInfoTableView viewWithTag:tap.view.tag-330]) becomeFirstResponder];
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
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dataDict = [responseDict objectForKey:@"data"];
                if (![[dataDict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    [Tools fillImageView:headerImageView withImageFromURL:[dataDict objectForKey:@"img_icon"] andDefault:@"head_pic.jpg"];
                }
                if (![[dataDict objectForKey:@"img_kb"] isEqual:[NSNull null]])
                {
                    [Tools fillImageView:topicImageView withImageFromURL:[dataDict objectForKey:@"img_kb"] andDefault:@"toppic.jpg"];
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
    DDLOG(@"used=%@",imageUsed);
    [self selectoo];
}
-(void)changeHeaderImage
{
    imageUsed = @"img_icon";
    DDLOG(@"used=%@",imageUsed);
    [self selectoo];
}

-(void)selectoo
{
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    [ac showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"====%d",buttonIndex);
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
    if (selectIndex == 1000)
    {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:imagePickerController animated:YES];
        }
        else
        {
            [Tools showAlertView:@"相机不可用" delegateViewController:nil];
        }
    }
    else if(selectIndex == 1001)
    {
        //相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:imagePickerController animated:YES];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imageArray removeAllObjects];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *fullScreenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
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
        DDLOG(@"%.1f==%.1f++%.1f==%.1f",imageWidth,imageHeight,fullScreenImage.size.width,fullScreenImage.size.height);
        fullScreenImage = [Tools thumbnailWithImageWithoutScale:fullScreenImage size:CGSizeMake(imageWidth, imageHeight)];
    }
    [imageArray addObject:fullScreenImage];
    [self uploadImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadImage
{
    if ([Tools NetworkReachable])
    {
        UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] init];
        if ([imageUsed isEqualToString:@"img_kb"])
        {
            indi.frame = CGRectMake(topicImageView.frame.origin.x+topicImageView.frame.size.width/2-20, topicImageView.frame.origin.y+topicImageView.frame.size.height/2-20, 40, 40);
        }
        else if([imageUsed isEqualToString:@"img_icon"])
        {
            indi.frame = CGRectMake(headerImageView.frame.origin.x+headerImageView.frame.size.width/2-20, headerImageView.frame.origin.y+headerImageView.frame.size.height/2-20, 40, 40);
        }

        __weak ASIHTTPRequest *request = [Tools upLoadImages:imageArray withSubURL:SETUSERIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":imageUsed}];
        [request setCompletionBlock:^{
            [indi stopAnimating];
            [indi removeFromSuperview];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([imageUsed isEqualToString:@"img_kb"])
                {
                    [topicImageView setImage:[imageArray firstObject]];
                }
                else if ([imageUsed isEqualToString:@"img_icon"])
                {
                    [headerImageView setImage:[imageArray firstObject]];
                    NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                    [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:HEADERIMAGE];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
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
            [indi stopAnimating];
            [indi removeFromSuperview];
        }];
        [indi startAnimating];
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
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;

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
