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

#import "UIImageView+WebCache.h"
#import "ClassesListViewController.h"

#define NormalImageScale  2
#define BigImageScale    2

#define ContentTextViewTag  1000
#define LocationTextViewTag  2000

#define ImageTag   777777
#define DeleteButtonTag   55555

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
UIImagePickerControllerDelegate
>
{
    AGImagePickerController *imagePickerController;
    UIImagePickerController *sysImagePickerController;
    
    NSMutableArray *selectPhotosArray;
    NSMutableArray *normalPhotosArray;
    NSMutableArray *thunImageArray;
    
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
            name = placemark.name;
            
                [UIView animateWithDuration:0.2 animations:^{
                    locationTextView.frame = CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y-3, [name length]*14>260?260:([name length]*14),35);
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


#pragma mark - backClick

-(void)mybackClick
{
    count = 0;
    [self unShowSelfViewController];
}
#pragma mark - viewControllerLifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    [self getImgs];
    
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
    self.titleLabel.text = @"发布日记";
    
    keyBoardHeight = 0.0f;
    imageW = 67.5;
    imageH = 67.5;
    
    enableLocation = YES;
    
    isSelectPhoto = NO;
    
    sysImagePickerController = [[UIImagePickerController alloc] init];
    sysImagePickerController.delegate = self;
    
    imagePickerController = [[AGImagePickerController alloc] initWithDelegate:self];
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT);
    [self.bgView addSubview:mainScrollView];
    
    UITapGestureRecognizer *scTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKeyboard)];
    mainScrollView.userInteractionEnabled = YES;
    [mainScrollView addGestureRecognizer:scTap];
    
//    inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(10, 2, 10, 2)];
    contentImageView = [[UIImageView alloc] init];
    contentImageView.frame = CGRectMake(9.5, 8, SCREEN_WIDTH - 19,71);
    contentImageView.layer.cornerRadius = 8;
    contentImageView.backgroundColor = [UIColor whiteColor];
    contentImageView.layer.borderColor = TIMECOLOR.CGColor;
    contentImageView.layer.borderWidth = 0.3;
//    [contentImageView setImage:inputImage];
    [mainScrollView addSubview:contentImageView];
    
    placeHolderLabel = [[UITextView alloc] init];
    placeHolderLabel.text = @"说点什么吧...";
    placeHolderLabel.backgroundColor = [UIColor clearColor];
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    placeHolderLabel.font = [UIFont systemFontOfSize:16];
    [mainScrollView addSubview:placeHolderLabel];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(13, 12, SCREEN_WIDTH -26, 47)];
    contentTextView.delegate = self;
    contentTextView.tag = ContentTextViewTag;
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.font = [UIFont systemFontOfSize:15];
    [mainScrollView addSubview:contentTextView];
    
    
    imageScrollView = [[UIScrollView alloc] init];
    imageScrollView.frame = CGRectMake(9.5, contentImageView.frame.size.height+contentImageView.frame.origin.y+12, SCREEN_WIDTH-19, imageH+23);
    imageScrollView.backgroundColor = [UIColor whiteColor];
    imageScrollView.layer.borderColor = TIMECOLOR.CGColor;
    imageScrollView.layer.borderWidth = 0.3;
    imageScrollView.clipsToBounds = YES;
    imageScrollView.layer.cornerRadius = 8;
    imageScrollView.contentSize = CGSizeMake(SCREEN_WIDTH-8, 80);
    [mainScrollView addSubview:imageScrollView];
    
    imageTipLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageTipLabel setImage:[UIImage imageNamed:@"diary_add_image"] forState:UIControlStateNormal];
    imageTipLabel.frame = CGRectMake(19, imageScrollView.frame.origin.y+11.5, imageW, imageW);
    imageTipLabel.backgroundColor = [UIColor clearColor];
    [imageTipLabel addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    [imageTipLabel setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    imageTipLabel.titleLabel.font = [UIFont systemFontOfSize:16];
    
    addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + 10, imageTipLabel.frame.origin.y, 80, imageH);
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
    
    
    lateImageView = [[UIView alloc] init];
    lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height + imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, 125.5);
    lateImageView.backgroundColor = [UIColor whiteColor];
    lateImageView.layer.cornerRadius = 8;
    lateImageView.layer.borderWidth = 0.3;
    lateImageView.layer.borderColor = TIMECOLOR.CGColor;
    [mainScrollView addSubview:lateImageView];
    
    latelyLabel = [[UILabel alloc] init];
    latelyLabel.text = @"你可能想上传的照片";
    latelyLabel.backgroundColor = [UIColor clearColor];
    latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
    latelyLabel.font = [UIFont systemFontOfSize:17];
    latelyLabel.textColor = UIColorFromRGB(0x727171);
    [mainScrollView addSubview:latelyLabel];

    
//    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    //位置
    locationEditing = NO;
    locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(lateImageView.frame.origin.x, lateImageView.frame.origin.y+lateImageView.frame.size.height+9.5, 30, 30);
