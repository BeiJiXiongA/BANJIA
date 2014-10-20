//
//  AddDongTaiViewController.m
//  School
//
//  Created by TeekerZW on 14-1-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AddDongTaiViewController.h"
#import "Header.h"
#import "AGImagePickerController+Helper.h"
#import "AGIPCGridItem.h"
#import "AGIPCToolbarItem.h"
#import "Header.h"
#import "TFIndicatorView.h"
#import <CoreLocation/CoreLocation.h>
#import "ImageCell.h"
#import "ImageItem.h"

#import "UIImageView+WebCache.h"
#import "ClassesListViewController.h"

#import "KLSwitch.h"

#define CONTENT_TEXTVIEW_HEIGHT  49

#define NormalImageScale  2
#define BigImageScale    2

#define ContentTextViewTag  1000
#define LocationTextViewTag  2000

#define ImageTag   777777
#define DeleteButtonTag   55555

#define CancelEditDongTaiAlTag   9999

#define columns 4
//#define rows 4
#define itemsPerPage 16
#define space ((SCREEN_WIDTH-columns*gridWith)/(columns+1))
#define gridHight 65
#define gridWith 65
#define unValidIndex  -1
#define threshold 2

#define betweenspace    10
#define marginspace  ((SCREEN_WIDTH - gridWith*4-10*3)/2)

@interface AddDongTaiViewController ()<UIScrollViewDelegate,
AGImagePickerControllerDelegate,
UIGestureRecognizerDelegate,
UITextViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate,
ASIProgressDelegate,
UIActionSheetDelegate,
SelectClasses,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate
>
{
    AGImagePickerController *imagePickerController;
    UIImagePickerController *sysImagePickerController;
    
    NSMutableArray *selectPhotosArray;
    NSMutableArray *normalPhotosArray;
    NSMutableArray *thunImageArray;
    NSMutableArray *alreadySelectAssets;
    
    NSMutableArray *latelyAssetArray;
    
    UIButton *imageTipLabel;
    
    UIScrollView *mainScrollView;
    
    UIScrollView *imageScrollView;
    UILabel *latelyLabel;
    UIButton *addImageButton;
    UIImageView *inputImageView;
    UITextView *contentTextView;
    UITextView *placeHolderLabel;
    UIButton *emitButton;
    
    UIImage *inputImage;
    UIImageView *contentImageView;
    
    UIView *lateImageView;
    NSMutableArray *tmpLatelyArray;
    NSMutableArray *latelyThumImageArray;
    NSMutableArray *latelyFullImageArray;
    NSMutableDictionary *latelyImageDict;
    NSMutableArray *originalLatelyImageArray;
    
    //位置
    CLLocationManager *locationManager;
    CLLocation *nowLocation;
    UIButton *locationButton;
    BOOL locationEditing;
    UIView *locationBgView;
    MyTextField *locationTextView;
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    BOOL enableLocation;
    
    CGFloat keyBoardHeight;
    
    NSMutableArray *latelyImageNumArray;
    
    UIProgressView *mypro;
    
    CGFloat imageH;
    CGFloat imageW;
    
    BOOL isSelectPhoto;
    
    CGFloat lateImageHeight;
    CGFloat spaceHeight;
    
    UIView *isBlogView;
    UILabel *isBlogLabel;
    KLSwitch *isBolgSwitch;
    NSString *isBlog;
}
@end

