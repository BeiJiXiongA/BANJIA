//
//  Tools.m
//  XMPP1106
//
//  Created by mac120 on 13-11-11.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "Tools.h"
#import "WelcomeViewController.h"
#import "ChineseToPinyin.h"
#import <AVFoundation/AVFoundation.h>
#import "KKNavigationController.h"
#import "UIImageView+MJWebCache.h"

extern NSString *CTSettingCopyMyPhoneNumber();


@implementation Tools

+ (NSDictionary *)JSonFromString:(NSString* )result
{
    NSDictionary *json = [result objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    return json;
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
+ (void) fillButtonView:(UIButton *)button withImageFromURL:(NSString*)URL andDefault:(NSString *)defaultName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGEURL,URL];
    NSURL *imageURL = [NSURL URLWithString:urlStr];
    [button setImage:[UIImage imageNamed:defaultName] forState:UIControlStateNormal];
    [button setImageWithURL:imageURL forState:UIControlStateNormal];
}

+ (void) fillImageView:(UIImageView *)imageView withImageFromURL:(NSString*)URL andDefault:(NSString *)defaultName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGEURL,URL];
    NSURL *imageURL = [NSURL URLWithString:urlStr];
    [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:defaultName]];
}

//+(void)setHeaderImageView;

+ (void) fillImageView:(UIImageView *)imageView withImageFromURL:(NSString*)URL imageWidth:(CGFloat)imageWidth andDefault:(NSString *)defaultName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@@%.0fw%@",IMAGEURL,[URL substringToIndex:[URL length]-4],imageWidth,[URL substringFromIndex:[URL rangeOfString:@"."].location]];
    NSURL *imageURL = [NSURL URLWithString:urlStr];
    DDLOG(@"image url %@",imageURL.absoluteString);
    [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:defaultName]];
}
+(BOOL)isPhoneNumber:(NSString *)numStr
{
//    NSString *mobileNum = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString *mobileNum = @"^1(3[0-9]|5[0-35-9]|8[025-9]|10|70)\\d{8}$";
    NSPredicate *mobilePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobileNum];
    return [mobilePredicate evaluateWithObject:numStr];
}

+(NSString *)getPhoneNumFromString:(NSString *)numStr
{
    NSMutableString *tmpNum = [NSMutableString stringWithString:numStr];
    NSRange range = [tmpNum rangeOfString:@"-"];
    while (range.length > 0)
    {
        [tmpNum deleteCharactersInRange:range];
        range = [tmpNum rangeOfString:@"-"];
    }
    NSRange range1 = [tmpNum rangeOfString:@"("];
    while (range1.length > 0)
    {
        [tmpNum deleteCharactersInRange:range1];
        range1 = [tmpNum rangeOfString:@"("];
    }
    NSRange range2 = [tmpNum rangeOfString:@")"];
    while (range2.length > 0)
    {
        [tmpNum deleteCharactersInRange:range2];
        range2 = [tmpNum rangeOfString:@")"];
    }
    NSRange range3 = [tmpNum rangeOfString:@" "];
    while (range3.length > 0)
    {
        [tmpNum deleteCharactersInRange:range3];
        range3 = [tmpNum rangeOfString:@" "];
    }

    return tmpNum;
}

+(BOOL)isMailAddress:(NSString *)mailStr
{
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *emailRegex = @"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [predicate evaluateWithObject:mailStr];
    return isValid;
}

+(BOOL)isPassWord:(NSString *)passStr
{
    NSString *passwordRegex = @"^[a-z0-9A-Z]{6,20}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex];
    BOOL isValid = [predicate evaluateWithObject:passStr];
    return isValid;
}

