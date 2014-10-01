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
    if ([Tools user_birth])
    {
        birth = [Tools user_birth];
    }
    else
    {
        birth = @"请设置生日";
    }
    
    userName = [Tools user_name];
    
    cellNameArray = @[@"我的头像",@"姓名",@"生日",@"性别",@"手机号"];
    
    userInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    bgImage = nil;
    headerImage = nil;
    
    db = [[OperatDB alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    objectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"保存" forState:UIControlStateNormal];
    [inviteButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
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
    DDLOG(@"birth %@",birth);
    if ( bgImage || headerImage || ![userName isEqualToString:[Tools user_name]] || (![birth isEqualToString:[Tools user_birth]] && ![birth isEqualToString:@"请设置生日"]) || ![sex isEqualToString:[Tools user_sex]])
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"你要放弃以上更改么？" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"保存", nil];
        al.tag = 1234;
        [al show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234)
    {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(buttonIndex == 1)
        {
            [self submitChange];
        }
    }
}

-(void)submitChange
{
    if (!bgImage && !headerImage && [((UITextField *)[personInfoTableView viewWithTag:4]).text isEqualToString:[Tools user_birth]] && [userName isEqualToString:[Tools user_name]])
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
    
    if([birth rangeOfString:@"设置"].length > 0)
    {
        birth = @"";
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
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"setusetInfo== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:birth forKey:BIRTH];
                [[NSUserDefaults standardUserDefaults] setObject:sex forKey:USERSEX];
                [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEHEADERICON object:nil];
                
                if (!headerImage)
                {
                    [self.navigationController popViewControllerAnimated:YES];
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
        }];
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
    cell.contentLabel.text = [cellNameArray objectAtIndex:indexPath.row];
    cell.contentLabel.font = [UIFont systemFontOfSize:15];
    cell.contentLabel.textColor = TITLE_COLOR;
    if (indexPath.row == 0)
    {
         cell.contentLabel.frame = CGRectMake(10, 12, 100, 30);
    }
    else
    {
         cell.contentLabel.frame = CGRectMake(10, 9, 100, 30);
    }
    
    
    UITapGestureRecognizer *iconTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editInfo:)];
    cell.iconImageView.userInteractionEnabled = YES;
    [cell.iconImageView addGestureRecognizer:iconTag];
    
    cell.iconImageView.hidden = YES;
    cell.nametf.hidden = YES;
    
    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 200, 10, 180, 28);
    cell.nametf.textColor = TITLE_COLOR;
    cell.nametf.textAlignment = NSTextAlignmentRight;
    cell.nametf.font = [UIFont systemFontOfSize:16];
    cell.nametf.enabled = NO;
    cell.nametf.tag = indexPath.row+3000;
    cell.nametf.delegate = self;
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(00, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 0)
    {
        cell.iconImageView.hidden = NO;
        cell.iconImageView.frame = CGRectMake(SCREEN_WIDTH-80, 7, 40, 40);
        cell.iconImageView.backgroundColor = [UIColor yellowColor];
        cell.iconImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        cell.iconImageView.clipsToBounds = YES;
        if (headerImage)
        {
            [cell.iconImageView setImage:headerImage];
        }
        else
        {
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
        if ([birth length] == 0)
        {
            cell.nametf.text = @"请设置生日";
        }
        else
        {
            cell.nametf.text = birth;
        }
    }
    else if (indexPath.row == 3)
    {
        cell.nametf.hidden = NO;
        if ([sex integerValue] == 1)
        {
            cell.nametf.text = @"男";
        }
        else if([sex integerValue] == 0)
        {
            cell.nametf.text = @"女";
        }
        else if([sex integerValue] == -1)
        {
            cell.nametf.text = @"保密";
        }
    }
    else if (indexPath.row == 4)
    {
        cell.nametf.hidden = NO;
        if ([Tools phone_num] && [[Tools phone_num] length] > 0)
        {
            cell.nametf.text = [Tools phone_num];
        }
        else
        {
            cell.nametf.text = @"尚未绑定";
        }
    }
    cell.relateButton.frame = CGRectMake(45, 15, 40, 26);
    cell.relateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cell.relateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.relateButton.tag = indexPath.row+333;
    
    if (indexPath.row < 4)
    {
        cell.arrowImageView.hidden = NO;
        if (indexPath.row == 0)
        {
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 19.5, 10, 15)];
        }
        else
        {
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 16.5, 10, 15)];
        }
        
        [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"性别选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", @"保密",nil];
        ac.tag = SEXTAG;
        [ac showInView:self.bgView];
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
    [UIView animateWithDuration:0.2 animations:^{
        DDLOG(@"birth+++%@",birth);
        NSString *day = @"";
        NSString *month = @"";
        NSString *year = @"";
        if ([birth rangeOfString:@"-"].length > 0)
        {
            day = [birth substringFromIndex:8];
            month = [birth substringWithRange:NSMakeRange(5, 2)];
            year = [birth substringToIndex:4];
        }
        else if([birth rangeOfString:@"年"].length > 0)
        {
//            NSRange range1 = [birth rangeOfString:@"日"];
            NSRange range2 = [birth rangeOfString:@"月"];
            NSRange range3 = [birth rangeOfString:@"年"];
            day = [birth substringWithRange:NSMakeRange(range2.location+1, 2)];
            month = [birth substringWithRange:NSMakeRange(range3.location+1, 2)];
            year = [birth substringToIndex:4];
        }
        if ([day length] > 0 && [month length] > 0 && [year length] > 0)
        {
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            
            NSDateComponents *dateComps = [[NSDateComponents alloc] init];
            
            [dateComps setDay:[day integerValue]];
            
            [dateComps setMonth:[month integerValue]];
            
            [dateComps setYear:[year integerValue]];
            
            NSDate *itemDate = [calendar dateFromComponents:dateComps];
            [datePicker setDate:itemDate];
        }
        
        
        dateView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
    }];
}
-(void)dateDone
{
    [UIView animateWithDuration:0.2 animations:^{
        dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年MM月dd日"];
        birth = [formatter stringFromDate:datePicker.date];
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
                    birth = [dataDict objectForKey:@"birth"];
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
    if (actionSheet.tag == SEXTAG)
    {
        if(buttonIndex == 0)
        {
            //
            sex = @"1";
        }
        else if(buttonIndex == 1)
        {
            //
            sex = @"0";
        }
        else if(buttonIndex == 2)
        {
            //
            sex = @"-1";
        }
        [personInfoTableView reloadData];
    }
    else
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
                    bgImage = nil;
                }
                else if ([imageKey isEqualToString:@"img_icon"])
                {
                    NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                    [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:HEADERIMAGE];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEHEADERICON object:nil];
                }
                if (headerImage)
                {
                    headerImage = nil;
                    [self.navigationController popViewControllerAnimated:YES];
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
    DDLOG(@"===%d",(int)textField.tag);
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-textField.tag*25);
    }];
}
@end
