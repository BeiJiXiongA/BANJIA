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
    UITextField *nameTextField;
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
    [setButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    setButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [setButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:setButton];
    
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, 60, 30)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.text = @"姓名：";
    nameLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:nameLabel];
    
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width, nameLabel.frame.origin.y, 200, 30)];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.delegate = self;
    nameTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.font = [UIFont systemFontOfSize:14];
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
    idCardImageView.image = [UIImage imageNamed:@""];
    [self.bgView addSubview:idCardImageView];
    
    UITapGestureRecognizer *idCardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeIDCardImage)];
    idCardImageView.userInteractionEnabled = YES;
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
    competenceImageView.layer.masksToBounds = YES;
    competenceImageView.image = [UIImage imageNamed:@""];
    [self.bgView addSubview:competenceImageView];
    
    UITapGestureRecognizer *competenceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCompetenceImage)];
    competenceImageView.userInteractionEnabled = YES;
    [competenceImageView addGestureRecognizer:competenceGestureRecognizer];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submit
{
    if (!idImage || !componentImage)
    {
        if (idImage)
        {
            [self uploadImage:idImage used:@"img_id"];
        }
        if (componentImage)
        {
            [self uploadImage:componentImage used:@"img_tcard"];
        }
    }
    else
    {
        [Tools showAlertView:@"请选择身份证或教师资格证" delegateViewController:nil];
        return ;
    }
}

-(void)changeCompetenceImage
{
    imageUsed = @"img_tcard";
    [self selectImage];
}

-(void)changeIDCardImage
{
    imageUsed = @"img_id";
    [self selectImage];
}

-(void)selectImage
{
//    selectImageView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0)];
//    selectImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
//    [self.bgView addSubview:selectImageView];
//    
//    UITapGestureRecognizer *cancelSelectImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectImage)];
//    selectImageView.userInteractionEnabled = YES;
//    [selectImageView addGestureRecognizer:cancelSelectImage];
//    
//    UIButton *cancelSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancelSelectButton.backgroundColor = [UIColor grayColor];
//    [cancelSelectButton setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelSelectButton addTarget:self action:@selector(cancelSelectImage) forControlEvents:UIControlEventTouchUpInside];
//    [selectImageView addSubview:cancelSelectButton];
//    
//    UIButton *takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    takePictureButton.backgroundColor = [UIColor whiteColor];
//    takePictureButton.tag = 1000;
//    [takePictureButton addTarget:self action:@selector(selectPicture:) forControlEvents:UIControlEventTouchUpInside];
//    [takePictureButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [takePictureButton setTitle:@"拍照" forState:UIControlStateNormal];
//    [selectImageView addSubview:takePictureButton];
//    
//    UIButton *fromLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    fromLibraryButton.backgroundColor = [UIColor whiteColor];
//    fromLibraryButton.tag = 1001;
//    [fromLibraryButton addTarget:self action:@selector(selectPicture:) forControlEvents:UIControlEventTouchUpInside];
//    [fromLibraryButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [fromLibraryButton setTitle:@"从相册选取" forState:UIControlStateNormal];
//    [selectImageView addSubview:fromLibraryButton];
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        selectImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        cancelSelectButton.frame = CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT - 50, 200, 30);
//        takePictureButton.frame = CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT - 90, 200, 30);
//        fromLibraryButton.frame = CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT-130, 200, 30);
//    }];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"", nil];
    [ac showInView:self.bgView];
}

-(void)selectPicture:(UIButton *)button
{
    if (button.tag == 1000)
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
    else if(button.tag == 1001)
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
        if ([imgUsed isEqualToString:@"img_tcard"])
        {
            indi.frame = CGRectMake(competenceImageView.frame.origin.x+competenceImageView.frame.size.width/2-20, competenceImageView.frame.origin.y+competenceImageView.frame.size.height/2-20, 40, 40);
        }
        else if([imgUsed isEqualToString:@"img_id"])
        {
            indi.frame = CGRectMake(idCardImageView.frame.origin.x+idCardImageView.frame.size.width/2-20, idCardImageView.frame.origin.y+idCardImageView.frame.size.height/2-20, 40, 40);
        }
        
        indi .activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.bgView addSubview:indi];
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETUSERIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":imageUsed}];
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
                    [competenceImageView setImage:[imageArray firstObject]];
                }
                else if ([imgUsed isEqualToString:@"img_id"])
                {
                    [idCardImageView setImage:[imageArray firstObject]];
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