@implementation AddDongTaiViewController
@synthesize classID,fromCLass;
int count = 0;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self)
    {
        mypro = [[UIProgressView alloc] init];
        selectPhotosArray = [[NSMutableArray alloc] initWithCapacity:0];
        thunImageArray = [[NSMutableArray alloc] initWithCapacity:0];
        latelyThumImageArray = [[NSMutableArray alloc] initWithCapacity:0];
        latelyFullImageArray = [[NSMutableArray alloc] initWithCapacity:0];
        latelyImageDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        tmpLatelyArray = [[NSMutableArray alloc] initWithCapacity:0];
        latelyImageNumArray = [[NSMutableArray alloc] initWithCapacity:0];
        normalPhotosArray = [[NSMutableArray alloc] initWithCapacity:0];
        originalLatelyImageArray = [[NSMutableArray alloc] initWithCapacity:0];
        alreadySelectAssets = [[NSMutableArray alloc] initWithCapacity:0];
        latelyAssetArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark - location

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    nowLocation = newLocation;
    //do something else
    __block NSString *name;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array,NSError *error){
        if ([array count]>0) {
            
            CLPlacemark * placemark = [array objectAtIndex:0];
            NSDictionary *addDict = placemark.addressDictionary;
            name = [NSString stringWithFormat:@"%@.%@.%@",[addDict objectForKey:@"State"],[addDict objectForKey:@"SubLocality"],[addDict objectForKey:@"Thoroughfare"]];
            [UIView animateWithDuration:0.2 animations:^{
                CGSize nameSize = [Tools getSizeWithString:name andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                locationTextView.frame = CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y-3, nameSize.width+60,35);
            }];
            locationTextView.text = name;
            latitude = newLocation.coordinate.latitude;
            longitude = newLocation.coordinate.longitude;
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    DDLOG(@"Error:%@",[error localizedDescription]);
    switch ([error code])
    {
        case kCLErrorDenied:
            errorString = @"定位服务被禁止，请到设置->隐私->定位服务里打开这个应用的定位服务";
            break;
        case kCLErrorLocationUnknown:
            errorString = @"定位信息不可用";
        default:
            errorString = @"位置错误";
            break;
    }
    [Tools showAlertView:errorString delegateViewController:nil];
}

- (void) setupLocationManager {
    if (![Tools NetworkReachable])
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
        return ;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    if (SYSVERSION >= 8)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
                locationManager.delegate = self;
                locationManager.distanceFilter = 200;
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [locationManager startUpdatingLocation];
    }
}

-(void)switchLocation
{
    [self setupLocationManager];
}



#pragma mark - viewControllerLifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
//    [self getImgs];
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
        [self setupLocationManager];
