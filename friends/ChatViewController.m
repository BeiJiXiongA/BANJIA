//
//  ChatViewController.m
//  School
//
//  Created by TeekerZW on 14-3-4.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ChatViewController.h"
#import "Header.h"
#import "MessageCell.h"
#import "Base64.h"
#import "AppDelegate.h"
#import "OperatDB.h"
#import "InputTableBar.h"
#import "ClassZoneViewController.h"


#define DIRECT  @"direct"
#define TYPE    @"msgType"
#define TEXTMEG  @"text"
#define IMAGEMSG  @"image"

#define Image_H 180
#define additonalH  90


@interface ChatViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
ChatDelegate,
ReturnFunctionDelegate>
{
    NSMutableArray *messageArray;
    UITableView *messageTableView;
    
    UIImagePickerController *imagePickerController;
    UIButton*editButton;
    BOOL edittingTableView;
    
    InputTableBar *inputTabBar;
    
    OperatDB *db;
    
    UIImage *fromImage;
    UIImage *toImage;
    
    NSInteger currentSec;
    
    CGFloat tmpheight;
    
    CGSize inputSize;
    
    CGFloat faceViewHeight;
    
    BOOL iseditting;
    
    UIImage *fromHeaderImage;
}
@end

@implementation ChatViewController
@synthesize name,toID,imageUrl,chatVcDel;
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
    self.titleLabel.text = name;
        
    db = [[OperatDB alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    currentSec = 0;
    iseditting = NO;
    
    faceViewHeight = 0;
    
    inputSize = CGSizeMake(250, 30);
    
    self.bgView.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, SCREEN_HEIGHT+200);
    
    fromImage = [Tools getImageFromImage:[UIImage imageNamed:@"f"] andInsets:UIEdgeInsetsMake(35, 40, 17, 40)];
    toImage = [Tools getImageFromImage:[UIImage imageNamed:@"t"] andInsets:UIEdgeInsetsMake(35, 40, 17, 40)];
    
    if (imageUrl)
    {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGEURL,imageUrl];
        
        NSString *key = [urlStr MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        fromHeaderImage = [UIImage imageWithData:data];
    }
    else
    {
        fromHeaderImage = [UIImage imageNamed:HEADERBG];
    }
   
    
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:editButton];
    
    messageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40) style:UITableViewStylePlain];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.backgroundColor = [UIColor clearColor];
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:messageTableView];
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-20, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor whiteColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.layer.anchorPoint = CGPointMake(0.5, 1);
    [self.bgView addSubview:inputTabBar];
    if ([Tools NetworkReachable])
    {
        [self getChatLog];
    }
    else
    {
        [self dealNewChatMsg:nil];
    }
    [self dealNewChatMsg:nil];
    [self.backButton addTarget:self action:@selector(myBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    [MobClick beginLogPageView:@"PageOne"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    
    inputTabBar.returnFunDel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:inputTabBar];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
}

-(void)myBackButtonClick
{
    [self uploadLastViewTime];
    [self unShowSelfViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getchatlog
-(void)getChatLog
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID,
                                                                      } API:GETCHATLOG];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat=log=responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                    NSArray *array = [[NSArray alloc] initWithArray:[responseDict objectForKey:@"data"]];
                    for (int i=0; i<[array count]; ++i)
                    {
                        NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSDictionary *dict = [array objectAtIndex:i];
                        [chatDict setObject:[dict objectForKey:@"_id"] forKey:@"mid"];
                        [chatDict setObject:[Tools user_id] forKey:@"userid"];
                        [chatDict setObject:[dict objectForKey:@"by"] forKey:@"fid"];
                        [chatDict setObject:[dict objectForKey:@"msg"] forKey:@"content"];
                        [chatDict setObject:[NSString stringWithFormat:@"%f",[[dict objectForKey:@"t"] floatValue]] forKey:@"time"];
                        [chatDict setObject:imageUrl?imageUrl:@"" forKey:@"ficon"];
                        [chatDict setObject:@"1" forKey:@"readed"];
                        [chatDict setObject:TEXTMEG forKey:@"msgType"];
                        if ([[dict objectForKey:@"by"] isEqualToString:[Tools user_id]])
                        {
                            [chatDict setObject:toID forKey:@"tid"];
                            [chatDict setObject:[Tools user_name] forKey:@"fname"];
                            [chatDict setObject:@"t" forKey:@"direct"];
                        }
                        else if([[dict objectForKey:@"by"] isEqualToString:toID])
                        {
                            [chatDict setObject:[Tools user_id] forKey:@"tid"];
                            [chatDict setObject:name forKey:@"fname"];
                            [chatDict setObject:@"f" forKey:@"direct"];
                        }
                        
                        NSArray *dataMsgArray = [db findSetWithKey:@"mid" andValue:[dict objectForKey:@"_id"] andTableName:@"chatMsg"];
                        if ([dataMsgArray count] <= 0)
                        {
                            [db insertRecord:chatDict andTableName:@"chatMsg"];
                        }
                        else if ([[[dataMsgArray firstObject] objectForKey:@"content"] isEqualToString:@"您有一条新的邀请"]||
                                 [[[dataMsgArray firstObject] objectForKey:@"content"] isEqualToString:@"您有一条新的消息"])
                        {
                            [db deleteRecordWithDict:@{@"mid":[dict objectForKey:@"_id"]} andTableName:CHATTABLE];
                            [db insertRecord:chatDict andTableName:@"chatMsg"];
                        }
                    }
                    [self dealNewChatMsg:nil];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }

}