+(BOOL)islogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *userid = [ud objectForKey:USERID];
    
    if ([userid length] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(void)exit
{
    if ([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo])
    {
        [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    }
    if ([ShareSDK hasAuthorizedWithType:ShareTypeQQSpace])
    {
        [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
    }
    if ([ShareSDK hasAuthorizedWithType:ShareTypeRenren])
    {
        [ShareSDK cancelAuthWithType:ShareTypeRenren];
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:USERID];
    [ud removeObjectForKey:CLIENT_TOKEN];
    [ud removeObjectForKey:PASSWORD];
    [ud removeObjectForKey:CLIENT_TOKEN];
    [ud removeObjectForKey:HEADERIMAGE];
    [ud removeObjectForKey:USERNAME];
    [ud removeObjectForKey:@"useropt"];
    [ud setObject:[Tools phone_num] forKey:LAST_PHONENUM];
    [ud removeObjectForKey:PHONENUM];
    [ud synchronize];
}

#pragma mark - 用户信息

+ (NSString *)user_id
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [ud objectForKey:USERID];
    return user_id;
}

+(NSString *)user_name
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [ud objectForKey:USERNAME];
    return user_name;
}
+(NSString *)phone_num
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *phone_num = [ud objectForKey:PHONENUM];
    return phone_num;
}

+(NSString *)last_phone_num
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *phone_num = [ud objectForKey:LAST_PHONENUM];
    return phone_num;
}

+ (NSString *)banjia_num
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *banjia_num = [ud objectForKey:BANJIANUM];
    return banjia_num;
}

+(NSString *)pwd
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *pwd = [ud objectForKey:PASSWORD];
    return pwd;
}

+(NSString *)header_image
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *headerimage = [ud objectForKey:HEADERIMAGE];
    return headerimage;
}

+(NSString *)top_image
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *topImage = [ud objectForKey:TOPIMAGE];
    return topImage;
}

+(NSString *)user_birth
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_birth = [ud objectForKey:BIRTH];
    return user_birth;
}

+(NSString *)user_sex
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_sex = [ud objectForKey:USERSEX];
    return user_sex;
}

+(NSString *)device_os
{
    NSString *deviceOS = [[UIDevice currentDevice] systemName];
    return deviceOS;
}

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
+(NSString *)device_uid
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+(NSString *)device_name
{
    NSString *deviceName = [[UIDevice currentDevice] name];
    return deviceName;
}
+(NSString *)reg_method
{
    return @"2";
}
+(NSString *)device_version
{
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
    return deviceVersion;
}

+(NSString *)client_ver
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
    return app_Version;
}

+(NSString *)client_token
{
    NSString *c_token = [[NSUserDefaults standardUserDefaults] objectForKey:CLIENT_TOKEN];
    return c_token;
}

#pragma mark - my method
+(void)showAlertView:(NSString *)message delegateViewController:(XDContentViewController *)viewController
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:viewController cancelButtonTitle:@"知道啦" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - 等待
+ (void)showProgress:(UIView *) view
{
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+ (void)hideProgress:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}
+ (void) showTips:(NSString *)text toView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = text;
    
	[hud show:YES];
	[hud hide:YES afterDelay:0.5];
}