//    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    if (!isSelectPhoto)
    {
        count = 0;
    }
    [self backKeyboard];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"发表空间";
    
    keyBoardHeight = 0.0f;
    imageW = 67.5;
    imageH = 67.5;
    
    spaceHeight = 12;
    
    enableLocation = YES;
    
    isSelectPhoto = NO;
    
    isBlog = @"1";
    
    sysImagePickerController = [[UIImagePickerController alloc] init];
    sysImagePickerController.delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelected:) name:@"photochanged" object:nil];
    
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
    [self.bgView addSubview:mainScrollView];
    
    UITapGestureRecognizer *scTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKeyboard)];
    mainScrollView.userInteractionEnabled = YES;
    [mainScrollView addGestureRecognizer:scTap];
    
    contentImageView = [[UIImageView alloc] init];
    contentImageView.frame = CGRectMake(9.5, 8, SCREEN_WIDTH - 19,71);
    contentImageView.layer.cornerRadius = 8;
    contentImageView.backgroundColor = [UIColor whiteColor];
    contentImageView.layer.borderColor = TIMECOLOR.CGColor;
    contentImageView.layer.borderWidth = 0.3;
    [mainScrollView addSubview:contentImageView];
    
    placeHolderLabel = [[UITextView alloc] init];
    placeHolderLabel.text = @"说点什么吧...";
    placeHolderLabel.backgroundColor = [UIColor clearColor];
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    placeHolderLabel.font = [UIFont systemFontOfSize:16];
    [mainScrollView addSubview:placeHolderLabel];
    
    
    
    contentTextView = [[UITextView alloc] init];
    contentTextView.frame = CGRectMake(13, spaceHeight, SCREEN_WIDTH -26, CONTENT_TEXTVIEW_HEIGHT);
    contentTextView.delegate = self;
    contentTextView.tag = ContentTextViewTag;
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.font = [UIFont systemFontOfSize:15];
    [mainScrollView addSubview:contentTextView];
    
    
    imageScrollView = [[UIScrollView alloc] init];
    imageScrollView.frame = CGRectMake(9.5, contentImageView.frame.size.height+contentImageView.frame.origin.y+spaceHeight, SCREEN_WIDTH-19, imageH+23);
    imageScrollView.backgroundColor = [UIColor whiteColor];
    imageScrollView.layer.borderColor = TIMECOLOR.CGColor;
    imageScrollView.layer.borderWidth = 0.3;
    imageScrollView.clipsToBounds = YES;
    imageScrollView.scrollEnabled = NO;
    imageScrollView.layer.cornerRadius = 8;
    imageScrollView.contentSize = CGSizeMake(SCREEN_WIDTH-8, 80);
    [mainScrollView addSubview:imageScrollView];
    
    imageTipLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageTipLabel setImage:[UIImage imageNamed:@"diary_add_image"] forState:UIControlStateNormal];
    imageTipLabel.frame = CGRectMake(19, imageScrollView.frame.origin.y+spaceHeight, imageW, imageW);
    imageTipLabel.backgroundColor = [UIColor clearColor];
    [imageTipLabel addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    [imageTipLabel setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    imageTipLabel.titleLabel.font = [UIFont systemFontOfSize:16];
    
    addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + spaceHeight, imageTipLabel.frame.origin.y, 80, imageH);
    [addImageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    addImageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [addImageButton setTitle: @"添加图片\n至多12张" forState:UIControlStateNormal];
    addImageButton.titleLabel.numberOfLines = 2;
    addImageButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [addImageButton addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    placeHolderLabel.frame = contentTextView.frame;
    
    [mainScrollView addSubview:imageTipLabel];
    [mainScrollView addSubview:addImageButton];
    placeHolderLabel.frame = contentTextView.frame;
    
    lateImageHeight = -7;
    lateImageView = [[UIView alloc] init];
    lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height + imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, lateImageHeight);
    lateImageView.backgroundColor = [UIColor whiteColor];
    lateImageView.layer.cornerRadius = 8;
    lateImageView.layer.borderWidth = 0.3;
    lateImageView.layer.borderColor = TIMECOLOR.CGColor;
    [mainScrollView addSubview:lateImageView];
    lateImageView.hidden = YES;
    
    latelyLabel = [[UILabel alloc] init];
    latelyLabel.text = @"你可能想上传的照片";
    latelyLabel.backgroundColor = [UIColor clearColor];
    latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
    latelyLabel.font = [UIFont systemFontOfSize:17];
    latelyLabel.textColor = UIColorFromRGB(0x727171);
    [mainScrollView addSubview:latelyLabel];
    latelyLabel.hidden = YES;

    
//    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    locationBgView = [[UIView alloc] init];
    locationBgView.frame = CGRectMake(lateImageView.frame.origin.x, imageScrollView.frame.origin.y+imageScrollView.frame.size.height+spaceHeight, lateImageView.frame.size.width, 45);
    locationBgView.backgroundColor = [UIColor whiteColor];
    locationBgView.layer.cornerRadius = 3;
    locationBgView.clipsToBounds = YES;
    [mainScrollView addSubview:locationBgView];
    
    //位置
    locationEditing = NO;
    locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(3, 7.5, 30, 30);
    [locationButton addTarget:self action:@selector(switchLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [locationBgView addSubview:locationButton];
    
    locationTextView = [[MyTextField alloc] init];
    locationTextView.frame = CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y, 0,45);
    locationTextView.font = [UIFont systemFontOfSize:14];
    locationTextView.background = nil;
    locationTextView.delegate = self;
    locationTextView.clearButtonMode = UITextFieldViewModeAlways;
    locationTextView.tag = LocationTextViewTag;
    [locationBgView addSubview:locationTextView];
    
    //提交
    emitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emitButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    emitButton.backgroundColor = [UIColor clearColor];
    [emitButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    [emitButton addTarget:self action:@selector(emitClick) forControlEvents:UIControlEventTouchUpInside];
    [emitButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.navigationBarView addSubview:emitButton];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, lateImageView.frame.size.height+lateImageView.frame.origin.y+20);
    
    isBlogView = [[UIView alloc] init];
    isBlogView.frame = CGRectMake(locationBgView.frame.origin.x, locationBgView.frame.origin.y+locationBgView.frame.size.height+10, locationBgView.frame.size.width, locationBgView.frame.size.height);
    [mainScrollView addSubview:isBlogView];
    
    isBlogLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7.5, 230, 30)];
    isBlogLabel.textColor = COMMENTCOLOR;
    isBlogLabel.backgroundColor = [UIColor clearColor];
    isBlogLabel.font = [UIFont systemFontOfSize:18];
    isBlogLabel.text = @"是否提供给学校进行展示";
    [isBlogView addSubview:isBlogLabel];
        
    isBolgSwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(isBlogView.frame.size.width-60, 7.5, 60, 30)];
    [isBolgSwitch addTarget:self action:@selector(isBlogChange:) forControlEvents:UIControlEventValueChanged];
    [isBolgSwitch setOn:YES];
    [isBlogView addSubview:isBolgSwitch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)isBlogChange:(KLSwitch *)klSwitch
{
    if ([klSwitch isOn])
    {
        isBlog = @"1";
    }
    else
    {
        isBlog = @"0";
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)unShowSelfViewController
{
    if ([normalPhotosArray count] > 0 || [contentTextView.text length] > 0)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要放弃编辑吗" delegate:self cancelButtonTitle:@"继续" otherButtonTitles:@"放弃", nil];
        al.tag = CancelEditDongTaiAlTag;
        [al show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CancelEditDongTaiAlTag)
    {
        if (buttonIndex == 1)
        {
            count = 0;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - aboutPhoto
-(void)selectPhoto
{
    [self backKeyboard];
    
    if ([selectPhotosArray count]>12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        imageTipLabel.hidden = YES;
        addImageButton.hidden = YES;
        return ;
    }
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    [ac showInView:self.bgView];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self openAction:nil];
    }
    else if(buttonIndex == 1)
    {
        if ([Tools captureEnable])
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                sysImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                isSelectPhoto = YES;
                [self presentViewController:sysImagePickerController animated:YES completion:nil];
            }
            else
            {
                [Tools showAlertView:@"相机不可用" delegateViewController:nil];
            }
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [sysImagePickerController dismissViewControllerAnimated:YES completion:nil];
    UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerOriginalImage"], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self loadAssetsGroups];
//    [self getImgs];
}

#pragma mark - dealImage
-(UIImage *)getNormalImageFromImage:(UIImage *)originalImage
{
//    a307741613dbc06cd926be027a15298364712d59
    CGFloat imageHeight = 0.0f;
    CGFloat imageWidth = 0.0f;
    if (originalImage.size.width > originalImage.size.height)
    {
        if (originalImage.size.height > MAXHEIGHT)
        {
            imageHeight = MAXHEIGHT;
            imageWidth = originalImage.size.width*imageHeight/originalImage.size.height;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    else if(originalImage.size.width < originalImage.size.height)
    {
        if (originalImage.size.width > MAXWIDTH)
        {
            imageWidth = MAXWIDTH;
            imageHeight = originalImage.size.height*imageWidth/originalImage.size.width;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    else
    {
        if (originalImage.size.width > MAXWIDTH)
        {
            imageWidth = MAXWIDTH;
            imageHeight = MAXWIDTH;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    originalImage = [Tools thumbnailWithImageWithoutScale:originalImage size:CGSizeMake(imageWidth, imageHeight)];
    
    return originalImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isSelectPhoto = NO;
    [sysImagePickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - getLatelyPhotos

-(void)getImgs
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->隐私->照片'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                [latelyAssetArray addObject:result];
            }
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop){
            
            if (group == nil || group.numberOfAssets == 0)
            {
                return ;
            }
            
            if (group!=nil)
            {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                
                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[NSArray arrayWithArray:[g1 componentsSeparatedByString:@","]];
                NSString *g2=[[arr objectAtIndex:0]substringFromIndex:5];
                if ([g2 isEqualToString:@"Camera Roll"]) {
                    g2=@"相机胶卷";
                }
                NSString *groupName=g2;//组的name
                DDLOG(@"groupName=%@",groupName);
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
                if ([groupName isEqualToString:@"相机胶卷"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateLately];
                    });
                }
            }
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
    });
}

-(void)updateLately
{
    ALAsset *asset = [latelyAssetArray lastObject];
    [alreadySelectAssets addObject:asset];
    [self reloadImages];
}

-(void)addLatelyImage:(UITapGestureRecognizer *)tap
{
    ALAsset *asset = [latelyAssetArray objectAtIndex:tap.view.tag-ImageTag];
    if (![self hasThisLatelyImage:asset])
    {
        [alreadySelectAssets addObject:asset];
    }
    else
    {
        for(ALAsset *item in alreadySelectAssets)
        {
            if ([item isEqual:asset])
            {
                [alreadySelectAssets removeObject:item];
            }
        }
    }
    [self reloadImages];
}

-(void)reloadImages
{
    for(UIView *v in imageScrollView.subviews)
    {
        [v removeFromSuperview];
    }
    
    int row = 0;
    if (([alreadySelectAssets count]+1)%4 == 0)
    {
        row = ([alreadySelectAssets count]+1)/4;
    }
    else
    {
        row = ([alreadySelectAssets count]+1)/4+1;
    }
    [normalPhotosArray removeAllObjects];
    if ([alreadySelectAssets count] > 0)
    {
        addImageButton.hidden = YES;
        if ([alreadySelectAssets count] >= 12)
        {
            imageTipLabel.hidden = YES;
        }
        else
        {
            imageTipLabel.hidden = NO;
        }
        for (int i=0; i<[alreadySelectAssets count]; ++i)
        {
            ALAsset *item = [alreadySelectAssets objectAtIndex:i];
            UIImage *normarlImage = [ImageTools getImageFromALAssesst:item];
            [normalPhotosArray addObject:normarlImage];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            imageView.frame = CGRectMake(10+(imageW+5)*(i%4), 11.5+(imageH+5)*(i/4), imageW, imageH);
            [imageView setImage:normarlImage];
            imageView.tag = ImageTag + i;
            imageView.layer.cornerRadius = 5;
            imageView.clipsToBounds = YES;
            [imageScrollView addSubview:imageView];
            
            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.frame = CGRectMake(10+(imageW+5)*(i%4), 5+(imageH+5)*(i/4), imageW, 20);
            deleteButton.tag = DeleteButtonTag +i;
            [deleteButton setImage:[UIImage imageNamed:@"icon_del"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            [imageScrollView addSubview:deleteButton];
            
            if (row <= 3)
            {
                imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, (row>1?(10+(imageH+5)*row):(imageW+23))+5);
            }
            else
            {
                imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, (10+(imageH+5)*3));
            }
            
            imageTipLabel.frame = CGRectMake(19+(imageW+5)*([normalPhotosArray count]%4), 11.5+(imageH+5)*([normalPhotosArray count]/4)+imageScrollView.frame.origin.y, imageW, imageH);
            addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + 10, imageTipLabel.frame.origin.y, 80, imageH);
            lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height+imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, lateImageHeight);
            latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
            
            locationBgView.frame = CGRectMake(lateImageView.frame.origin.x, imageScrollView.frame.origin.y+imageScrollView.frame.size.height+spaceHeight, lateImageView.frame.size.width , 45);
            isBlogView.frame = CGRectMake(locationBgView.frame.origin.x, locationBgView.frame.origin.y+locationBgView.frame.size.height+10, locationBgView.frame.size.width, locationBgView.frame.size.height);
            mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, isBlogView.frame.size.height+isBlogView.frame.origin.y+20);
        }

    }
    else
    {
        addImageButton.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            imageTipLabel.frame = CGRectMake(19+(imageW+5)*([normalPhotosArray count]%4), 11.5+(imageH+5)*([normalPhotosArray count]/4)+imageScrollView.frame.origin.y, imageW, imageH);
            addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + 10, imageTipLabel.frame.origin.y, 80, imageH);
            lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height+imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, lateImageHeight);
            latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
            locationBgView.frame = CGRectMake(lateImageView.frame.origin.x, imageScrollView.frame.origin.y + imageScrollView.frame.size.height+9.5, lateImageView.frame.size.width , 45);
            
            mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, locationBgView.frame.size.height+locationBgView.frame.origin.y+20);
        }];
    }
    
}

