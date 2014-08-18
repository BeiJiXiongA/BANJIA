//
//  Tools.h
//  XMPP1106
//
//  Created by mac120 on 13-11-11.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTWCache.h"
#import "NSString+MD5.h"
#import "FTWCache.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Header.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "XDContentViewController.h"

@interface Tools : NSObject
+ (NSDictionary *)JSonFromString:(NSString* )result;
+ (void) fillButtonView:(UIButton *)button withImageFromURL:(NSString*)URL andDefault:(NSString *)defaultName;
+ (void) fillImageView:(UIImageView *)imageView withImageFromURL:(NSString*)URL andDefault:(NSString *)defaultName;
+ (void) fillImageView:(UIImageView *)imageView withImageFromURL:(NSString*)URL imageWidth:(CGFloat)imageWidth andDefault:(NSString *)defaultName;
+(BOOL)isPhoneNumber:(NSString *)numStr;
+(BOOL)isStudentsNumber:(NSString *)numStr;
+(BOOL)isMailAddress:(NSString *)mailStr;
+(BOOL)isPassWord:(NSString *)passStr;
+(BOOL)islogin;
+(void)exit;

+(NSString *)user_id;
+(NSString *)user_name;
+(NSString *)phone_num;
+(NSString *)banjia_num;
+(NSString *)last_phone_num;
+(NSString *)header_image;
+(NSString *)top_image;
+(NSString *)user_birth;
+(NSString *)pwd;
+(NSString *)device_os;
+(NSString *)device_uid;
+(NSString *)device_name;
+(NSString *)reg_method;
+(NSString *)device_version;
+(NSString *)client_ver;
+(NSString *)client_token;
+(NSString *)user_sex;

+(void)showAlertView:(NSString *)message delegateViewController:(XDContentViewController *)viewController;
+ (void)showProgress:(UIView *) view;
+ (void)hideProgress:(UIView *)view;
+ (void) showTips:(NSString *)text toView:(UIView *)view;

#pragma mark - aboutRequest
+ (ASIHTTPRequest *)joinUrlWithDic:(NSDictionary *)parameterDict  andHostUrl:(NSString *)hostUrl;
+ (ASIHTTPRequest *)joinUrlWithDic:(NSDictionary *)parameterDict andUrl:(NSString *)subUrl;
+ (ASIFormDataRequest *)postRequestWithDict:(NSDictionary *)parameterDict API:(NSString *)subUrl;
+ (ASIFormDataRequest *)getRequestWithDict:(NSDictionary *)parameterDict andHostUrl:(NSString *)hostUrl;
+ (ASIFormDataRequest *)upLoadImages:(NSArray *)imageArray withSubURL:(NSString *)subUrl andParaDict:(NSDictionary *)pareDict;
+ (ASIFormDataRequest *)upLoadImageFiles:(NSArray *)filesArray withSubURL:(NSString *)subUrl andParaDict:(NSDictionary *)pareDict;
+ (ASIFormDataRequest *)upLoadSoundFiles:(NSArray *)filesArray withSubURL:(NSString *)subUrl andParaDict:(NSDictionary *)pareDict timeLength:(int)length;

+(NSString *)getURLWithDict:(NSDictionary *)dict andUrl:(NSString *)url;
+(void)showAlterView:(NSString *)alterContent;
+ (BOOL)NetworkReachable;
+ (CGRect)getFrame:(UIImage *)img;
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
+(BOOL)soundOpen;

#pragma mark - aboutTime
+(NSString *)showTime:(NSString *)time;
+(NSString *)showTimeOfToday:(NSString *)time;
+(NSString *)showTime:(NSString *)time andFromat:(NSString *)timeFormat;

#pragma mark - getimageFromView
+(UIImage*)convertViewToImage:(UIView*)v;

+(void)dealRequestError:(NSDictionary *)errorDict fromViewController:(XDContentViewController *)viewController;

#pragma mark - aboutSort
+ (NSArray *)getSpellSortArrayFromChineseArray:(NSArray *)sourceArray andKey:(NSString *)key;

#pragma mark - getImage
+ (UIImage *)getImageFromImage:(UIImage *)image andInsets:(UIEdgeInsets)insets;

+(NSString *)getPhoneNumFromString:(NSString *)numStr;

+(CGSize)getSizeWithString:(NSString *)content andWidth:(CGFloat)width andFont:(UIFont *)font;

#pragma mark - myPhoneNum
+(NSString *)myNumber;

#pragma mark - captureenable
+(BOOL)captureEnable;
#pragma mark - callPhoneNum
+ (void) dialPhoneNumber:(NSString *)aPhoneNumber inView:(UIView *)view;
@end