+ (ASIHTTPRequest *)joinUrlWithDic:(NSDictionary *)parameterDict  andHostUrl:(NSString *)hostUrl
{
    NSMutableString *postDataStr = [[NSMutableString alloc] initWithCapacity:0];
    [postDataStr insertString:[NSString stringWithFormat:@"{"] atIndex:[postDataStr length]];
    for (id key in parameterDict)
    {
        [postDataStr insertString:[NSString stringWithFormat:@"%@:%@&,",key,[parameterDict objectForKey:key]] atIndex:[postDataStr length]];
    }
    [postDataStr replaceCharactersInRange:NSMakeRange([postDataStr length]-1, 1) withString:@"}"];
//    NSString * postStr = [postDataStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DDLOG(@"postStr %@",postDataStr);
    NSURL *url = [NSURL URLWithString:hostUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    if ([parameterDict count] >0)
    {
        [request setPostBody:postData];
    }
    [request setTimeOutSeconds:12];
    return request;
}

+ (ASIFormDataRequest*)getRequestWithDict:(NSDictionary *)parameterDict andHostUrl:(NSString *)hostUrl
{
    NSMutableString *postDataStr = [[NSMutableString alloc] initWithCapacity:0];
    [postDataStr insertString:[NSString stringWithFormat:@"{"] atIndex:[postDataStr length]];
    for (id key in parameterDict)
    {
        [postDataStr insertString:[NSString stringWithFormat:@"%@:%@&,",key,[parameterDict objectForKey:key]] atIndex:[postDataStr length]];
    }
    [postDataStr replaceCharactersInRange:NSMakeRange([postDataStr length]-1, 1) withString:@"}"];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",hostUrl]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:12];
    if ([parameterDict count] > 0)
    {
        [request setPostBody:postData];
    }
    return request;
}

+ (ASIHTTPRequest *)joinUrlWithDic:(NSDictionary *)parameterDict andUrl:(NSString *)subUrl
{
    NSMutableString *postDataStr = [[NSMutableString alloc] initWithCapacity:0];
    [postDataStr insertString:[NSString stringWithFormat:@"%@%@?",HOST_URL,subUrl] atIndex:[postDataStr length]];
    for (id keys in parameterDict)
    {
        [postDataStr insertString:[NSString stringWithFormat:@"%@=%@&",keys,[parameterDict objectForKey:keys]] atIndex:[postDataStr length]];
    }
    NSString *tmpStr = [postDataStr substringToIndex:[postDataStr length]-1];
    NSString * postStr = [tmpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DDLOG(@"postStr %@",postStr);
    NSURL *url = [NSURL URLWithString:postStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:12];
    return request;
}

+ (ASIFormDataRequest*)postRequestWithDict:(NSDictionary *)parameterDict API:(NSString *)subUrl
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOST_URL,subUrl]];
    DDLOG(@"url=%@",url);
    NSMutableString *postDataStr = [[NSMutableString alloc] initWithCapacity:0];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:12];
    [postDataStr insertString:[NSString stringWithFormat:@"%@%@?",HOST_URL,subUrl] atIndex:[postDataStr length]];
    for (id keys in parameterDict)
    {
        [request setPostValue:[parameterDict objectForKey:keys] forKey:keys];
        DDLOG(@"post date &%@=%@",keys,[parameterDict objectForKey:keys]);
    }
    
    return request;
}

+ (ASIFormDataRequest *)upLoadImages:(NSArray *)imageArray withSubURL:(NSString *)subUrl andParaDict:(NSDictionary *)pareDict
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:
                                                                      [NSString stringWithFormat:@"%@%@",HOST_URL,subUrl]]];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:12];
    DDLOG(@"url=%@",request.url);
    for (NSString *key in pareDict.allKeys)
    {
        [request setPostValue:[pareDict objectForKey:key] forKey:key];
        DDLOG(@"post date &%@=%@",key,[pareDict objectForKey:key]);
    }
    
    for (int i=0; i<[imageArray count]; ++i)
    {
        UIImage *image = [imageArray objectAtIndex:i];
        NSData *imageData = UIImagePNGRepresentation(image);
        DDLOG(@"%@",NSStringFromCGSize(image.size));
        [request addData:imageData withFileName:[NSString stringWithFormat:@"%d.png",i+1] andContentType:@"image/png" forKey:[NSString stringWithFormat:@"img%@",i==0?@"":[NSString stringWithFormat:@"%d",i+1]]];
    }
    return request;
}

+(NSString *)getURLWithDict:(NSDictionary *)dict andUrl:(NSString *)url
{
    NSMutableString *postDataStr = [[NSMutableString alloc] initWithCapacity:0];
    [postDataStr insertString:[NSString stringWithFormat:@"%@%@?",HOST_URL,url] atIndex:[postDataStr length]];
    for (id keys in dict)
    {
        [postDataStr insertString:[NSString stringWithFormat:@"%@=%@&",keys,[dict objectForKey:keys]] atIndex:[postDataStr length]];
    }
    NSString *tmpStr = [postDataStr substringToIndex:[postDataStr length]-1];
    NSString * postStr = [tmpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DDLOG(@"postStr %@",postStr);
    return postStr;
}
#pragma mark - 提示
+(void)showAlterView:(NSString *)alterContent
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:alterContent delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [al show];
}