-(BOOL)hasThisLatelyImage:(ALAsset *)asset
{
    for(ImageItem *item in alreadySelectAssets)
    {
        if ([item.asset isEqual:asset])
        {
            return YES;
        }
    }
    return NO;
}

-(void)deleteImage:(UIButton *)button
{
    [alreadySelectAssets removeObjectAtIndex:button.tag-DeleteButtonTag];
    [normalPhotosArray removeObjectAtIndex:button.tag - DeleteButtonTag];
    
    for(UIView *v in imageScrollView.subviews)
    {
        [v removeFromSuperview];
    }
    
    int row = 0;
    if (([alreadySelectAssets count]+1)%4 == 0)
    {
        row = ([normalPhotosArray count]+1)/4;
    }
    else
    {
        row = ([normalPhotosArray count]+1)/4+1;
    }
    for (int i=0; i<[normalPhotosArray count]; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        imageView.frame = CGRectMake(10 + ( imageW + 5 ) * ( i % 4 ), 11.5 + (imageH + 5 ) * ( i / 4), imageW, imageH);
        [imageView setImage:[normalPhotosArray objectAtIndex:i]];
        imageView.tag = ImageTag + i;
        imageView.layer.cornerRadius = 5;
        imageView.clipsToBounds = YES;
        [imageScrollView addSubview:imageView];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(10+(imageW+5)*(i%4), 5+(imageH+5)*(i/4), imageW, 20);
        deleteButton.tag = DeleteButtonTag +i;
        [deleteButton setImage:[UIImage imageNamed:@"icon_del"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageScrollView addSubview:deleteButton];
    }
    if (row <= 3)
    {
        imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, (row>1?(10+(imageH+5)*row):(imageW+23))+5);
    }
    else
    {
        imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, (10+(imageH+5)*3)+5);
    }
    
    if ([alreadySelectAssets count] > 0)
    {
        addImageButton.hidden = YES;
    }
    else
    {
        addImageButton.hidden = NO;
    }
    [UIView animateWithDuration:0.2 animations:^{
        imageTipLabel.frame = CGRectMake(19+(imageW+5)*([normalPhotosArray count]%4), 11.5+(imageH+5)*([normalPhotosArray count]/4)+imageScrollView.frame.origin.y, imageW, imageH);
        addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + 10, imageTipLabel.frame.origin.y, 80, imageH);
        lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height+imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, lateImageHeight);
        latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
        
        locationBgView.frame = CGRectMake(lateImageView.frame.origin.x, imageScrollView.frame.origin.y+imageScrollView.frame.size.height+spaceHeight, lateImageView.frame.size.width , 45);
        
        isBlogView.frame = CGRectMake(locationBgView.frame.origin.x, locationBgView.frame.origin.y+locationBgView.frame.size.height+10, locationBgView.frame.size.width, locationBgView.frame.size.height);
        
        mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, locationBgView.frame.size.height+locationBgView.frame.origin.y+20);
    }];
    if ([alreadySelectAssets count] == 12)
    {
        imageTipLabel.hidden = YES;
    }
    else
    {
        imageTipLabel.hidden = NO;
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    
}

