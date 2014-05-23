//
//  ClassInfoViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/12/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ClassInfoViewController.h"
#import "XDTabViewController.h"
#import "PersonalSettingCell.h"
#import "MoreViewController.h"
#import "SetClassInfoViewController.h"


#define MOREACTIONSHEETTAG    1000
#define TAKEPICTURETAG        2000

#define HEADERIMAGETAG        3000
#define TOPIMAGETAG           4000

#define TOP_HEIGHT      120
@interface ClassInfoViewController ()<
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
SetClassInfoDel>
{
    UIImageView *topicImageView;
    UIImageView *headerImageView;
    UIImagePickerController *imagePickerController;
    
    NSString *imageUsed;
    
    UITableView *classInfoTableView;
    
    UIView *dateView;
    UIImage *bgImage;
    UIImage *iconImage;
    
    NSString *classInfo;
    
    NSString *schoolID;
    NSString *schoolName;
    NSString *classID;
    NSString *className;
    
    NSString *regionStr;
}
@end

@implementation ClassInfoViewController
@synthesize signOutDel;
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
    
    self.titleLabel.text = @"班级信息";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    classInfo = @"";
    regionStr = @"";
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    topicImageView.backgroundColor = [UIColor whiteColor];
    topicImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    topicImageView.clipsToBounds = YES;
    [topicImageView setImage:[UIImage imageNamed:@"toppic.jpg"]];

    
    UITapGestureRecognizer *topGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTopImage)];
    topicImageView.userInteractionEnabled = YES;
    [topicImageView addGestureRecognizer:topGestureRecognizer];
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, -40, 80, 80)];
    headerImageView.backgroundColor = [UIColor whiteColor];
    headerImageView.layer.cornerRadius = 10;
    [headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerImageView.layer.borderWidth = 2;
    headerImageView.layer.masksToBounds = YES;
    
    
    UITapGestureRecognizer *headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeaderImage)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:headerGestureRecognizer];

    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    classInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,UI_NAVIGATION_BAR_HEIGHT , SCREEN_WIDTH, SCREEN_HEIGHT-UI_TAB_BAR_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classInfoTableView.delegate = self;
    classInfoTableView.dataSource = self;
    classInfoTableView.backgroundColor = [UIColor clearColor];
    classInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classInfoTableView];
    
    classInfoTableView.contentInset = UIEdgeInsetsMake(TOP_HEIGHT+40, 0, 0, 0);
    
    [classInfoTableView addSubview:topicImageView];
    [classInfoTableView addSubview:headerImageView];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![[ud objectForKey:@"classkbimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classkbimage"] length] > 10)
    {
        [Tools fillImageView:topicImageView withImageFromURL:[[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"] andDefault:@""];
    }
    else
    {
        [topicImageView setImage:[UIImage imageNamed:@"toppic.jpg"]];
    }
    
    if (![[ud objectForKey:@"classiconimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classiconimage"] length] > 10)
    {
        [Tools fillImageView:headerImageView withImageFromURL:[[NSUserDefaults standardUserDefaults] objectForKey:@"classiconimage"] andDefault:@""];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    }

    
    [self getClassInfo];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unShowSelfViewController
{
    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - aboutNotification
-(void)updateClassInfo:(NSString *)infoKey value:(NSString *)infoValue
{
    if ([infoKey isEqualToString:@"name"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:infoValue forKey:@"classname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([infoKey isEqualToString:@"info"])
    {
        classInfo = infoValue;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeClassInfo" object:nil];
    [classInfoTableView reloadData];
}

#pragma mark - tableview

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -TOP_HEIGHT) {
        CGRect f = topicImageView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset;
        topicImageView.frame = f;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < 3)
    {
        if (indexPath.row == 0)
        {
            NSString *classNamestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            CGSize classNameSize = [Tools getSizeWithString:classNamestr andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
            return classNameSize.height>20?(classNameSize.height+70):90;
        }
        else if (indexPath.row == 1)
        {
            CGSize schoolNameSize = [Tools getSizeWithString:schoolName andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
            return schoolNameSize.height>20?(schoolNameSize.height+20):40;
        }
        return 40;
    }
    else
    {
        CGSize size = [Tools getSizeWithString:classInfo andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
        return size.height+20>40?(size.height+20):40;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classInfoCell = @"classInfoCell";
    PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:classInfoCell];
    if (cell == nil)
    {
        cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classInfoCell];
    }
    cell.headerImageView.hidden = YES;
    cell.nameLabel.font = [UIFont systemFontOfSize:15];
    cell.objectsLabel.font = [UIFont systemFontOfSize:15];
    cell.objectsLabel.numberOfLines = 10;
    cell.objectsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    if (indexPath.row < 3)
    {
        cell.nameLabel.frame = CGRectMake(10, 10, 80, 20);
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = @"班级名称";
            cell.nameLabel.frame = CGRectMake(10, 60, 80, 20);
            NSString *classNamestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            CGSize classNameSize = [Tools getSizeWithString:classNamestr andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
            cell.objectsLabel.frame = CGRectMake(100, 60, SCREEN_WIDTH-150, classNameSize.height);
            cell.objectsLabel.text = classNamestr;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
            {
                cell.authenticationSign.frame = CGRectMake(SCREEN_WIDTH-20, 60, 10, 20);
                [cell.authenticationSign setImage:[UIImage imageNamed:@"icon_angle"]];

            }
        }
        else if(indexPath.row == 1)
        {
            schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
            CGSize schoolNameSize = [Tools getSizeWithString:schoolName andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
            cell.objectsLabel.frame = CGRectMake(100, 10, SCREEN_WIDTH-130, schoolNameSize.height);
            
            cell.nameLabel.text = @"学校名称";
            cell.objectsLabel.text = schoolName;
        }
        else if(indexPath.row == 2)
        {
            cell.nameLabel.text = @"地区";
            cell.objectsLabel.frame = CGRectMake(100, 10, SCREEN_WIDTH-150, 20);
            cell.objectsLabel.text = regionStr;
        }
        
    }
    else if(indexPath.row == 3)
    {
        CGSize size = [Tools getSizeWithString:classInfo andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
        cell.nameLabel.frame = CGRectMake(10, 10, 80, 20);
        cell.objectsLabel.frame = CGRectMake(100, 10, SCREEN_WIDTH-150, size.height>20?size.height:20);
        cell.nameLabel.text = @"班级介绍";
        if ([classInfo length] > 0)
        {
            cell.objectsLabel.text = classInfo;
            cell.objectsLabel.numberOfLines = 10;
        }
        else
        {
            cell.objectsLabel.text = @"请填写班级介绍";
        }
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 60, 10, 20)];
        }
    }
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
    cell.backgroundView = bgImageBG;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            SetClassInfoViewController *setClassInfoViewController = [[SetClassInfoViewController alloc] init];
            setClassInfoViewController.infoKey = @"name";
            setClassInfoViewController.infoStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            setClassInfoViewController.classID = classID;
            setClassInfoViewController.setClassInfoDel = self;
            [[XDTabViewController sharedTabViewController] .navigationController pushViewController:setClassInfoViewController animated:YES];
        }
    }
    else if(indexPath.row == 3)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            SetClassInfoViewController *setClassInfoViewController = [[SetClassInfoViewController alloc] init];
            setClassInfoViewController.infoKey = @"info";
            setClassInfoViewController.infoStr = classInfo;
            setClassInfoViewController.setClassInfoDel = self;
            [[XDTabViewController sharedTabViewController] .navigationController pushViewController:setClassInfoViewController animated:YES];
        }
    }
}

-(void)moreClick
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        UIActionSheet *moreAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"班级设置", nil];
        moreAction.tag = MOREACTIONSHEETTAG;
        [moreAction showInView:self.bgView];
    }
    else
    {
        UIActionSheet *moreAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出班级", nil];
        moreAction.tag = MOREACTIONSHEETTAG;
        [moreAction showInView:self.bgView];
    }
}

