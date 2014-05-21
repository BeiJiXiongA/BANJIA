//
//  AuthViewController.m
//  School
//
//  Created by TeekerZW on 14-2-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AuthViewController.h"
#import "Header.h"

@interface AuthViewController ()<UITextFieldDelegate,UIActionSheetDelegate>
{
    MyTextField *nameTextField;
    UIImageView *idCardImageView;
    UIImageView *competenceImageView;
    NSString *imageUsed;
    UIView *selectImageView;
    
    UIImage *idImage;
    UIImage *componentImage;
    
    NSMutableArray *imageArray;
}
@end

@implementation AuthViewController
@synthesize img_id,img_tcard;
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
    
    self.titleLabel.text = @"教师认证";
    imageUsed = @"";
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setTitle:@"提交" forState:UIControlStateNormal];
    [setButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    setButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [setButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:setButton];
    if ([img_tcard length] > 10 || [img_id length] > 10)
    {
        setButton.hidden = YES;
    }
    
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, 60, 30)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.text = @"姓名：";
    nameLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:nameLabel];
    
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width, nameLabel.frame.origin.y, 200, 35)];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.delegate = self;
    nameTextField.enabled = NO;
    nameTextField.text = [Tools user_name];
    nameTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:nameTextField];
    
    UILabel *idCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, nameLabel.frame.size.height+nameLabel.frame.origin.y+20, 100, 30)];
    idCardLabel.backgroundColor = [UIColor clearColor];
    idCardLabel.font = [UIFont systemFontOfSize:16];
    idCardLabel.text = @"身份证照片：";
    idCardLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:idCardLabel];
    
    idCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(idCardLabel.frame.size.width+idCardLabel.frame.origin.x+10, nameLabel.frame.origin.y+nameLabel.frame.size.height+20, 150, 100)];
    idCardImageView.backgroundColor = [UIColor whiteColor];
    idCardImageView.layer.cornerRadius = 2;
    idCardImageView.layer.masksToBounds = YES;
    idCardImageView.userInteractionEnabled = YES;
    [self.bgView addSubview:idCardImageView];
    
    if ([img_id length] > 10)
    {
        [Tools fillImageView:idCardImageView withImageFromURL:img_id andDefault:nil];
    }
    
    UITapGestureRecognizer *idCardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeIDCardImage)];
    [idCardImageView addGestureRecognizer:idCardGestureRecognizer];
    
    UILabel *competenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, idCardImageView.frame.size.height+idCardImageView.frame.origin.y+20, 100, 30)];
    competenceLabel.backgroundColor = [UIColor clearColor];
    competenceLabel.font = [UIFont systemFontOfSize:16];
    competenceLabel.text = @"教师证照片：";
    competenceLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:competenceLabel];
    
    competenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(competenceLabel.frame.size.width+competenceLabel.frame.origin.x+10, idCardImageView.frame.origin.y+idCardImageView.frame.size.height+20, 150, 100)];
    competenceImageView.backgroundColor = [UIColor whiteColor];
    competenceImageView.layer.cornerRadius = 2;
    competenceImageView.userInteractionEnabled = YES;
    competenceImageView.layer.masksToBounds = YES;
    [self.bgView addSubview:competenceImageView];
    
    if ([img_tcard length] > 10)
    {
        [Tools fillImageView:competenceImageView withImageFromURL:img_tcard andDefault:nil];
    }
    
    UITapGestureRecognizer *competenceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCompetenceImage)];
    [competenceImageView addGestureRecognizer:competenceGestureRecognizer];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
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

-(void)submit
{
    if (idImage && componentImage)
    {
        [self uploadImage:idImage used:@"img_id"];
        [self uploadImage:componentImage used:@"img_tcard"];
    }
    else if(!idImage)
    {
        [Tools showAlertView:@"请添加身份证" delegateViewController:nil];
        return ;
    }
    else if(!componentImage)
    {
        [Tools showAlertView:@"请添加教师资格证" delegateViewController:nil];
        return ;
    }
}

-(void)changeCompetenceImage
{
    if ([img_tcard length] > 10)
    {
        [Tools showAlertView:@"正在审核中" delegateViewController:nil];
        return;
    }
    imageUsed = @"img_tcard";
    [self selectImage];
}

-(void)changeIDCardImage
{
    if ([img_id length] > 10)
    {
        [Tools showAlertView:@"正在审核中" delegateViewController:nil];
        return;
    }
    imageUsed = @"img_id";
    [self selectImage];
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

-(void)selectImage
{
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"相机", nil];
    [ac showInView:self.bgView];
}

-(void)selectPicture:(NSInteger)buttonIndex
{
    if (buttonIndex == 1000)
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
    else if(buttonIndex == 1001)
    {
        //相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

-(void)cancelSelectImage
{
    [selectImageView removeFromSuperview];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self cancelSelectImage];
    [imageArray removeAllObjects];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
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
        image = [Tools thumbnailWithImageWithoutScale:image size:CGSizeMake(imageWidth, imageHeight)];
    }

    [imageArray addObject:image];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    if ([imageUsed isEqualToString:@"img_tcard"])
    {
        componentImage = image;
        [competenceImageView setImage:image];
    }
    else if([imageUsed isEqualToString:@"img_id"])
    {
        idImage = image;
        [idCardImageView setImage:image];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadImage:(UIImage *)image used:(NSString *)imgUsed
{
    if ([Tools NetworkReachable])
    {
        UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] init];
        indi.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        if ([imgUsed isEqualToString:@"img_tcard"])
        {
            indi.frame = CGRectMake(competenceImageView.frame.origin.x+competenceImageView.frame.size.width/2-20, competenceImageView.frame.origin.y+competenceImageView.frame.size.height/2-20, 40, 40);
        }
        else if([imgUsed isEqualToString:@"img_id"])
        {
            indi.frame = CGRectMake(idCardImageView.frame.origin.x+idCardImageView.frame.size.width/2-20, idCardImageView.frame.origin.y+idCardImageView.frame.size.height/2-20, 40, 40);
        }
        [self.bgView addSubview:indi];
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETUSERIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":imgUsed}];
        [request setCompletionBlock:^{
            [indi stopAnimating];
            [indi removeFromSuperview];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([imgUsed isEqualToString:@"img_tcard"])
                {
                    [competenceImageView setImage:image];
                    [Tools showTips:@"教师资格证上传成功" toView:self.bgView];
                }
                else if ([imgUsed isEqualToString:@"img_id"])
                {
                    [idCardImageView setImage:image];
                    [Tools showTips:@"身份证上传成功" toView:self.bgView];
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

@end