-(void)emitClick
{
    [contentTextView resignFirstResponder];
    if ([contentTextView.text length] <= 0 && [normalPhotosArray count] <= 0)
    {
        [Tools showAlertView:@"说点什么或添加几张图片吧！" delegateViewController:nil];
        return ;
    }
    if (!fromCLass)
    {
        ClassesListViewController *classelistVC = [[ClassesListViewController alloc] init];
        classelistVC.selectClassdel = self;
        [self.navigationController pushViewController:classelistVC animated:YES];
        return ;
    }
    [self submitDongTai:classID];
}

-(void)selectClasses:(NSArray *)selectClassesArray
{
    DDLOG(@"selected classes %@",selectClassesArray);
    [self submitDongTai:[selectClassesArray firstObject]];
}

-(void)submitDongTai:(NSString *)classid
{
    if ([Tools NetworkReachable])
    {
        NSString *url = [NSString stringWithFormat:@"%@/Diaries/mbAddDiaries",HOST_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        [request setUploadProgressDelegate:mypro];
        [request setRequestMethod:@"POST"];
        [request setPostValue:[Tools client_token] forKey:@"token"];
        [request setPostValue:[Tools user_id] forKey:@"u_id"];
        [request setPostValue:classid forKey:@"c_id"];
        [request setPostValue:contentTextView.text forKey:@"content"];
        [request setPostValue:isBlog forKey:@"isblog"];
        [request setTimeOutSeconds:60];
        
        if ([locationTextView.text length]>0)
        {
            [request setPostValue:locationTextView.text forKey:@"add"];
            [request setPostValue:[NSString stringWithFormat:@"%f",latitude] forKey:@"lat"];
            [request setPostValue:[NSString stringWithFormat:@"%f",longitude] forKey:@"lng"];
        }
        
        for (int i=0; i<[normalPhotosArray count]; ++i)
        {
            UIImage *image = [normalPhotosArray objectAtIndex:i];
            DDLOG(@"image size = %@",NSStringFromCGSize(image.size));
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
            DDLOG(@"size======%d",[imageData length]);
            
            [request addData:imageData withFileName:[NSString stringWithFormat:@"%d.jpeg",i+1] andContentType:@"image/jpeg" forKey:[NSString stringWithFormat:@"file%d",i+1]];
        }
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"add trends responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"]) && ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue] == 0))
                {
                    [Tools showAlertView:@"发表成功,审核通过后会显示在班级空间列表里" delegateViewController:nil];
                }
                else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"]) && ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue] == 0))
                {
                    [Tools showAlertView:@"发表成功,审核通过后会显示在班级空间列表里" delegateViewController:nil];
                }
                if ([self.classZoneDelegate respondsToSelector:@selector(haveAddDonfTai:)])
                {
                    [self.classZoneDelegate haveAddDonfTai:YES];
                    [Tools showTips:@"发表成功！" toView:self.bgView];
                    count = 0;
                    [self.navigationController popViewControllerAnimated:YES];
                }
                emitButton.enabled = YES;
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            emitButton.enabled = YES;
        }];
        emitButton.enabled = NO;
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    DDLOG(@"%f",[mypro progress]);
}