-(void)signOut
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出这个班级吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = 2222;
    [al show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2222)
    {
        if (buttonIndex == 1)
        {
            [self signoutclass];
        }
    }
    else if (alertView.tag == HEADERIMAGETAG)
    {
        if (buttonIndex == 1)
        {
            [self uploadImage:iconImage andkey:@"img_icon"];
        }
    }
    else if(alertView.tag == TOPIMAGETAG)
    {
        if (buttonIndex == 1)
        {
            [self uploadImage:bgImage andkey:@"img_kb"];
        }
    }
}

-(void)signoutclass
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"role":[[NSUserDefaults standardUserDefaults] objectForKey:@"role"],
                                                                      @"c_id":classID
                                                                      } API:SIGNOUTCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"signout responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.signOutDel respondsToSelector:@selector(signOutClass:)])
                {
                    [self.signOutDel signOutClass:YES];
                }
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
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MOREACTIONSHEETTAG)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                //班级设置
                MoreViewController *more = [[MoreViewController alloc] init];
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:more animated:YES];
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                //退出班级
                [self signOut];
            }
        }
    }
    else if(actionSheet.tag == TAKEPICTURETAG)
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
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] < 2)
    {
        return ;
    }
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    ac.tag = TAKEPICTURETAG;
    [ac showInView:self.bgView];
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
                [[XDTabViewController sharedTabViewController] presentViewController:imagePickerController animated:YES completion:nil];
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
            [[XDTabViewController sharedTabViewController] presentViewController:imagePickerController animated:YES completion:nil];
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
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"确定更换班级背景图片吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = TOPIMAGETAG;
        [al show];
    }
    else if([imageUsed isEqualToString:@"img_icon"])
    {
        iconImage = fullScreenImage;
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"确定要更换班级头像吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = HEADERIMAGETAG;
        [al show];
    }
}