+ (BOOL)NetworkReachable
{
    NetworkStatus wifi = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus gprs = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(wifi == NotReachable && gprs == NotReachable)
    {
        return NO;
    }
    return YES;
}

+ (CGRect)getFrame:(UIImage *)img
{
    CGFloat displayWidth = 0;
    CGFloat displayHeight = 0;
    if (img.size.width > SCREEN_WIDTH)
    {
        displayWidth = SCREEN_WIDTH;
        displayHeight = img.size.height*displayWidth/img.size.width;
    }
    else if(img.size.height > SCREEN_HEIGHT)
    {
        displayHeight = SCREEN_HEIGHT;
        displayWidth = img.size.width*displayHeight/img.size.height;
    }
    else
    {
        displayHeight = img.size.height;
        displayWidth = img.size.width;
    }
    return CGRectMake((SCREEN_WIDTH-displayWidth)/2 ,(SCREEN_HEIGHT-displayHeight)/2 ,displayWidth, displayHeight);
}

//-(CGSize)getSizeWithString:(NSString *)content andWidth:(CGFloat)width andFont:(UIFont *)font
//{
//    if (font == nil)
//    {
//        font = [UIFont systemFontOfSize:14];
//    }
//    
//}



//    }

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIGraphicsBeginImageContext(asize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
    
    // Get the new image from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.8);
    
    newImage = [UIImage imageWithData:imageData];
    return newImage;
}


#pragma mark - setting
+(BOOL)soundOpen
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *soundState = [ud objectForKey:@"open"];
    if ([soundState isEqualToString:@"open"])
    {
        return YES;
    }
    return NO;
}

#pragma mark - abouttime
+(NSString *)showTime:(NSString *)time
{
    NSDate *localDate = [NSDate date];
    NSTimeInterval localTimeInterVal = [localDate timeIntervalSince1970];
    NSString *localtimeStr = [NSString stringWithFormat:@"%.0lf",localTimeInterVal];
    NSString *timeStr = [NSString stringWithFormat:@"%@",time];
    int resultTime = [localtimeStr intValue] - [timeStr intValue];
    
    
    NSString *resultStr;
    if (resultTime > SECPERYEAR)
    {
        {
            long sec = (long)[time longLongValue];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"YYYY年MM月dd日 hh:mm"];
            NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
            resultStr = [dateFormatter stringFromDate:datetimeDate];
        }
    }
    else if (resultTime > MINUTE*10)
    {
        long sec = (long)[time longLongValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日 hh:mm"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        resultStr = [dateFormatter stringFromDate:datetimeDate];
    }
    else
    {
        resultStr = [NSString stringWithFormat:@"%d分钟前",resultTime/MINUTE];
    }
    return resultStr;
}