#pragma mark - textViewDelegate

-(void)backKeyboard
{
    [contentTextView resignFirstResponder];
    [locationTextView resignFirstResponder];
    keyBoardHeight = 0;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView.tag == ContentTextViewTag)
    {
        [UIView animateWithDuration:0.25 animations:^{
            mainScrollView.contentOffset = CGPointMake(0,keyBoardHeight);
            
        }completion:^(BOOL finished) {
        }];
    }
    if (!textView.window.isKeyWindow)
    {
        [textView.window makeKeyAndVisible];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == LocationTextViewTag)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-(([alreadySelectAssets count]+1)/4)*imageH);
            
        }completion:^(BOOL finished) {
        }];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [locationTextView resignFirstResponder];
        [contentTextView resignFirstResponder];
        
        if ([textView.text length] > 200)
        {
            textView.text = [textView.text substringToIndex:200];
            return NO;
        }
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 1000)
    {
        if ([textView.text length]>0)
        {
            placeHolderLabel.text = @"";
        }
        else if([textView.text length] == 0)
        {
            placeHolderLabel.text = @"说点什么吧...";
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in mainScrollView.subviews)
    {
        if ([v isKindOfClass:[UITextView class]])
        {
            if (![v isExclusiveTouch])
            {
                [v resignFirstResponder];
            }
        }
    }
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
        mainScrollView.contentOffset = CGPointZero;
    }completion:^(BOOL finished) {
        locationEditing = NO;
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    int height = keyboardRect.size.height;
    
//    if (FOURS)
//    {
//        keyBoardHeight = ABS(height + (mainScrollView.contentSize.height - mainScrollView.frame.size.height))-YSTART-130;
//    }
//    else
//    {
//        if (SYSVERSION>=7)
//        {
//            keyBoardHeight = ABS(height + (mainScrollView.contentSize.height - mainScrollView.frame.size.height))-YSTART-35;
//        }
//        else
//        {
//            keyBoardHeight = ABS(height + (mainScrollView.contentSize.height - mainScrollView.frame.size.height))-YSTART;
//        }
//    }
}


