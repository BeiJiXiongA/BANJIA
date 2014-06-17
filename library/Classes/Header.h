//
//  Header.h
//  0113
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//
//

#import <QuartzCore/QuartzCore.h>
#import "Tools.h"
#import "API.h"
#import "XDContentViewController+JDSideMenu.h"
#import "MyTextField.h"
#import "MobClick.h"
#import "UITextField+AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"
#import "AKNumericFormatter.h"

#define FaceViewHeight  220

#pragma mark - Debug log macro
#ifdef DEBUG

#define DDLOG(...) NSLog(__VA_ARGS__)
#define DDLOG_CURRENT_METHOD NSLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

#else

#define DDLOG(...) ;
#define DDLOG_CURRENT_METHOD ;

#endif

#pragma mark - aboutColor

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define RGB(r,g,b,a)  [UIColor colorWithRed:(double)r/255.0f green:(double)g/255.0f blue:(double)b/255.0f alpha:a]


#define LIGHT_BLUE_COLOR  RGB(74, 188, 194, 1)
#define LIGHT_GREEN_COLOR RGB(113, 192, 159, 1)
#define TITLE_COLOR   UIColorFromRGB(0x717070)

#pragma mark - aboutCoordinate

#define FOURS  ([[UIScreen mainScreen] bounds].size.height==480?YES:NO)

#define SYSVERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

#define SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)

#ifdef YSTART
#define SCREEN_HEIGHT  (([[UIScreen mainScreen] bounds].size.height)-20)
#else
#define SCREEN_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)
#endif

#define Y_STARTPOINT (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) ? 0.0f:64.0f)

#define XD_TOPNAVBACKGROUD_HEIGHT        36
#define XD_VIEW_ORGION_Y                 44            //由于导航栏用imageview代替，
#define XD_SHADOWVIEW_ORGION_MAX_X       1             //抽屉视图放缩时原点的x的最大值（视图缩小时原点的x会不断增加）
#define XD_SHADOWVIEW_ORGION_MAX_Y       0             //抽屉视图放缩时原点的y的最大值（视图缩小时原点的y会不断增加）
#define XD_SHADOWVIEW_MAX_ALPHA         0.8               //抽屉视图的阴影层的透明度的最大值
#define XD_SHADOWVIEW_ISMAINVIEW_MAX_ORGION_x   220    //抽屉视图是主视图时侧滑后的原点的位置
#define XD_SHADOWVIEW_DECIDE_DIRECTIONPOINT     120     //与原点的x作比较，决定手势结束后视图应该回到初始位置还是自动右移

#define UI_NAVIGATION_BAR_HEIGHT        44
#define UI_TOOL_BAR_HEIGHT              44
#define UI_TAB_BAR_HEIGHT               49
#define UI_STATUS_BAR_HEIGHT            20
#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)
#define UI_MAINSCREEN_HEIGHT            (UI_SCREEN_HEIGHT - UI_STATUS_BAR_HEIGHT)
#define UI_MAINSCREEN_HEIGHT_ROTATE     (UI_SCREEN_WIDTH - UI_STATUS_BAR_HEIGHT)
#define UI_WHOLE_SCREEN_FRAME           CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)
#define UI_WHOLE_SCREEN_FRAME_ROTATE    CGRectMake(0, 0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH)
#define UI_MAIN_VIEW_FRAME              CGRectMake(0, UI_STATUS_BAR_HEIGHT, UI_SCREEN_WIDTH, UI_MAINSCREEN_HEIGHT)
#define UI_MAIN_VIEW_FRAME_ROTATE       CGRectMake(0, UI_STATUS_BAR_HEIGHT, UI_SCREEN_HEIGHT, UI_MAINSCREEN_HEIGHT_ROTATE)

#define CENTER_POINT    CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2+YSTART)

#define HEADER_NEWS_COUNT   3

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

/*********
 宏作用:单例生成宏
 使用方法:http://blog.csdn.net/totogo2010/article/details/8373642
 **********/
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}


#define GETMOREOFFSET    70
#define DetailHeaderHeight  70

#pragma mark - 关于提示
#define NOT_NETWORK    @"没有网络哦！"

#define COUNT_PERPAGE  @"10"

#pragma mark - 用户信息
#define HEADERDEFAULT  @"header_pic.jpg"
#define HEADERBG     @"headerbg"
#define HEADERICON   @"headericon"
#define NAVBTNBG    @"navbtn"
#define NAVCOLOR    TITLE_COLOR
#define CornerMore   @"corner_more"

#define NAMEFONT   [UIFont boldSystemFontOfSize:16]
#define NAMECOLOR  [UIColor blackColor]

#define USERID    @"u_id"
#define PHONENUM  @"phone_num"
#define LAST_PHONENUM  @"last_phone_num"
#define PASSWORD  @"password"
#define USERNAME  @"user_name"
#define USERSEX   @"sex"



#define BGVIEWCOLOR   UIColorFromRGB(0xf1f0ec)


#define HEADERIMAGE  [NSString stringWithFormat:@"%@-img_icon",[Tools user_id]]
#define TOPIMAGE    [NSString stringWithFormat:@"%@-top_image",[Tools user_id]]
#define BIRTH     [NSString stringWithFormat:@"%@-birth",[Tools user_id]]
#define CLIENT_VERSION  @"c_ver"
#define DEVICE_NAME     @"d_name"
#define DEVICE_IDENTIFER  @"d_imei"
#define DEVICE_OS         @"c_os"
#define CLIENT_TOKEN      @"c_token"

#define PHONE_FORMAT   @"***********"

#define  TAGSARRAYKEY  [NSString stringWithFormat:@"%@-tags",[Tools user_id]]

#pragma mark - abouttime
#define SECPERYEAR          (SECPERDAY*365)
#define SECPERDAY           (60*60*24)
#define HOUR                (60*60)
#define MINUTE              60


