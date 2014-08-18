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
#import "SetImageTools.h"
#import "API.h"
#import "XDContentViewController+JDSideMenu.h"
#import "MyTextField.h"
#import "MobClick.h"
#import "UITextField+AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "UIButton+WebCache.h"
#import "cnvUILabel.h"
#import "SizeTools.h"
#import "ImageTools.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "DealJiFen.h"

#define FaceViewHeight  200

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

#define TITLE_COLOR   UIColorFromRGB(0x555555)
#define CONTENTCOLOR  UIColorFromRGB(0x666666)
#define COMMENTCOLOR  UIColorFromRGB(0x999999)
#define TIMECOLOR     UIColorFromRGB(0xcccccc)

#pragma mark - aboutCoordinate

#define FOURS  ([[UIScreen mainScreen] bounds].size.height==480?YES:NO)

#define SYSVERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

#define SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)

#define NAV_RIGHT_BUTTON_HEIGHT   40

//#define SCREEN_HEIGHT  (SYSVERSION > 7.0 ? ([[UIScreen mainScreen] bounds].size.height):([[UIScreen mainScreen] bounds].size.height-20))

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define Y_STARTPOINT (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) ? 0.0f:64.0f)

#define UI_NAVIGATION_BAR_HEIGHT        ((SYSVERSION >= 7.0)?64:44)
#define UI_TOOL_BAR_HEIGHT              44
#define UI_TAB_BAR_HEIGHT               49
#define UI_STATUS_BAR_HEIGHT            20
#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                (SYSVERSION >= 7.0 ? ([[UIScreen mainScreen] bounds].size.height):([[UIScreen mainScreen] bounds].size.height-20))
#define UI_MAINSCREEN_HEIGHT            (UI_SCREEN_HEIGHT - UI_STATUS_BAR_HEIGHT)
#define UI_MAINSCREEN_HEIGHT_ROTATE     (UI_SCREEN_WIDTH - UI_STATUS_BAR_HEIGHT)
#define UI_WHOLE_SCREEN_FRAME           CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)
#define UI_WHOLE_SCREEN_FRAME_ROTATE    CGRectMake(0, 0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH)
#define UI_MAIN_VIEW_FRAME              CGRectMake(0, UI_STATUS_BAR_HEIGHT, UI_SCREEN_WIDTH, UI_MAINSCREEN_HEIGHT)
#define UI_MAIN_VIEW_FRAME_ROTATE       CGRectMake(0, UI_STATUS_BAR_HEIGHT, UI_SCREEN_HEIGHT, UI_MAINSCREEN_HEIGHT_ROTATE)

#define CENTER_POINT    CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2)

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
#define DetailHeaderHeight  53

#pragma mark - 关于提示
#define NOT_NETWORK    @"没有网络哦！"

#define COUNT_PERPAGE  @"10"

#pragma mark - 用户信息
#define HEADERDEFAULT  @"header_pic.jpg"
#define HEADERBG     @"headerbg"
#define HEADERICON   @"defaultheader"
#define NAVBTNBG    @"navbtn"
#define NAVCOLOR    TITLE_COLOR
#define CornerMore   @"corner_more"
#define CORNERMORERIGHT  50

#define NAMEFONT   [UIFont boldSystemFontOfSize:16]
#define NAMECOLOR  RGB(51, 51, 51, 1)

#define USERID    @"u_id"
#define PHONENUM  @"phone_num"
#define LAST_PHONENUM  @"last_phone_num"
#define PASSWORD  @"password"
#define USERNAME  @"user_name"
#define USERSEX   @"sex"
#define BANJIANUM  @"banjianum"


#define BGVIEWCOLOR   UIColorFromRGB(0xf1f0ec)


#define HEADERIMAGE  [NSString stringWithFormat:@"%@-img_icon",[Tools user_id]]
#define TOPIMAGE    [NSString stringWithFormat:@"%@-top_image",[Tools user_id]]
#define BIRTH     [NSString stringWithFormat:@"%@-birth",[Tools user_id]]
#define CLIENT_VERSION  @"c_ver"
#define DEVICE_NAME     @"d_name"
#define DEVICE_IDENTIFER  @"d_imei"
#define DEVICE_OS         @"c_os"
#define CLIENT_TOKEN      @"c_token"