#pragma mark - AGIImagePickerController

- (void)openAction:(id)sender
{
    // Show saved photos on top
    
    for (int i = 0; i<[alreadySelectAssets count]; i++)
    {
        DDLOG(@"asset %@",[alreadySelectAssets objectAtIndex:i]);
    }

    imagePickerController = [[AGImagePickerController alloc] initWithDelegate:self andAlreadySelect:alreadySelectAssets];
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    imagePickerController.shouldShowSavedPhotosOnTop = NO;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    imagePickerController.toolbarItemsForManagingTheSelection = @[];
    if ([alreadySelectAssets count] > 0)
    {
        imagePickerController.selection = alreadySelectAssets;
    }
    
    imagePickerController.maximumNumberOfPhotosToBeSelected = 12;
    isSelectPhoto = YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error
{
    NSLog(@"Fail. Error: %@", error);
    isSelectPhoto = NO;
    if (error == nil) {
        NSLog(@"User has cancelled.");
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        
        // We need to wait for the view controller to appear first.
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        });
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLOG(@"album info %@",info);
    }];
    [alreadySelectAssets removeAllObjects];
    for (int i= 0; i<[info count]; i++)
    {
        ALAsset *asset = [info objectAtIndex:i];
        [alreadySelectAssets addObject:asset];
    }
    [self reloadImages];
}

-(void)handleSelected:(NSNotification *)notification
{
    
}

#pragma mark - AGImagePickerControllerDelegate methods

- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
         numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
              andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 7;
        else
            return 6;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 5;
        else
            return 4;
    }
}
- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}


- (void)loadAssets:(ALAssetsGroup *)assetsGroup
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 
         [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
 
             if (result == nil)
             {
                 return;
             }
             if (index == [assetsGroup numberOfAssets]-1)
             {
                 [alreadySelectAssets addObject:result];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self reloadImages];
                 });
             }
         }];
     });
 }
 
 
 - (void)loadAssetsGroups
 {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
 
         @autoreleasepool {
 
             void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
             {
                 if (group == nil || group.numberOfAssets == 0)
                 {
                     return;
                 }
                 if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos)
                 {
                     [self loadAssets:group];
                 }
             };
 
             void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                 NSLog(@"A problem occured. Error: %@", error.localizedDescription);
             };
 
             [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                           usingBlock:assetGroupEnumerator
                                                                         failureBlock:assetGroupEnumberatorFailure];
 
         }
 
     });
 }


@end