//
//  AddDongTaiViewController.m
//  School
//
//  Created by TeekerZW on 14-1-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AddDongTaiViewController1.h"
#import "Header.h"
#import "AGImagePickerController+Helper.h"
#import "AGIPCGridItem.h"
#import "AGIPCToolbarItem.h"
#import "Header.h"
#import "BJGridItem.h"
#import "UIView+URBMediaFocusViewController.h"
#import "UIImage+URBImageEffects.h"
#import "ShowDetailImageViewController.h"
#import "TFIndicatorView.h"
#import <CoreLocation/CoreLocation.h>
#import "ImageCell.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

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

@interface AddDongTaiViewController1 ()<UIScrollViewDelegate,
AGImagePickerControllerDelegate,
UIGestureRecognizerDelegate,
ShowDetailImageViewControllerDelegate,
UITextViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
ASIProgressDelegate>
{
    AGImagePickerController *imagePickerController;
    NSMutableArray *selectPhotosArray;
    NSMutableArray *thunImageArray;
    
    UITextView *contentTextView;
    UILabel *placeHolderLabel;
    UIButton *emitButton;
    
    UITableView *imageTableView;
    
    UIView *lateImageView;
    NSMutableArray *tmpLatelyArray;
    NSMutableArray *latelyThumImageArray;
    NSMutableArray *latelyFullImageArray;
    NSMutableDictionary *latelyImageDict;
    
    //位置
    CLLocationManager *locationManager;
    CLLocation *nowLocation;
    UIButton *locationButton;
    BOOL locationEditing;
    UITextView *locationTextView;
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    
    CGFloat keyBoardHeight;
    
    NSMutableArray *latelyImageNumArray;
    
    UIProgressView *mypro;
}
@property (nonatomic, strong) ShowDetailImageViewController *showDetailImageViewController;
@end

@implementation AddDongTaiViewController1
@synthesize classID;
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
    }
    return self;
}

#pragma mark - location

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    nowLocation = newLocation;
    //do something else
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array,NSError *error){
        if ([array count]>0) {
            CLPlacemark * placemark = [array objectAtIndex:0];
            NSString *name = placemark.name;
            locationTextView.text = name;
            latitude = newLocation.coordinate.latitude;
            longitude = newLocation.coordinate.longitude;
            
        }
    }];

}

- (void) setupLocationManager {
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        locationManager.delegate = self;
        locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }  
}

-(void)switchLocation
{
    if (locationEditing)
    {
        locationTextView.editable = NO;
        [locationButton setTitle:@"编辑" forState:UIControlStateNormal];
        [locationTextView resignFirstResponder];
    }
    else
    {
        locationTextView.editable = YES;
        [locationButton setTitle:@"完成" forState:UIControlStateNormal];
        [locationTextView becomeFirstResponder];
    }
    locationEditing = !locationEditing;
}


#pragma mark - backClick

-(void)mybackClick
{
    count = 0;
    if ([self.classZoneDelegate respondsToSelector:@selector(haveAddDonfTai:)])
    {
        [self.classZoneDelegate haveAddDonfTai:NO];
    }
    [self unShowSelfViewController];
}
#pragma mark - viewControllerLifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"发布日记";
    
    self.bgView.frame = CGRectMake(0, YSTART,
                                   UI_SCREEN_WIDTH,
                                   UI_SCREEN_HEIGHT+50);
    
    keyBoardHeight = 0.0f;
    
    imagePickerController = [[AGImagePickerController alloc] initWithDelegate:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(10, 2, 10, 2)];
    UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 7.5+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH - 62.5-8,150)];
    [contentImageView setImage:inputImage];
    [self.bgView addSubview:contentImageView];
    
    placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"请填写要发布的内容";
    placeHolderLabel.backgroundColor = [UIColor clearColor];
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    placeHolderLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:placeHolderLabel];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 17+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH - 62.5-18, 110)];
    contentTextView.delegate = self;
    contentTextView.tag = 1000;
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:contentTextView];
    
    UIButton *addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addImageButton.backgroundColor = [UIColor greenColor];
    addImageButton.frame = CGRectMake(contentTextView.frame.origin.x+5, contentTextView.frame.origin.y+contentTextView.frame.size.height, 40, 30);
    [addImageButton setImage:[UIImage imageNamed:@"icon_pic"] forState:UIControlStateNormal];
    [addImageButton addTarget:self action:@selector(openAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:addImageButton];
    
    placeHolderLabel.frame = CGRectMake(14, 19+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH - 62.5-18, 30);
    
    imageTableView = [[UITableView alloc] initWithFrame:CGRectMake(contentImageView.frame.size.width+contentImageView.frame.origin.x, contentImageView.frame.origin.y+2, 62.5, 150-4) style:UITableViewStylePlain];
    imageTableView.delegate = self;
    imageTableView.dataSource = self;
    imageTableView.backgroundColor = [UIColor clearColor];
    imageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:imageTableView];
    
    lateImageView = [[UIView alloc] initWithFrame:CGRectMake(4, contentImageView.frame.size.height+contentImageView.frame.origin.y+4, SCREEN_WIDTH-8, 120)];
    lateImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:lateImageView];
    
    UILabel *latelyLabel = [[UILabel alloc] init];
    latelyLabel.text = @"你可能想上传的照片";
    latelyLabel.backgroundColor = [UIColor clearColor];
    latelyLabel.frame = CGRectMake(lateImageView.frame.origin.x+10, lateImageView.frame.origin.y+3, 17*[latelyLabel.text length], 20);
    latelyLabel.font = [UIFont systemFontOfSize:17];
    latelyLabel.textColor = UIColorFromRGB(0x727171);
    [self.bgView addSubview:latelyLabel];
                            
    