#pragma mark - imagePicker

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadImage:(UIImage *)image andkey:(NSString *)imageKey
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETCLASSIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"c_id":classID,@"img_type":imageKey}];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([imageKey isEqualToString:@"img_kb"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeClassInfo" object:nil];
                    
                    [[NSUserDefaults standardUserDefaults]  setObject:[[responseDict objectForKey:@"data"] objectForKey:@"files"] forKey:@"classkbimage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [topicImageView setImage:image];
                    
                }
                else if ([imageKey isEqualToString:@"img_icon"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeClassInfo" object:nil];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"files"] forKey:@"classiconimage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [headerImageView setImage:image];
                }
                [classInfoTableView reloadData];
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

-(void)getClassInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:CLASSINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"img_icon"] length] > 10)
                {
                    [Tools fillImageView:((UIImageView *)[classInfoTableView viewWithTag:2222]) withImageFromURL:[[responseDict objectForKey:@"data"] objectForKey:@"img_icon"] andDefault:@"toppic.jpg"];
                }
                else
                {
                    [headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"img_kb"] length] > 10)
                {
                    [Tools fillImageView:((UIImageView *)[classInfoTableView viewWithTag:3333]) withImageFromURL:[[responseDict objectForKey:@"data"] objectForKey:@"img_kb"] andDefault:@"toppic.jpg"];
                }
                else
                {
                    [topicImageView setImage:[UIImage imageNamed:@"toppic.jpg"]];
                }
                if ([[responseDict objectForKey:@"data"] objectForKey:@"info"])
                {
                    classInfo = [[responseDict objectForKey:@"data"] objectForKey:@"info"];
                }
                
                regionStr = [[[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"region"] objectForKey:@"name"];
                [classInfoTableView reloadData];
                
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