+(NSString *)showTimeOfToday:(NSString *)time
{
    NSDate *localDate = [NSDate date];
    NSTimeInterval localTimeInterVal = [localDate timeIntervalSince1970];
    NSString *localtimeStr = [NSString stringWithFormat:@"%.0lf",localTimeInterVal];
    NSString *timeStr = [NSString stringWithFormat:@"%@",time];
    int resultTime = [localtimeStr intValue] - [timeStr intValue];
    
    NSString *resultStr;
    if (resultTime > MINUTE*10)
    {
        long sec = (long)[time longLongValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"hh:mm"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        resultStr = [dateFormatter stringFromDate:datetimeDate];
    }
    else
    {
        resultStr = [NSString stringWithFormat:@"%d分钟前",resultTime/MINUTE];
    }
    return resultStr;
}

#pragma mark - getimageFromView
+(UIImage*)convertViewToImage:(UIView*)v
{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(void)dealRequestError:(NSDictionary *)errorDict fromViewController:(XDContentViewController *)viewController
{
    if ([[[[errorDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_AUTH"])
    {
        if (![self user_id])
        {
            return ;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
        [Tools showAlertView:[[[errorDict objectForKey:@"message"] allValues] firstObject] delegateViewController:viewController];
        return ;
    }
    [Tools showAlertView:[[[errorDict objectForKey:@"message"] allValues] firstObject] delegateViewController:viewController];

}

#pragma mark - aboutSort
+ (NSArray *)getSpellSortArrayFromChineseArray:(NSArray *)sourceArray andKey:(NSString *)key
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *letters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    for (int i=0; i<[letters count]+1; ++i)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        int count = 0;
        if (i == [letters count])
        {
            for (int j = 0; j < [sourceArray count]; ++j)
            {
                NSDictionary *dict = [sourceArray objectAtIndex:j];
                NSString *first = [NSString stringWithFormat:@"%c",[[ChineseToPinyin jianPinFromChiniseString:[dict objectForKey:key]] characterAtIndex:0]];
                if (![letters containsObject:first])
                {
                    [array addObject:dict];
                    count ++;
                }
            }
            [dict setObject:@"#" forKey:@"key"];
        }
        else
        {
            
            [dict setObject:[letters objectAtIndex:i] forKey:@"key"];
            for (int j = 0; j < [sourceArray count]; ++j)
            {
                NSDictionary *dict = [sourceArray objectAtIndex:j];
                NSString *first = [NSString stringWithFormat:@"%c",[[ChineseToPinyin jianPinFromChiniseString:[dict objectForKey:key]] characterAtIndex:0]];
                if ([[letters objectAtIndex:i]isEqualToString:first])
                {
                    [array addObject:dict];
                    count++;
                }
            }
        }
        
        
        for (int i=0; i<[array count]; i++)
        {
            NSDictionary *maxDict = [array objectAtIndex:i];
            NSString *maxJIanPin = [ChineseToPinyin pinyinFromChiniseString:[maxDict objectForKey:key]];
            for (int j=i; j<[array count]; j++)
            {
                NSDictionary *tmpDict = [array objectAtIndex:j];
                NSString *tmpPinYin = [ChineseToPinyin pinyinFromChiniseString:[tmpDict objectForKey:key]];
                if ([maxJIanPin compare:tmpPinYin options:NSLiteralSearch] == NSOrderedDescending)
                {
                    [array exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
        
        if (count > 0)
        {
            [dict setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
            [dict setObject:array forKey:@"array"];
            [resultArray addObject:dict];
        }
    }
    return resultArray;
}
#pragma mark - getImage
+ (UIImage *)getImageFromImage:(UIImage *)image andInsets:(UIEdgeInsets)insets
{
    return [image resizableImageWithCapInsets:insets];
}
#import "dlfcn.h"
#pragma mark - getLableSize

+(CGSize)getSizeWithString:(NSString *)content andWidth:(CGFloat)width andFont:(UIFont *)font
{
    
    CGSize maxSize=CGSizeMake(width, 99999);
    CGSize  strSize=[content sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    return strSize;
}

+(NSString *)myNumber{
    void *lib = dlopen("/Symbols/System/Library/Framework/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    NSString* (*getPhoneNumber)() = dlsym(lib, "CTSettingCopyMyPhoneNumber");
    
    if (getPhoneNumber == nil) {
        NSLog(@"getPhoneNumber is nil");
        return nil;
    }
    NSString* ownPhoneNumber = getPhoneNumber();
    return ownPhoneNumber;
}

#pragma mark - captureenable
+(BOOL)captureEnable
{
    if([[self device_version] integerValue] >= 7.0)
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusAuthorized)
        {
            return YES;
        }
        else if(authStatus == AVAuthorizationStatusDenied)
        {
            [Tools showAlertView:@"相机不可访问" delegateViewController:nil];
            return NO;
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            return YES;
        }
    }
    return YES;
}

#pragma mark - callPhoneNum
+ (void) dialPhoneNumber:(NSString *)aPhoneNumber inView:(UIView *)view
{
    UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",aPhoneNumber]];
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    [view addSubview:phoneCallWebView];
}
@end