//    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    //位置
    locationEditing = NO;
    locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(lateImageView.frame.origin.x, lateImageView.frame.origin.y+lateImageView.frame.size.height+20, 40, 40);
//    [locationButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(switchLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [self.bgView addSubview:locationButton];
    
    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y, SCREEN_WIDTH-locationButton.frame.size.width-locationButton.frame.origin.x*2, locationButton.frame.size.height)];
    [inputImageView setImage:inputImage];
    [self.bgView addSubview:inputImageView];
    
    locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(locationButton.frame.size.width+locationButton.frame.origin.x, locationButton.frame.origin.y-3, SCREEN_WIDTH-locationButton.frame.size.width-locationButton.frame.origin.x*2, locationButton.frame.size.height+3)];
    locationTextView.font = [UIFont systemFontOfSize:14];
    locationTextView.backgroundColor = [UIColor clearColor];
    locationTextView.delegate = self;
//    locationTextView.editable = NO;
    locationTextView.tag = 2000;
    locationTextView.scrollEnabled = NO;
    locationTextView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:locationTextView];
    
    //提交
    emitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emitButton.frame = CGRectMake(SCREEN_WIDTH - 60, 4, 50, 36);
    emitButton.backgroundColor = [UIColor clearColor];
    [emitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [emitButton addTarget:self action:@selector(emitClick) forControlEvents:UIControlEventTouchUpInside];
    [emitButton setTitle:@"确认" forState:UIControlStateNormal];
    [self.navigationBarView addSubview:emitButton];
    
    [self getImgs];
    
    [self setupLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        DDLOG(@"tm == %d",[tmpLatelyArray count]-i-1);
        int m = [tmpLatelyArray count]-i-1;
        if (m > 0)
        {
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            NSURL *url=[NSURL URLWithString:[tmpLatelyArray objectAtIndex:[tmpLatelyArray count]-i-1]];
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
                UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
                [latelyThumImageArray addObject:image];
                UIImage *fullImage = [self getImageFromALAssesst:asset];
                [latelyFullImageArray addObject:fullImage];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(70+5)*i, 35, 70, 70)];
                imageView.layer.cornerRadius = 5;
                imageView.clipsToBounds = YES;
                imageView.tag = 2000+i;
                [imageView setImage:image];
                [lateImageView addSubview:imageView];
                UITapGestureRecognizer *addLatelyImageTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addLatelyImage:)];
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:addLatelyImageTgr];
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
        return;
    }
    DDLOG(@"tap tag==%d",tap.view.tag);
    NSString *imageTag = [NSString stringWithFormat:@"%d",tap.view.tag];
    if ([self hasThisLatelyImage:imageTag])
    {
        [selectPhotosArray removeObject:[latelyFullImageArray objectAtIndex:tap.view.tag-2000]];
        [thunImageArray removeObject:[latelyThumImageArray objectAtIndex:tap.view.tag-2000]];
        [latelyImageNumArray removeObject:imageTag];
    }
    else
    {
        [selectPhotosArray addObject:[latelyFullImageArray objectAtIndex:tap.view.tag-2000]];
        [thunImageArray addObject:[latelyThumImageArray objectAtIndex:tap.view.tag-2000]];
        [latelyImageNumArray addObject:imageTag];
    }
    [imageTableView reloadData];
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