//    [locationButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(switchLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [mainScrollView addSubview:locationButton];
    
    locationTextView = [[MyTextField alloc] init];
    locationTextView.frame = CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y, 0,45);
    locationTextView.font = [UIFont systemFontOfSize:14];
    locationTextView.backgroundColor = [UIColor whiteColor];
    locationTextView.layer.cornerRadius = 3;
    locationTextView.clipsToBounds = YES;
    locationTextView.background = nil;
    locationTextView.delegate = self;
    locationTextView.clearButtonMode = UITextFieldViewModeAlways;
    locationTextView.tag = LocationTextViewTag;
    [mainScrollView addSubview:locationTextView];
    
    //提交
    emitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emitButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    emitButton.backgroundColor = [UIColor clearColor];
    [emitButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [emitButton addTarget:self action:@selector(emitClick) forControlEvents:UIControlEventTouchUpInside];
    [emitButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.navigationBarView addSubview:emitButton];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, lateImageView.frame.size.height+lateImageView.frame.origin.y+20);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
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
    
    
    isSelectPhoto = NO;
    UIImage *fullScreenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [selectPhotosArray addObject:fullScreenImage];
    
    fullScreenImage = [self getNormalImageFromImage:fullScreenImage];
    
    if (fullScreenImage)
    {
        [normalPhotosArray addObject:fullScreenImage];
        [thunImageArray addObject:fullScreenImage];
        [self reloadImages];
    }
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
    DDLOG(@"image direction %d",originalImage.imageOrientation);
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                    
                    NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                    [tmpLatelyArray addObject:urlstr];
                }
            }
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop){
            
            if (group == nil)
            {
                
            }
            
            if (group!=nil)
            {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
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
                    [self updateLately];
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
    for (int i=0; i<4; ++i)
    {
        int m = [tmpLatelyArray count]-i-1;
        if (m > 0)
        {
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            NSURL *url=[NSURL URLWithString:[tmpLatelyArray objectAtIndex:[tmpLatelyArray count]-i-1]];
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
                
                UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
                [latelyThumImageArray addObject:image];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(67.5+5)*i, 37, 67.5, 67.5)];
                imageView.layer.cornerRadius = 5;
                imageView.clipsToBounds = YES;
                imageView.tag = ImageTag+i;
                [imageView setImage:image];
                [lateImageView addSubview:imageView];
                UITapGestureRecognizer *addLatelyImageTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addLatelyImage:)];
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:addLatelyImageTgr];
                
                UIImage *fullScreenImage = [self getImageFromALAssesst:asset];
                fullScreenImage = [self getNormalImageFromImage:fullScreenImage];
                [originalLatelyImageArray addObject:fullScreenImage];
                [latelyFullImageArray addObject:fullScreenImage];
                
                
//                __block UIImage *fullScreenImage;
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    fullScreenImage = [self getImageFromALAssesst:asset];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        fullScreenImage = [self getImageFromALAssesst:asset];
//                        fullScreenImage = [self getNormalImageFromImage:fullScreenImage];
//                        [originalLatelyImageArray addObject:fullScreenImage];
//                        [latelyFullImageArray addObject:fullScreenImage];
//                    });
//                });
                
            }failureBlock:^(NSError *error) {
                NSLog(@"error=%@",error);
            }
             ];
        }
    }
}