#define ANONYMITY  @"anonymity"
#define  SCHEMETYPE  @"schemetype"
#define  SCHEMEDEBUG  @"debug"
#define SCHEMERELEASE  @"release"

#define PHONE_FORMAT   @"***********"

#define  TAGSARRAYKEY  [NSString stringWithFormat:@"%@-tags",[Tools user_id]]

#pragma mark - abouttime
#define SECPERYEAR          (SECPERDAY*365)
#define SECPERDAY           (60*60*24)
#define HOUR                (60*60)
#define MINUTE              60

#define FROMCLASS   @"fromclass"
#define NOTFROMCLASS  @"notfromclass"
#define FROMWHERE   @"fromwhere"

#define SEARCHSCHOOLTYPE  @"searchschooltype"
#define BINDCLASSTOSCHOOL  @"bindclasstoschool"
#define CREATENEWCLASS    @"createnewclass"

#define LOCATIONLABELHEI   18

#define CHATTO   @"    发私信"
#define ADDFRIEND  @"    加好友"
#define CHATW  15
#define CHATH  15
#define ADDFRIW  20
#define ADDFRIH  20
#define CTOP   11
#define ATOP   13
#define CLEFT  24
#define ALEFT  33

#define MinCommentHeight  35
#define MaxCommentWidth   (SCREEN_WIDTH-40)

#define SCHOOLLEVELARRAY  @[@"小学",@"中学",@"夏令营",@"社团",@"职业学校",@"幼儿园",@"其他"]
#define OBJECTARRAY   @[@"语文老师",@"数学老师",@"英语老师"]
#define RELATEARRAY   @[@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"其他"]


#define ROLEPARENTS  @"parents"
#define ROLETEACHER  @"teachers"
#define ROLESTUDENTS  @"students"

#define OurTeamID  @"YmFuamlh"
#define OurTeamHeader  @"/teamlogo.png"

#define AssistantID  @"YXNzaXN0YW50"

#define ClassAssistantHeader   @"/assistant.png"

#pragma mark - notification name
#define UPDATECLASSMEMBERLIST   @"updateclassmemberlist"
#define UPDATEFRIENDSLIST       @"updatefriendslist"
#define LOGOUT                  @"logout"
#define CHANGECLASSINFO         @"changeclassinfo"
#define CHANGEHEADERICON    @"changeicon"
#define RECEIVENEWMSG     @"receivenewmsg"
#define RECEIVENEWMSGNOTATCHATVIEW   @"receivenewmsgnotatchatview"
#define RECEIVENEWNOTICE   @"receivenewnotice"

#define UPDATEGROUPCHATLIST   @"updategroupchatlist"

#pragma mark - aboutinvite
#define InviteParentKey  @"item3"
#define InviteClassMemberKey  @"item2"
#define ShareContentKey    @"item1"


#define ShareContent [[NSUserDefaults standardUserDefaults] objectForKey:ShareContentKey]
#define InviteClassMember [[NSUserDefaults standardUserDefaults] objectForKey:InviteClassMemberKey]
#define InviteParent [[NSUserDefaults standardUserDefaults] objectForKey:InviteParentKey]

#define ShareUrl @"https://itunes.apple.com/cn/app/ban-jia/id862315597?mt=8&uo=4"
#pragma mark - aboutimagesize
#define MAXHEIGHT     640
#define MAXWIDTH      640
#define TakePhotoTag   7777
#define AlbumTag      9999

#define PhotoSpace  7

#pragma mark - aboutpushnotification
#define BECOMEACTIVE  @"becomeactive"
#define FROMBACKGROUD  @"frombackgroud"
#define FROMFORGROUD  @"fromforgroud"

#pragma mark - base64
#define QQBASE64   @"cXE="
#define RRBASE64   @"cnI="
#define WXBASE64   @"d3g="
#define SWBASE64   @"c3c="