#pragma mark - lastViewTime
-(void)uploadLastViewTime
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID
                                                                      } API:LASTVIEWTIME];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                
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

#pragma mark - returnfunctionDelegate
-(void)myReturnFunction
{
    if (inputTabBar.inputTextView.text.length == 0)
    {
        [Tools showAlertView:@"消息不能为空！" delegateViewController:nil];
        return ;
    }
    if ([inputTabBar.inputTextView.text length]>0)
    {
        inputSize = CGSizeMake(250, 30);
//        [self backInput];
        [self sendMsgWithString:[inputTabBar analyString:inputTabBar.inputTextView.text]];
    }
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
        if (messageTableView.contentSize.height>tmpheight)
        {
            messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+keyBoardHeight);
        }
        iseditting = YES;
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        faceViewHeight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-FaceViewHeight-10, SCREEN_WIDTH, 40 + FaceViewHeight);
    }
    else if([changeType isEqualToString:@"key"])
    {
        faceViewHeight = 0;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-tmpheight-10, SCREEN_WIDTH, 40 + FaceViewHeight);
    }
    iseditting = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [inputTabBar backKeyBoard];
    if (iseditting)
    {
        [self backInput];
    }
    
}
-(void)backInput
{
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        messageTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-inputSize.height-10);
        if (messageTableView.contentSize.height>SCREEN_HEIGHT-80)
        {
           messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height);
        }
        else
        {
            messageTableView.contentOffset = CGPointZero;
        }
        iseditting = NO;
    }];
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+faceViewHeight);
        
        if (messageTableView.contentSize.height>tmpheight)
        {
            if (inputSize.height>30)
            {
                messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight+inputSize.height-40);
            }
        }
    }];
}
#pragma mark - chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [messageArray removeAllObjects];
    [messageArray addObjectsFromArray:[db findChatLogWithUid:[Tools user_id] andOtherId:toID andTableName:@"chatMsg"]];
    DDLOG(@"dict = %@",dict);
    if ([[dict objectForKey:@"content"] isEqualToString:@"您有一条新的邀请"]||
        [[dict objectForKey:@"content"] isEqualToString:@"您有一条新的消息"])
    {
        [self getChatLog];
    }
    else
    {
        for (int i=0; i<[messageArray count]; ++i)
        {
            NSDictionary *tmpDict = [messageArray objectAtIndex:i];
            [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[tmpDict objectForKey:@"fid"],@"userid":[Tools user_id]} andTableName:@"chatMsg"];
        }
        
        [messageTableView reloadData];
    }
    
    if (messageTableView.contentSize.height>messageTableView.frame.size.height)
    {
        messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight);
    }
    if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
    {
        [self.chatVcDel updateChatList:YES];
    }
}