#pragma mark - tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [thunImageArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"imagecell";
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    [cell.deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = indexPath.row+2001;
    cell.deleteButton.backgroundColor = [UIColor clearColor];
    [cell.thumImageView setImage:[thunImageArray objectAtIndex:indexPath.row]];
    cell.thumImageView.tag = indexPath.row+1001;
    cell.thumImageView.userInteractionEnabled = YES;
    [cell.thumImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
    return cell;
}

-(void)deleteImage:(UIButton *)button
{
    [thunImageArray removeObjectAtIndex:button.tag-2001];
    [selectPhotosArray removeObjectAtIndex:button.tag-2001];
    [imageTableView reloadData];
    count--;
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    int count = [selectPhotosArray count];
    DDLOG(@"select count==%d",tap.view.tag);
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        //        DDLOG(@"url =%@",url);
        photo.image = [selectPhotosArray objectAtIndex:i]; // 图片路径
        photo.srcImageView = (UIImageView *)[imageTableView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag-1001; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

-(void)emitClick
{
    DDLOG(@"========%ld",sizeof(selectPhotosArray));
    
    [contentTextView resignFirstResponder];
    [self submitDongTai];
}

-(void)submitDongTai
{
    if ([contentTextView.text length] <= 0 && [selectPhotosArray count] <= 0)
    {
        [Tools showAlertView:@"输出您的话或添加几张图片吧！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        NSString *url = [NSString stringWithFormat:@"%@/Diaries/mbAddDiaries",HOST_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        [request setUploadProgressDelegate:mypro];
        [request setRequestMethod:@"POST"];
        [request setPostValue:[Tools client_token] forKey:@"token"];
        [request setPostValue:[Tools user_id] forKey:@"u_id"];
        [request setPostValue:classID forKey:@"c_id"];
        [request setPostValue:contentTextView.text forKey:@"content"];
        [request setTimeOutSeconds:60];
        
        if ([locationTextView.text length]>0)
        {
            [request setPostValue:locationTextView.text forKey:@"add"];
            [request setPostValue:[NSString stringWithFormat:@"%f",latitude] forKey:@"lat"];
            [request setPostValue:[NSString stringWithFormat:@"%f",longitude] forKey:@"lng"];
        }
        long total = 0.0f;
        for (int i=0; i<[selectPhotosArray count]; ++i)
        {
            UIImage *image = [selectPhotosArray objectAtIndex:i];
            image = [Tools thumbnailWithImageWithoutScale:image size:[self sizeWithImage:image]];
            DDLOG(@"image size = %@",NSStringFromCGSize(image.size));
            NSData *imageData = UIImagePNGRepresentation(image);
            total += [imageData length];
            
            [request addData:imageData withFileName:[NSString stringWithFormat:@"%d.png",i+1] andContentType:@"image/png" forKey:[NSString stringWithFormat:@"file%d",i+1]];
        }
        DDLOG(@"size======%ld",total);
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
                }
                emitButton.enabled = YES;
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

-(CGSize)sizeWithImage:(UIImage *)image
{
    CGFloat imageHeight = 0.0f;
    CGFloat imageWidth = 0.0f;
    CGFloat times = 1;
    if (image.size.width>SCREEN_WIDTH*times || image.size.height>SCREEN_HEIGHT*times)
    {
        if (image.size.width>SCREEN_WIDTH*1.5)
        {
            imageWidth = SCREEN_WIDTH*times;
            imageHeight = imageWidth*image.size.height/image.size.width;
        }
        else
        {
            imageHeight = SCREEN_HEIGHT*times;
            imageWidth = imageHeight*image.size.width/image.size.height;
        }
    }
    else
    {
        imageWidth = image.size.width;
        imageHeight = image.size.height;
    }
    return CGSizeMake(imageWidth, imageHeight);
}

-(void)unShowSelfViewController
{
    [super unShowSelfViewController];
}

-(void)selfBackClick
{
    count = 0;
    [self unShowSelfViewController];
}

#pragma mark - textViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView.tag == 2000)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-keyBoardHeight);
            
        }completion:^(BOOL finished) {
        }];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [contentTextView resignFirstResponder];
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
            placeHolderLabel.text = @"请填写要发布的内容";
        }
        else if([textView.text length] > 140)
        {
            [Tools showAlertView:@"字数不能超过140个字" delegateViewController:nil];
        }
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in self.bgView.subviews)
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
        self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y+25);
    }completion:^(BOOL finished) {
        locationTextView.editable = NO;
        locationEditing = NO;
        [locationButton setTitle:@"编辑" forState:UIControlStateNormal];
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (iPhone5)
    {
        //            self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height+150);
        keyBoardHeight = height-150;
    }
    else
    {
        //            self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height);
        keyBoardHeight = height;
    }
}


