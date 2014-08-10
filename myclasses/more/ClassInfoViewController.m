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

#import "SetClassInfoViewController.h"
#import "SearchSchoolViewController.h"
#import "ClassQRViewController.h"


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
    NSString *schoolLevel;
    NSString *classNumber;
    NSString *regionStr;
    
    NSArray *schoolLevelArray;
    
    BOOL first;
}
@end

@implementation ClassInfoViewController
@synthesize signOutDel,classinfoDict;
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
    classInfo = @"";
    regionStr = @"";
    
    first = YES;
    
    schoolLevelArray = SCHOOLLEVELARRAY;
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getClassInfo) name:CHANGECLASSINFO object:nil];
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    
    topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    topicImageView.backgroundColor = [UIColor whiteColor];
    topicImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    topicImageView.clipsToBounds = YES;
    [topicImageView setImage:[UIImage imageNamed:@"toppic"]];
    
    UILabel *classNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, -60, 200, 20)];
    classNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classNameLabel.backgroundColor = [UIColor clearColor];
    classNameLabel.textColor = [UIColor whiteColor];
    classNameLabel.font = [UIFont systemFontOfSize:18];
    classNameLabel.shadowColor = TITLE_COLOR;
    classNameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    
    UILabel *schoolNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, -34, 200, 20)];
    schoolNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolNameLabel.backgroundColor = [UIColor clearColor];
    schoolNameLabel.textColor = [UIColor whiteColor];
    schoolNameLabel.font = [UIFont systemFontOfSize:16];
    schoolNameLabel.shadowColor = TITLE_COLOR;
    schoolNameLabel.shadowOffset = CGSizeMake(0.5, 0.5);

    
    UITapGestureRecognizer *topGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTopImage)];
    topicImageView.userInteractionEnabled = YES;
    [topicImageView addGestureRecognizer:topGestureRecognizer];
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, -65, 53, 53)];
    headerImageView.backgroundColor = [UIColor whiteColor];
    headerImageView.layer.cornerRadius = 5;
    [headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerImageView.layer.borderWidth = 2;
    headerImageView.layer.masksToBounds = YES;
    
    
    UITapGestureRecognizer *headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeaderImage)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:headerGestureRecognizer];

    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    classInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,UI_NAVIGATION_BAR_HEIGHT , SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classInfoTableView.delegate = self;
    classInfoTableView.dataSource = self;
    classInfoTableView.backgroundColor = [UIColor clearColor];
    classInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classInfoTableView];
    
    classInfoTableView.contentInset = UIEdgeInsetsMake(TOP_HEIGHT+30, 0, 0, 0);
    
    [classInfoTableView addSubview:topicImageView];
    [classInfoTableView addSubview:headerImageView];
    [classInfoTableView addSubview:classNameLabel];
    [classInfoTableView addSubview:schoolNameLabel];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![[ud objectForKey:@"classkbimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classkbimage"] length] > 10)
    {
        [Tools fillImageView:topicImageView withImageFromURL:[[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"] andDefault:@""];
    }
    else
    {
        [topicImageView setImage:[UIImage imageNamed:@"toppic"]];
    }
    
    if (![[ud objectForKey:@"classiconimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classiconimage"] length] > 10)
    {
        [Tools fillImageView:headerImageView withImageFromURL:[[NSUserDefaults standardUserDefaults] objectForKey:@"classiconimage"] andDefault:@"headpic.jpg"];
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
    [self.navigationController popViewControllerAnimated:YES];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
    [classInfoTableView reloadData];
}

#pragma mark - tableview

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (first)
    {
        CGFloat yOffset  = scrollView.contentOffset.y;
        if (yOffset < -TOP_HEIGHT)
        {
            CGRect f = topicImageView.frame;
            f.origin.y = yOffset;
            f.size.height =  -yOffset;
            topicImageView.frame = f;
        }
        first = NO;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < 6)
    {
        return 47;
    }
    else
    {
        CGSize size = [Tools getSizeWithString:classInfo andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
        return size.height+20>40?(size.height+20+30):(40+30);
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
    cell.authenticationSign.hidden = YES;
    cell.nameLabel.textColor = CONTENTCOLOR;
    cell.nameLabel.font = [UIFont systemFontOfSize:15];
    cell.objectsLabel.font = [UIFont systemFontOfSize:15];
    cell.objectsLabel.textColor = COMMENTCOLOR;
    cell.objectsLabel.numberOfLines = 10;
    cell.objectsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.objectsLabel.textAlignment = NSTextAlignmentRight;
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat left = 210;
    if (indexPath.row < 6)
    {
        cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = @"我的身份";
            cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
            
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-220, 10, 180,27);
            NSString *role = [[NSUserDefaults standardUserDefaults] objectForKey:@"role"];
            if ([role isEqualToString:@"students"])
            {
                cell.objectsLabel.text = @"学生";
            }
            else if ([role isEqualToString:@"teachers"])
            {
                cell.objectsLabel.text = @"老师";
            }
            else if ([role isEqualToString:@"parents"])
            {
                cell.objectsLabel.text = @"家长";
            }
        }
        else if (indexPath.row == 1)
        {
            cell.nameLabel.text = @"班级名称";
            cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
            NSString *classNamestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left, 10, 180, 27);
            cell.objectsLabel.text = classNamestr;
        }
        else if(indexPath.row == 2)
        {
            cell.nameLabel.text = @"班      号";
            cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
            
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left-40, 10, 180, 27);
            
            cell.objectsLabel.text = classNumber;
            
            cell.authenticationSign.hidden = NO;
            cell.authenticationSign.frame = CGRectMake(SCREEN_WIDTH-60, 8.5, 30, 30);
            [cell.authenticationSign setImage:[UIImage imageNamed:@"icon_qr"]];
        }
        else if(indexPath.row == 3)
        {
            cell.nameLabel.text = @"班级类型";
            cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
            
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left, 10, 180, 27);
            NSString *schoollevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoollevel"];
            cell.objectsLabel.text = [NSString stringWithFormat:@"%@",[schoolLevelArray objectAtIndex:[schoollevel integerValue]]];
        }
        
        else if(indexPath.row == 4)
        {
            CGSize schoolNameSize = [Tools getSizeWithString:schoolName andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left, 10, 180, schoolNameSize.height>27?schoolNameSize.height:27);
            
            cell.nameLabel.text = @"学      校";
            cell.objectsLabel.text = schoolName;
        }
        else if(indexPath.row == 5)
        {
            cell.nameLabel.text = @"地      区";
            cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left, 10, 180, 27);
            cell.objectsLabel.text = regionStr;
            if ([regionStr length] == 0)
            {
                cell.objectsLabel.text = @"未设置学校";
            }
        }
    }
    else if(indexPath.row == 6)
    {
        CGSize size = [Tools getSizeWithString:classInfo andWidth:SCREEN_WIDTH-150 andFont:[UIFont systemFontOfSize:16]];
        cell.nameLabel.frame = CGRectMake(10, 10, 80, 27);
        cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-left, 10, 180, size.height>27?size.height:27);
        cell.objectsLabel.textAlignment = NSTextAlignmentLeft;
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
    }
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg2"];
    cell.backgroundView = bgImageBG;
    if (indexPath.row == 1 || indexPath.row == 4 || indexPath.row == 6 || indexPath.row == 3 || indexPath.row == 2)
    {
        UIImageView *markView = [[UIImageView alloc] init];
        markView.hidden = YES;
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue] == 2 || indexPath.row == 2)
        {
            markView.hidden = NO;
            markView.frame = CGRectMake(SCREEN_WIDTH-20, 17, 8, 12);
            [markView setImage:[UIImage imageNamed:@"discovery_arrow"]];
            [cell.contentView addSubview:markView];
        }
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            SetClassInfoViewController *setClassInfoViewController = [[SetClassInfoViewController alloc] init];
            setClassInfoViewController.infoKey = @"name";
            setClassInfoViewController.infoStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            setClassInfoViewController.classID = classID;
            setClassInfoViewController.setClassInfoDel = self;
            [self.navigationController pushViewController:setClassInfoViewController animated:YES];
        }
    }
    else if(indexPath.row == 2)
    {
        ClassQRViewController *classQRVC = [[ClassQRViewController alloc] init];
        classQRVC.classNumber = classNumber;
        [self.navigationController pushViewController:classQRVC animated:YES];
    }
    else if(indexPath.row == 6)
    {
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            SetClassInfoViewController *setClassInfoViewController = [[SetClassInfoViewController alloc] init];
            setClassInfoViewController.infoKey = @"info";
            setClassInfoViewController.infoStr = classInfo;
            setClassInfoViewController.setClassInfoDel = self;
            [self.navigationController pushViewController:setClassInfoViewController animated:YES];
        }
    }
    else if (indexPath.row == 4)
    {
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            SearchSchoolViewController  *searchSchoolInfoViewController = [[SearchSchoolViewController alloc] init];
            
            [[NSUserDefaults standardUserDefaults] setObject:BINDCLASSTOSCHOOL forKey:SEARCHSCHOOLTYPE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.navigationController pushViewController:searchSchoolInfoViewController animated:YES];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == HEADERIMAGETAG)
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == TAKEPICTURETAG)
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
    OperatDB *db = [[OperatDB alloc] init];
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] integerValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        NSString *title;
        if ([imageUsed isEqualToString:@"img_icon"])
        {
            title = @"更换班级头像";
        }
        else
        {
            title = @"更换班级背景";
        }
        
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
        ac.tag = TAKEPICTURETAG;
        [ac showInView:self.bgView];
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
                    [[NSUserDefaults standardUserDefaults]  setObject:[[responseDict objectForKey:@"data"] objectForKey:@"files"] forKey:@"classkbimage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
                    [topicImageView setImage:image];
                    
                }
                else if ([imageKey isEqualToString:@"img_icon"])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"files"] forKey:@"classiconimage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
                    [headerImageView setImage:image];
                }
                [classInfoTableView reloadData];
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
                    [Tools fillImageView:((UIImageView *)[classInfoTableView viewWithTag:2222]) withImageFromURL:[[responseDict objectForKey:@"data"] objectForKey:@"img_icon"] andDefault:@"toppic"];
                }
                else
                {
                    [headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"img_kb"] length] > 10)
                {
                    [Tools fillImageView:((UIImageView *)[classInfoTableView viewWithTag:3333]) withImageFromURL:[[responseDict objectForKey:@"data"] objectForKey:@"img_kb"] andDefault:@"toppic"];
                }
                else
                {
                    [topicImageView setImage:[UIImage imageNamed:@"toppic"]];
                }
                if ([[responseDict objectForKey:@"data"] objectForKey:@"info"])
                {
                    classInfo = [[responseDict objectForKey:@"data"] objectForKey:@"info"];
                }
                
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"school"] isEqual:[NSNull null]])
                {
                    regionStr = [[[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"region"] objectForKey:@"name"] ;
                    schoolName = [[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
                }
                
                if ([[responseDict objectForKey:@"data"]objectForKey:@"number"] &&
                    ![[[responseDict objectForKey:@"data"]objectForKey:@"number"] isEqual:[NSNull null]])
                {
                    NSString *tmpclassnumber = [NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"]objectForKey:@"number"] integerValue]];
                    if ([tmpclassnumber isEqualToString:@"0"])
                    {
                        classNumber = @"未获取到";
                    }
                    else
                    {
                        classNumber = tmpclassnumber;
                    }
                }
                else
                {
                    classNumber = @"未获取到";
                }
                [classInfoTableView reloadData];
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