#pragma mark - takepicture

-(void)takePicture:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册获取", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"相机不可用！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [al show];
        }
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else if(buttonIndex == 1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
//        UIImage *originaImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//        CGSize size = [self sizeWithImage:originaImage];
//        UIImage *image = [Tools thumbnailWithImageWithoutScale:originaImage size:CGSizeMake(size.width*3, size.height*3)];
//        NSData *imageData = UIImagePNGRepresentation(image);
        
//        NSString *imageStr = [NSString stringWithFormat:@"imag%@",[Base64 stringByEncodingData:imageData]];
        
    }];
    
}

#pragma mark - sizeabout
-(CGSize)sizeWithImage:(UIImage *)image
{
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    //    DDLOG(@" imageWidth %.0f imageHeight %.0f",imageWidth,imageHeight);
    
    if (imageWidth >= SCREEN_WIDTH && imageHeight >=Image_H)
    {
        if (imageHeight >= imageWidth)
        {
            height = Image_H;
            width = height*imageWidth/imageHeight;
        }
        else if(imageWidth >= imageHeight)
        {
            width = SCREEN_WIDTH-80;
            height = imageHeight*width/imageWidth;
        }
    }
    else if(imageHeight >= Image_H)
    {
        height = Image_H;
        width = height*imageWidth/imageHeight;
    }
    else if(imageWidth >= SCREEN_WIDTH)
    {
        width = SCREEN_WIDTH-80;
        height = imageHeight*width/imageWidth;
    }
    else
    {
        width = imageWidth;
        height = imageHeight;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}
-(CGSize)sizeWithText:(NSString *)string
{
    if ([string length]>=11)
    {
        CGSize labsize = [string sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(self.view.frame.size.width-130, 9999) lineBreakMode:NSLineBreakByWordWrapping];
        return labsize;
    }
    else
        return CGSizeMake([string length]*18, 20);
}


#pragma mark - tableview

-(void)editTableView
{
    if (edittingTableView)
    {
        messageTableView.editing = NO;
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else
    {
        messageTableView.editing = YES;
        [editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    edittingTableView = !edittingTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    CGSize size = [self sizeWithText:[[messageArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
    rowHeight = size.height+50;
    if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        NSString *msgContent = [dict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        msgContent = [msgContent substringFromIndex:range.location+range.length];
        size = [self sizeWithText:msgContent];
        rowHeight = size.height+70;
    }
    if (ABS([[dict objectForKey:@"time"] integerValue] - currentSec) < 60*3)
    {
        DDLOG(@"++++++%d",ABS([[dict objectForKey:@"time"] integerValue] - currentSec));
        DDLOG(@"content=%@",[dict objectForKey:@"content"]);
    }
    else
    {
        currentSec = [[dict objectForKey:@"time"] integerValue];
    }
    return rowHeight+20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCell = @"messageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell];
    if (cell == nil)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCell];
    }
    
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    CGFloat messageBgY = 30;
    CGFloat messageTfY = 5;
    CGSize size = [self  sizeWithText:[[dict objectForKey:@"content"] emojizedString]];
    cell.chatBg.hidden = NO;
    
    cell.button.hidden = YES;
    cell.joinlable.hidden = YES;
    cell.timeLabel.hidden = NO;
    
    cell.messageTf.hidden = NO;
    cell.messageTf.backgroundColor = [UIColor clearColor];
    cell.messageTf.font = [UIFont systemFontOfSize:16];
    
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        if ([[dict objectForKey:TYPE] isEqualToString:TEXTMEG])
        {
            cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            cell.timeLabel.text = timeStr;
            
            cell.chatBg.frame = CGRectMake(55, messageBgY-10, size.width+20, size.height+20);
            [cell.chatBg setImage:fromImage];
            
            CGFloat he = 0;
            if (SYSVERSION>=7)
            {
                he = 3;
            }
            
            cell.messageTf.frame = CGRectMake(cell.chatBg.frame.origin.x + 10,cell.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+10+he);
            cell.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                cell.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                
                size = [self sizeWithText:[[msgContent substringFromIndex:range.location+range.length] emojizedString]];
               
                cell.messageTf.frame = CGRectMake(cell.chatBg.frame.origin.x + 10,cell.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+10+he);

                cell.button.frame = cell.chatBg.frame;
                [cell.button addTarget:self action:@selector(joinClass:) forControlEvents:UIControlEventTouchUpInside];
                cell.backgroundColor = [UIColor clearColor];
                cell.button.tag = 5555+indexPath.row;
                cell.button.hidden = NO;
                
                cell.chatBg.frame = CGRectMake(55, messageBgY-10, size.width+20, size.height+20+30);
                
                UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(joinClass:)];
                
                cell.chatBg.tag = 5555+indexPath.row;
                cell.chatBg.userInteractionEnabled = YES;
                [cell.chatBg addGestureRecognizer:msgTap];
                
                cell.messageTf.backgroundColor = [UIColor clearColor];
                cell.messageTf.tag = 5555+indexPath.row;
                cell.messageTf.userInteractionEnabled = YES;
                [cell.messageTf addGestureRecognizer:msgTap];

                cell.joinlable.frame = CGRectMake(15, cell.chatBg.frame.size.height-35, size.width, 30);
                cell.joinlable.text = @"点击申请加入";
                cell.joinlable.hidden = NO;
                
                cell.joinlable.userInteractionEnabled = YES;
                cell.joinlable.tag = 5555+indexPath.row;
                [cell.joinlable addGestureRecognizer:msgTap];
            }
            else
            {
                cell.button.hidden = YES;
            }
            
            cell.headerImageView.frame = CGRectMake(5, messageBgY, 40, 40);
            if (ABS([[dict objectForKey:@"time"] integerValue] - currentSec) > 60*3)
            {
                cell.timeLabel.hidden = NO;
                currentSec = [[dict objectForKey:@"time"] integerValue];
            }
            else
            {
                cell.timeLabel.hidden = YES;
            }
            
            if (![imageUrl isEqual:[NSNull null]])
            {
                if ([imageUrl length] > 10)
                {
                    [Tools fillImageView:cell.headerImageView withImageFromURL:imageUrl andDefault:HEADERBG];
                }
                else
                {
                    [cell.headerImageView setImage:[UIImage imageNamed:HEADERBG]];
                }
            }
        }
    }
    else if([[dict objectForKey:DIRECT] isEqualToString:@"t"])
    {
        if ([[dict objectForKey:TYPE] isEqualToString:TEXTMEG])
        {
            cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            cell.timeLabel.text = timeStr;
            
            CGFloat x=7;
            if([[Tools device_version] integerValue] >= 7.0)
            {
                x=0;
            }
            
            cell.chatBg.frame = CGRectMake(self.view.frame.size.width - 10-size.width-30-45, messageBgY-10, size.width+20, size.height+20);
            [cell.chatBg setImage:toImage];
            
            cell.messageTf.frame = CGRectMake(cell.chatBg.frame.origin.x+ 5-x,cell.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+20);
            cell.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.button.hidden = YES;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                cell.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                size = [self sizeWithText:[[msgContent substringFromIndex:range.location+range.length] emojizedString]];
                cell.chatBg.frame = CGRectMake(self.view.frame.size.width - 10-size.width-30-45, messageBgY, size.width+20, size.height+20);
                cell.messageTf.frame = CGRectMake(cell.chatBg.frame.origin.x+ 10-x,cell.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+30);
            }
            cell.headerImageView.frame = CGRectMake(SCREEN_WIDTH - 60, messageBgY, 40, 40);
            if (ABS([[dict objectForKey:@"time"] integerValue] - currentSec) > 60*3)
            {
                cell.timeLabel.hidden = NO;
                currentSec = [[dict objectForKey:@"time"] integerValue];
            }
            else
            {
                cell.timeLabel.hidden = YES;
            }
            [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERBG];
        }
    }
    cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
    cell.headerImageView.clipsToBounds = YES;
    if (indexPath.row == 0)
    {
        cell.timeLabel.hidden = NO;
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iseditting)
    {
        [inputTabBar backKeyBoard];
        [self backInput];
    }
}

-(BOOL)isInThisClass:(NSString *)classId
{
    NSString *key = [TAGSARRAYKEY MD5Hash];
    NSData *tagsData = [FTWCache objectForKey:key];
    NSString *tagsString = [[NSString alloc] initWithData:tagsData encoding:NSUTF8StringEncoding];
    
    NSArray *tagsArray = [tagsString componentsSeparatedByString:@","];
    for (int i=0; i<[tagsArray count]; ++i)
    {
        if ([classId isEqualToString:[tagsArray objectAtIndex:i]])
        {
            return YES;
        }
    }
    return NO;
}

-(void)joinClass:(UITapGestureRecognizer *)button
{
    NSString *msgContent = [[messageArray objectAtIndex:button.view.tag-5555] objectForKey:@"content"];
    NSRange range1 = [msgContent rangeOfString:@"$!#"];
    NSRange range2 = [msgContent rangeOfString:@"["];
    NSRange range3 = [msgContent rangeOfString:@"—"];
    NSRange range4 = [msgContent rangeOfString:@"]"];
    NSRange range5 = [msgContent rangeOfString:@"("];
    NSString *classID = [msgContent substringToIndex:range1.location];
    
    if ([self isInThisClass:classID])
    {
        [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
        return;
    }
    
    NSString *schoolName;
    if (range2.length >0 && range5.length > 0)
    {
        schoolName = [msgContent substringWithRange:NSMakeRange(range2.location+1,range5.location-range2.location-1)];
    }
    
    NSString *className;
    if (range3.length>0 && range4.length>0)
    {
        className = [msgContent substringWithRange:NSMakeRange(range3.location+1, range4.location-range3.location-1)];
    }
    
    ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
    classZone.fromClasses = YES;
    classZone.classID = classID;
    classZone.schoolName = schoolName;
    classZone.className = className;
    [classZone showSelfViewController:self];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    [db deleteRecordWithDict:dict andTableName:@"chatMsg"];
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    DDLOG(@"dict == %@",dict);
    [self dealNewChatMsg:nil];
}

#pragma mark - sendMsg
-(void)sendMsgWithString:(NSString *)msgContent
{
    if ([Tools NetworkReachable])
    {
        NSDate *date = [NSDate date];
        NSTimeInterval timeinterval = [date timeIntervalSince1970];
        NSString *str = [NSString stringWithFormat:@"%@%.0f",[Tools user_id],timeinterval];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *messageID = [data base64Encoding];
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID,
                                                                      @"m_id":messageID,
                                                                      @"content":msgContent
                                                                      } API:CREATE_CHAT_MSG];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [chatDict setObject:messageID forKey:@"mid"];
                [chatDict setObject:msgContent forKey:@"content"];
                [chatDict setObject:[Tools user_id] forKey:@"userid"];
                [chatDict setObject:[Tools user_id] forKey:@"fid"];
                [chatDict setObject:[Tools user_name] forKey:@"fname"];
                [chatDict setObject:@"null" forKey:@"ficon"];
                [chatDict setObject:[NSString stringWithFormat:@"%d",[[responseDict objectForKey:@"data"] integerValue]] forKey:@"time"];
                [chatDict setObject:@"t" forKey:@"direct"];
                [chatDict setObject:@"text" forKey:@"msgType"];
                [chatDict setObject:toID forKey:@"tid"];
                [chatDict setObject:@"1" forKey:@"readed"];
                if ([[db findSetWithKey:@"mid" andValue:messageID andTableName:@"chatMsg"] count] <= 0)
                {
                    [db insertRecord:chatDict andTableName:@"chatMsg"];
                }
                if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
                {
                    [self.chatVcDel updateChatList:YES];
                }
                [self dealNewChatMsg:nil];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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

@end