#pragma mark - AGIImagePickerController

-(UIImage *)getImageFromALAssesst:(ALAsset *)asset
{
    ALAssetRepresentation *assetPresentation = [asset defaultRepresentation];
    
    CGImageRef imageRef = [assetPresentation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    if (image.size.width>SCREEN_WIDTH*2 || image.size.height>SCREEN_HEIGHT*2)
    {
        CGFloat imageHeight = 0.0f;
        CGFloat imageWidth = 0.0f;
        if (image.size.width>SCREEN_WIDTH*2)
        {
            imageWidth = SCREEN_WIDTH*2;
            imageHeight = imageWidth*image.size.height/image.size.width;
        }
        else
        {
            imageHeight = SCREEN_HEIGHT*2;
            imageWidth = imageHeight*image.size.width/image.size.height;
        }
        DDLOG(@"%.1f==%.1f++%.1f==%.1f",imageWidth,imageHeight,image.size.width,image.size.height);
        image = [Tools thumbnailWithImageWithoutScale:image size:CGSizeMake(imageWidth, imageHeight)];
        
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",tmpDir,assetPresentation.filename];
    [data writeToFile:filePath atomically:YES];
    return image;
}


- (void)openAction:(id)sender
{
    DDLOG(@"count in openaction %d",count);
    if (count >= 12)
    {
        [Tools showAlertView:@"图片不能多于7张,请删除后重新添加" delegateViewController:nil];
        return;
    }
    // Show saved photos on top
    imagePickerController.shouldShowSavedPhotosOnTop = NO;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    imagePickerController.toolbarItemsForManagingTheSelection = @[];
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error
{
    NSLog(@"Fail. Error: %@", error);
    [((XDContentViewController *)self.parentViewController.parentViewController).sideMenuController setPanGestureEnabled:NO];
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
    
    
    if ([info count]+count  > 12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        return;
    }
    
    if ([info count] > 12)
    {
        [Tools showAlertView:@"最多添加12张图片" delegateViewController:nil];
        return;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    for (int i=0;i<([info count]>7 ? 7:[info count]);++i)
    {
        
        ALAsset *asset = [info objectAtIndex:i];
        
        UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        
        [thunImageArray addObject:image];
        
        UIImage *fullScreenImage = [self getImageFromALAssesst:asset];
        if (fullScreenImage.size.width>SCREEN_WIDTH*2 || image.size.height>SCREEN_HEIGHT*2)
        {
            CGFloat imageHeight = 0.0f;
            CGFloat imageWidth = 0.0f;
            if (fullScreenImage.size.width>SCREEN_WIDTH*2)
            {
                imageWidth = SCREEN_WIDTH*2;
                imageHeight = imageWidth*image.size.height/image.size.width;
            }
            else
            {
                imageHeight = SCREEN_HEIGHT*2;
                imageWidth = imageHeight*image.size.width/image.size.height;
            }
        }
        
        [selectPhotosArray addObject:fullScreenImage];
        count ++;
    }
    [imageTableView reloadData];
    [((XDContentViewController *)self.parentViewController).sideMenuController setPanGestureEnabled:NO];
}

-(void)showDetailImage:(UIButton *)button
{
    UIView *fromView = [[UIView alloc] initWithFrame:CGRectMake(marginspace + (gridWith+5)*(button.tag%4), marginspace+(gridHight+betweenspace)*(button.tag/4), gridWith, gridHight)];
    [self.showDetailImageViewController showImage:[selectPhotosArray objectAtIndex:button.tag] fromView:fromView withView:self.bgView];
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