-(void)addLatelyImage:(UITapGestureRecognizer *)tap
{
    if (count >12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        addImageButton.hidden = YES;
        return;
    }
    NSString *imageTag = [NSString stringWithFormat:@"%d",tap.view.tag];
    
    if ([self hasThisLatelyImage:imageTag])
    {
        [selectPhotosArray removeObject:[originalLatelyImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [normalPhotosArray removeObject:[latelyFullImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [thunImageArray removeObject:[latelyThumImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [latelyImageNumArray removeObject:imageTag];
    }
    else
    {
        [selectPhotosArray addObject:[originalLatelyImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [normalPhotosArray addObject:[latelyFullImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [thunImageArray addObject:[latelyThumImageArray objectAtIndex:tap.view.tag-ImageTag]];
        [latelyImageNumArray addObject:imageTag];
    }
    [self reloadImages];
}

-(void)reloadImages
{
    if ([normalPhotosArray count] > 12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        addImageButton.hidden = YES;
        imageTipLabel.hidden = YES;
        return;
    }
    else if([normalPhotosArray count]==12)
    {
        addImageButton.hidden = YES;
        imageTipLabel.hidden = YES;
    }
    int row = 0;
    if ([normalPhotosArray count] < 12)
    {
        addImageButton.hidden = NO;
        imageTipLabel.hidden = NO;
    }
    for(UIView *v in imageScrollView.subviews)
    {
        [v removeFromSuperview];
    }
    
    if ([thunImageArray count]>0)
    {
        [addImageButton setTitle:@"" forState:UIControlStateNormal];
        addImageButton.enabled = NO;
    }
    else
    {
        [addImageButton setTitle:@"添加图片\n至多12张" forState:UIControlStateNormal];
        addImageButton.enabled = YES;
    }
    if (([thunImageArray count]+1)%4 == 0)
    {
        row = ([thunImageArray count]+1)/4;
    }
    else
    {
        row = ([thunImageArray count]+1)/4+1;
    }
    for (int i=0; i<[thunImageArray count]; ++i)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        imageView.frame = CGRectMake(10+(imageW+5)*(i%4), 11.5+(imageH+5)*(i/4), imageW, imageH);
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
        
        
        DDLOG(@"reload images orientation %d ==size %@",[[normalPhotosArray objectAtIndex:i] imageOrientation],NSStringFromCGSize(((UIImage *)[normalPhotosArray objectAtIndex:i]).size));
    }
    
    
    if (row <= 3)
    {
        imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, row>1?(10+(imageH+5)*row):(imageW+23));
    }
    else
    {
        imageScrollView.frame = CGRectMake(9.5, 7.5+contentImageView.frame.size.height+contentImageView.frame.origin.y, SCREEN_WIDTH-19, (10+(imageH+5)*3));
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        imageTipLabel.frame = CGRectMake(19+(imageW+5)*([thunImageArray count]%4), 11.5+(imageH+5)*([thunImageArray count]/4)+imageScrollView.frame.origin.y, imageW, imageH);
        addImageButton.frame = CGRectMake(imageTipLabel.frame.origin.x+imageTipLabel.frame.size.width + 10, imageTipLabel.frame.origin.y, 80, imageH);
        lateImageView.frame = CGRectMake(9.5, imageScrollView.frame.size.height+imageScrollView.frame.origin.y+10.5, SCREEN_WIDTH-19, 125.5);
        latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+6, 17*[latelyLabel.text length], 20);
        
        locationButton.frame = CGRectMake(locationButton.frame.origin.x, lateImageView.frame.origin.y+lateImageView.frame.size.height+9.5, 40, 40);
        locationTextView.frame = CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y, locationTextView.frame.size.width, 35);
        
        mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, lateImageView.frame.size.height+lateImageView.frame.origin.y+20);
    }];
    
}

-(BOOL)hasThisLatelyImage:(NSString *)latelyImageTag
{
    for(NSString *imageTag in latelyImageNumArray)
    {
        if ([latelyImageTag isEqualToString:imageTag])
        {
            return YES;
        }
    }
    return NO;
}

-(void)deleteImage:(UIButton *)button
{
    [thunImageArray removeObjectAtIndex:button.tag-DeleteButtonTag];
    [selectPhotosArray removeObjectAtIndex:button.tag-DeleteButtonTag];
    [normalPhotosArray removeObjectAtIndex:button.tag-DeleteButtonTag];
    count--;
    [self reloadImages];
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
                    [self unShowSelfViewController];
                    count = 0;
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

-(void)selfBackClick
{
    count = 0;
    [self unShowSelfViewController];
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
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == LocationTextViewTag)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-100-(([normalPhotosArray count]+1)/4)*imageH);
            
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
    mainScrollView.scrollEnabled = NO;
}


#pragma mark - AGIImagePickerController

-(UIImage *)getImageFromALAssesst:(ALAsset *)asset
{
    ALAssetRepresentation *assetPresentation = [asset defaultRepresentation];
    
    CGImageRef imageRef = [assetPresentation fullResolutionImage];
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1 orientation:(int)assetPresentation.orientation];
    NSData *data = UIImageJPEGRepresentation(image, 0.5f);
    UIImage *thumImage = [UIImage imageWithData:data];

    return thumImage;
}

- (void)openAction:(id)sender
{
    DDLOG(@"count in openaction %d",count);
    if (count >= 12)
    {
        [Tools showAlertView:@"图片不能多于12张,请删除后重新添加" delegateViewController:nil];
        return;
    }
    // Show saved photos on top
    imagePickerController.shouldShowSavedPhotosOnTop = NO;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    imagePickerController.toolbarItemsForManagingTheSelection = @[];
    imagePickerController.maximumNumberOfPhotosToBeSelected = 12 - [normalPhotosArray count];
    isSelectPhoto = YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error
{
    NSLog(@"Fail. Error: %@", error);
    [((XDContentViewController *)self.parentViewController.parentViewController).sideMenuController setPanGestureEnabled:NO];
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
    
    }];
    isSelectPhoto = NO;
    if ([info count]+[selectPhotosArray count] > 12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        imageTipLabel.hidden = YES;
        addImageButton.hidden = YES;
        return;
    }
    else if([info count]+[selectPhotosArray count] == 12)
    {
        imageTipLabel.hidden = YES;
        addImageButton.hidden = YES;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    for (int i=0;i<([info count]>12 ? 12:[info count]);++i)
    {
        
        ALAsset *asset = [info objectAtIndex:i];
        
        UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        
        [thunImageArray addObject:image];
        
        UIImage *fullScreenImage = [self getImageFromALAssesst:asset];
        [selectPhotosArray addObject:fullScreenImage];
        
        fullScreenImage = [self getNormalImageFromImage:fullScreenImage];
        
        [normalPhotosArray addObject:fullScreenImage];
        count ++;
    }
    [self reloadImages];
    [((XDContentViewController *)self.parentViewController).sideMenuController setPanGestureEnabled:NO];
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

@end
