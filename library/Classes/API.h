//
//  API.h
//  School
//
//  Created by TeekerZW on 14-1-25.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//18911587776 新都环岛西

#ifndef School_API_h
#define School_API_h

#pragma mark - 接口网址

//正式服务器
//#define HOST_URL       @"http://api.banjiaedu.com"
//#define IMAGEURL       @"http://img.banjiaedu.com"
//#define MEDIAURL      @"http://media.banjiaedu.com"

//测试服务器                                                                                         
#define HOST_URL       @"http://test.banjiaedu.com"
#define IMAGEURL       @"http://testimg.banjiaedu.com"
#define MEDIAURL       @"http://testmedia.banjiaedu.com"

//头像地址 人(host)\ur\(uid)\(img_icon||img_bk).(你想要啥格式就写啥)

//班级地址 人(host)\cl\(cid)\(img_icon||img_bk).(你想要啥格式就写啥)

#pragma mark - userprotocol
#define USER_PROTOCOL   @"/protocol.html"
/*
 参数：无
 说明：软件用户协议
 */

#define HOME_AD   @"/debugs/mbGetAD"
/*
 参数：u_id，token
 说明：获取首页广告信息
 */

#pragma mark - users
#define MB_REG         @"/users/mbReg"
/*
 参数：
 phone：手机号
 说明：提交手机号，然后调用MB_AUTHCODE，获取验证码
 */
#define MB_AUTHCODE    @"/users/mbAuthCode"
/*
 参数：
 phone：手机号
 说明：获取验证码
 */
#define CHECKPHONE     @"/users/mbCheckPhone"
/*
 参数：
 phone：手机号
 说明：提交手机号码，然后调用MB_AUTHCODE，获取验证码
 */
#define BINDPHONE      @"/users/mbBindPhone"
/*
 参数：u_id，token
 phone：手机号
 ~auth_code：验证码
 说明：如果不带auth_code，为提交手机号；如果带auth_code，为验证验证码
 */
#define HOMEDATA       @"/users/mbindex"
/*
 参数：u_id，token
 ~page：页码
 说明：获取首页数据，包括未读通知和班级日志
 */
#define NEWREGIST      @"/users/mbRegist"
/*
 参数：
 参数：u_id，token
 pwd：密码
 c_ver：客户端版本号
 d_name：设备名
 d_imei：设备唯一码
 c_os：客户端系统
 c_version：客户端版本号
 d_type：设备类型
 registrationID：激光推送id
 r_name：用户姓名
 sex：性别
 
 说明：用户完善信息
 */
#define MB_CHECKOUT    @"/users/mbCheckCode"
/*
 参数：
 phone：手机号
 auth_code：验证码
 说明：验证验证码
 */
#define MB_SUBPWD         @"/users/mbSubPwd"
/*
 参数：u_id
 
 */
#define MB_RESETPWD      @"/users/mbUpdatePwd"
/*
 参数：u_id，token
 opwd：旧密码
 npwd：新密码
 说明：更改用户登陆密码
 */
#define MB_SUBINFO        @"/users/mbSubInfo"
/*
 废弃
 */
#define MB_LOGIN          @"/users/mbLogin"
/*
 参数：
 phone：手机号码
 pwd：密码
 c_ver：客户端版本号
 d_name：设备名称
 d_imei：设备唯一码
 c_os：设备操作系统
 d_type：设备类型（iOS或Android）
 registrationID：激光推送id
 account：0
 
 说明：用户登录
 */
#define MB_LOGOUT         @"/users/mbLogout"
/*
 参数：u_id，token
 说明：退出登录
 */
#define MB_GETUSERINFO    @"/users/mbGetUserInfo"
/*
 参数：u_id，token
 ~c_id：想要获取的用户所在的班级，如果不传，会获取用户在所有班级的信息
 other_id：想要获取信息的用户id
 说明：获取用户详细信息
 */
#define SETUSERIMAGE    @"/users/mbUpdateUserImg"
/*
 参数：u_id，token
 img_type：上传图片类型
    img_tcard：教师资格证照片
    img_id：身份证照片
 说明：上传教师资格认证所需的照片
 */
#define MB_APPLY_FRIEND    @"/users/mbApplyFriend"
/*
 参数：u_id，token
 f_id：申请人id
 说明：申请加为好友
 */
#define MB_ADD_FRIEND      @"/users/mbAddFriend"
/*
 参数：u_id，token
 f_id：申请人id
 说明：同意好友申请
 */
#define MB_REFUSE_FRIEND   @"/users/mbRefuseFriend"
/*
 参数：u_id，token
 f_id：申请人id
 说明：拒绝好友申请
 */
#define MB_FRIENDLIST      @"/users/mbFriendList"
/*
 参数：u_id，token
 说明：获取用户好友列表
 */
#define MB_SETUSERSET      @"/users/mbSetUserSet"
/*
 参数：u_id，token
 s_k：
     #define NewChatAlert     @"n_c_a"
     #define NewDiaryAlert    @"n_d_a"
     #define NewNoticeMotion  @"n_n_m"
     #define NewNoticeAlert   @"n_n_a"
 s_v：
 说明：更改个人设置项
 */
#define MB_GETUSERSET     @"/users/mbGetUserSet"
/*
 参数：u_id，token
 说明：获取用户个人设置
 */
#define MB_SETUSERINFO    @"/users/mbSetUserInfo"   //u_id,birth
/*
 参数：u_id，token
 birth：生日
 sex：性别
 r_name：名字
 说明：更改用户个人信息
 */
#define MB_RMFRIEND       @"/users/mbRmFriend"
/*
 参数：u_id，token
 f_id:好友id
 说明：解除好友关系
 */
#define SCOREDETAIL   @"/users/mbExamDetails"
/*
 参数：u_id，token
 e_id：考试id
 说明：获取成绩详情
 */
#define MB_TRANSMIT     @"/users/mbRetransmit"
/*
 弃用
 */
#define MB_INVITE     @"/users/mbInvite"
/*
 参数：u_id，token
 phone：用逗号隔开的手机联系人
 说明：短信邀请手机联系人
 */

#define MB_SETUSERSETOFCLASS  @"/users/mbSetUserSetByClass"
/*
 参数：u_id，token
 c_id：班家id
 o_id：被设置用户id
 s_k：
     #define UserSendComment   @"u_s_c"
     #define UserSendLike      @"u_s_l"
     #define UserReceiveDiary   @"u_r_d"
     #define UserChatTeacher    @"u_c_t"
 s_v：
 
 说明：设置用户在班级内的权限，只有班主任有这个权限
 */
#define MB_GETUSERSETOFCLASS  @"/users/mbSetUserSetByClass"
/*
 弃用
 */
#define CHECKCONTACTS       @"/users/mbCheckContacts" //u_id', 'Contacts'
/*
 参数：u_id，token
 contacts：以逗号分割开的联系电话
 说明：把本地联系人电话上传到服务器，检查都有谁注册了班家软件
 */

#pragma mark -school
#define SEARCHSCHOOL      @"/schools/mbSchoolSearch"
/*
 弃用
 */
#define CREATESCHOOL      @"/schools/mbAddSchool"
/*
 参数：u_id，token
 name：学校名称
 level：学校类别
 r_id：地区id
 说明：创建学校
 */
#define GETHOTSCHOOLS        @"/schools/mbTopSchools"
/*
 弃用
 */
#define GETCITYS         @"/schools/mbGetCity"
/*
 弃用
 */
#define CITYLIST         @"/schools/mbCityList"
/*
 参数：u_id，token
 r_id:地区id
 说明：根据城市获得区域名称列表
 */
#define SEARCHSCHOOLBYCITY   @"/schools/mbSearchSchoolByCity"
/*
 参数：u_id，token
 r_id:地区id
 level：学校类型
 name：搜索关键字
 pr_id：省id
 说明：根据地区和学校类型搜索学校
 */
#define SEARCHSCHOOLBYBAIDU   @"/schools/mbSearchSchool"
/*
 参数：u_id，token
 region：城市名字
 name：搜索关键字
 说明：按城市和关键字搜索学校  //?????
 */
#define SEARCHNEARBYSCHOOL    @"/schools/mbNearBy"
/*
 弃用
 */
#define NEARBYSCHOOLDETAIL    @"/schools/mbDetail"
/*
 弃用
 */
#define GETCITIES            @"/schools/mbCitiesList"
/*
 弃用
 */

#pragma mark - classes
#define CREATECLASS       @"/classes/mbAddClass"
/*
 弃用
 */
#define CLASSESOFSCHOOL   @"/classes/mbClassesListBySchool"
/*
 参数：u_id，token
 s_id：学校id
 说明：获得学校现有的班级列表
 */
#define GETCLASSESBYUSER  @"/classes/mbClassesListByUser"
/*
 参数：u_id，token
 说明：获得用户班级列表
 */
#define GETUSERSBYCLASS   @"/classes/mbUsersListByClass"
/*
 参数：u_id，token
 c_id：班级id
 role：班级角色
 说明：获得班级成员列表
 */
#define CLASSINFO         @"/classes/mbClassesInfo"
/*
 参数：u_id，token
 c_id：班级id
 说明：获得班级信息，包括学校名称，入学时间，班级背景图片，头像，介绍，班号，如果班级绑定了学校，还会有学校信息。
 */
#define JOINCLASS         @"/classes/mbJoinClass"
/*
 参数：u_id，token
 c_id：班级id
 role：申请的班级角色（parents，teachers，）
 学生：
    title：空
    unin_id:请求合并同名学生的id
    sn:学生学号
 老师：
    title：老师申请的职务：语文，数学等；
 家长：
    re_id：学生id
    re_name：学生名字
    re_type：与学生关系
    sn：学生学号（可以为空）
 
 说明：申请加入班级，分三种角色，需要提交不同的信息
 */
#define ALLOWJOIN         @"/classes/mbAllowJoin"
/*
 参数：u_id，token
 c_id：班级id
 role：班级角色
 j_id：申请人id
 sn：学号
 ~re_id：合并学生id
 说明：统一成员申请，如果老师同意家长申请的时候，想把家长所带的孩子与班级内已经有的孩子和并，就会加上需要和并的学生的id
 */
#define REFUSEJOIN        @"/classes/mbRefuseJoin"
/*
 参数：u_id，token
 c_id：班级id
 role：班级角色
 j_id：申请人id
 说明：拒绝班级申请
 */
#define CLASSSETTING      @"/classes/mbSetOptions"
/*
 参数：u_id，token
 c_id：班级id
 s_k：
     #define AdminCheckApply   @"a_c_a"
     #define AdminCheckDiary   @"a_c_d"
     #define AdminInviteMem    @"a_i_m"
     #define AdminSendNotice   @"a_s_n"
     #define ParentComment     @"p_com"
     #define ParentInviteMem   @"p_i_m"
     #define ParentSendDiary   @"p_s_d"
     #define ParentTeacherFriend  @"p_t_f"
     #define StudentInviteMem  @"s_i_m"
     #define StudentSendDiary  @"s_s_d"
     #define StudentTeacherFriend  @"s_t_f"
     #define StudentVisiteTime   @"s_v_t"
     #define VisitorAccess     @"o_v_d"
 s_v：
 说明：班级权限设置
 */
#define CLASSGETSETVALUE       @"/classes/mbGetOptions"
/*
 参数：u_id，token
 c_id：班级id
 说明：获取班级管理员id列表
 */
#define MB_ADMINLIST       @"/classes/mbAdminList"  //c_id
/*
 
 */
#define CHANGE_MEM_TITLE      @"/classes/mbSetTitle"   //'u_id','m_id','c_id','title
/*
 参数：u_id，token
 c_id：班级id
 m_id：班级成员id
 title：班级职位称呼，如果学生，就是班干部职位，如班长，学习委员；
                    如果老师，就是老师职务名称，如语文老师，数学老师；
                    如果家长，就是家长称呼，如爸爸，妈妈；
 说明：设置班级成员职位称呼
 */
#define KICKUSERFROMCLASS  @"/classes/mbTickMember"  //u_id','m_id','c_id','role
/*
 参数：u_id，token
 c_id：班级id
 m_id：班级成员id
 role：班级成员角色
 说明：移除班级成员，只有班主任有这个权限
 */
#define APPOINTADMIN       @"/classes/mbsetAdmin"     //u_id,o_id,c_id
/*
 参数：u_id，token
 c_id：班级id
 o_id：学生id
 说明：任命班级管理员，老师默认就是管理员
 */
#define TRANSADMIN         @"/classes/mbTransferAdmin"
/*
 参数：u_id，token
 c_id：班级id
 o_id：老师id
 说明：移交班主任权限，移交之后自己成为普通老师
 */
#define GETSETTING      @"/classes/mbUserMatchClass" //u_id,c_id
/*
 参数：u_id，token
 c_id：班级id
 说明：获取班级设置，包括个人在班级里的权限，身份，角色
 */
#define RMADMIN        @"/classes/mbRmAdmin"    //u_id o_id
/*
 参数：u_id，token
 c_id：班级id
 o_id：学生id
 说明：取消学生管理员身份
 */
#define SIGNOUTCLASS    @"/classes/mbSignoutClass" //u_id,c_id,role
/*
 参数：u_id，token
 c_id：班级id
 role：班级角色（students，parents，teacher）
 说明：退出班级，非班主任
 */
#define SETCLASSIMAGE    @"/classes/mbUpdateClassImg"
/*
 参数：u_id，token
 c_id：班级id
 img_type：设置的图片类型（img_icon：班级头像图片或img_kb：班级背景图片）
 图片文件生成的data
 
 说明：设置班级背景图片或头像图片
 */
#define SETCLASSINFO     @"/classes/mbSetClassInfo"
/*
 参数：u_id，token
 c_id：班级id
 name：班级名称
 info：班级介绍
 name和info选一个
 
 说明：设置班级名称或班级介绍
 */
#define NEWCEATECLASS      @"/v11/classes/mbaddclass"
/*
 参数：u_id，token
 s_level：学校类别  
 
    #define SCHOOLLEVELARRAY @[@"6",@"1",@"2",@"9",@"3",@"4",@"5",@"8",@"7"];
    #define SCHOOLLEVELDICT  @{@"1":@"小学",@"2":@"中学",@"3":@"夏令营",@"4":@"社团",@"5":@"职业学校",@"6":@"幼儿园",@"7":@"其他",@"8":@"培训机构",@"9":@"大学"}
 
 name：班级名称
 enter_t：入学时间
 s_id：学校id
 说明：创建班级
 */
#define SEARCHCLASS     @"/classes/mbSearchClass"
/*
 参数：u_id，token
 c_id：班级id（为空）
 number：班号（618xxxx）
 说明：根据班好查找班级
 */
#define BINDSCHOOL     @"/classes/mbBindSchool"
/*
 参数：u_id，token
 c_id：班级id
 s_id：学校id
 说明：把班级与学校绑定，只有班主任有权限
 */
#define SCORELIST     @"/classes/mbExamsList"
/*
 参数：u_id，token
 c_id：班级id
 page：页码
 role：班级角色
 说明：获取成绩列表
 */
#define GETCHILDBYNAME  @"/classes/mbMemberAutoCom"
/*
 参数：u_id，token
 c_id：班级id
 name：孩子名字
 说明：获取班级内同名孩子列表
 */
#define SETDEFPARENT  @"/classes/mbSetDefParent"
/*
 参数：u_id，token
 c_id：班级id
 o_id:家长id
 说明：设置家长为孩子的默认家长，默认家长功能是如果默认家长读了班级通知，这个家长的孩子及孩子的其他家长也未已读状态
 */


#define DELCLASS  @"/classes/mbDelClass"
/*
 参数：u_id，token
 c_id：班级id
 说明：解散班级，只有班主任可以
*/

#pragma mark - diaries
#define ADDDIARY        @"/Diaries/mbAddDiaries"
/*
 NULL
 */


#define GETDIARIESLIST @"/v11/Diaries/mbGetDiariesList"
/*
 参数：u_id，token
 c_id：班级id
 ~page：页码
 ~month：月份（6为数字）
 说明：获取日志列表，第一次获取可以不传page和month，获取的数据里会有下次应该传的page和month
 */
#define OLDGETDIARIESLIST  @"/Diaries/mbGetDiariesList"
/*
 NULL
 */
#define COMMENT_DIARY   @"/Diaries/mbDiariesComment"
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 content:日志评论内容
 说明：评论日志
 */
#define GET_COMMENTS    @"/Diaries/mbCommentList"
/*
 NULL
 */
#define LIKE_DIARY      @"/Diaries/mbDiariesLike"
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 说明：赞或取消赞日志，如果已经赞过了就是取消赞，如果没有赞过日志就是赞日志
 */
#define LIKE_LIST       @"/Diaries/mbLikesList"
/*
 NULL
 */
#define GETDIARY_DETAIL @"/Diaries/mbDiariesInfo"
/*
 参数：u_id，token
 p_id：班级日志id
 说明：获取日志详情
 */
#define ALLOW_DIARY     @"/Diaries/mbAllowDiary"  //u_id,c_id,p_id
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 说明：管理员同意新日志发布到班级内
 */
#define IGNORE_DIARY    @"/Diaries/mbRefuseDiary"
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 说明：管理员拒绝新日志发布到班级内
 */
#define GETNEWDIARIES   @"/Diaries/mbGetUnckeckedList"  //c_id
/*
 参数：u_id，token
 c_id：班级id
 说明：获取待审核日志列表，只有班主任或者有审核日志权限的管理员才能获取到，现在已经弃用
 */
#define DELETEDIARY     @"/Diaries/mbDelDiary"
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 说明：删除班级日志，只有日志发布人和班主任可以删除
 */
#define DEL_COMMENT     @"/Diaries/mbDelComment"
/*
 参数：u_id，token
 c_id：班级id
 p_id：班级日志id
 index：评论索引
 说明：删除日志评论，只可以删除自己的评论
 */
#pragma mark - notices
#define GETNOTIFICATIONS @"/notices/mbGetNoticesList"
/*
 参数：u_id，token
 c_id：班级id
 month：月份缩写（6位数字）
 page：页码，获取通知是按月份分页获取的
 说明：班级内获取通知列表
 */
#define GETNOTICEVIEWLIST  @"/notices/mbGetViewList"
/*
 参数：u_id，token
 p_id：通知id
 list_type：列表类型（read：已读成员列表；unread：未读成员列表）
 说明：获取通知已读或未读成员列表
 */
#define ADDNOTIFICATION @"/notices/mbAddNotices"
/*
 参数：u_id，token
 c_id：班级id
 content：通知内容
 view：通知对象（all,parents,teachers, students），现在发布通知统一为all
 c_read：是否需要回执，现在发布的通知都需要回执
 
 说明：发布班级通知
 */
//#define READNTICES        @"/notices/mbReceipt"
#define READNTICES        @"/notices/mbNoticeRead"
/*
 参数：u_id，token
 p_id：通知id
 c_id：班级id
 说明：读取通知接口
 */
#define DELETENOTICE      @"/notices/mbDelNotice"
/*
 参数：u_id，token
 p_id：通知id
 c_id：班级id
 说明：删除通知，在通知详情里只有通知发布人和班主任可以删除通知
 */

#pragma mark - chat
#define CREATE_CHAT_MSG  @"/v11/chats/mbChat"
/*
 参数：u_id，token
 t_id：私聊是对方的用户id
 content：聊天内容
 说明：私聊想对方发送文字消息（发送语音或文字时，会先把文件传到服务器，服务器返回客户端文件网址，客户端再把网址以文字形式发送给对方）
 */
#define GETCHATLOG       @"/v11/chats/mbGetChatLog"
/*
 参数：u_id，token
 如果是群聊：
    g_id：群聊id
 如果是私聊：
    t_id：时间
 time：时间戳（0：说去未读聊天消息
             9999999999：本地如果没有聊天消息，获取历史10条为单位
             正确的时间戳：获取这条消息以前的10条历史消息
             ）
 说明：获取聊天记录，
 */
#define GETCHATLIST     @"/chats/mbNewChatList"
/*
 参数：u_id，token
 说明：获取聊天记录列表，只能获取到未读的消息列表，列表中会列出本地和未读的料部分
 */
#define LASTVIEWTIME    @"/chats/mbLastViewTime"
/*
 参数：u_id，token
 如果是群聊：
    g_id：群聊id
 如果是私聊：
    t_id：对方id

 说明：更新聊天最后时间
 */
#define UPLOADCHATFILE     @"/chats/mbUploadChatFile"
/*
 参数：u_id，token
 nsdata：文件生成的二进制
 说明：上传文件
 */
#define CREATEGROUPCHAT   @"/chats/mbcreateGroupChat"
/*
 参数：u_id，token
 users：群聊用户id 列表，字符串形式，以逗号隔开
 name：群聊名字（xxx,xxx等（x人））
 c_id:班级id
 说明：创建群聊
 */
#define GROUPCHATLIST     @"/chats/mbGetGroupChatList"   //u_id','~c_id'
/*
 参数：u_id，token
 c_id：班级id
 说明：在班级里获取群聊列表
 */
#define GROUPCHAT       @"/chats/mbGroupChat"   //'u_id', 'g_id', 'content'
/*
 参数：u_id，token
 g_id：群聊id
 content：消息内容
 说明：发送群聊消息
 */
#define GETGROUPINFO    @"/chats/mbGetGroupInfo"
/*
 参数：u_id，token
 g_id：群聊id
 说明：获得群聊信息，包括创建者，群内成员，群聊设置（是否接受群消息，是否保存到好友列表）
 */
#define EXITGROUPCHAT    @"/chats/mbOffGroupChat"
/*
 参数：u_id，token
 g_id：群聊id
 o_id：被踢出人得用户id
 
 说明：踢出群聊成员，只有创建者才有权利踢出成员
 */
#define SETGROUPCHAT   @"/chats/mbSetGroupChat"
/*
 参数：u_id，token
 g_id：群聊id
 s_k：设置的键
 s_v：设置的值
 说明：群聊设置，
 */
#define JOINGROUPCHAR  @"/chats/mbJoinCgroup"
/*
 参数：u_id，token
 g_id：群聊id
 说明：扫描二维码加入圈料
 */

#define GETCHATLOGBYID  @"/chats/mbGetLogByID"
/*
 参数：u_id，token
 mid:聊天消息id
 如果是群聊：
    g_id:群聊id
 如果是私聊：
    t_id:对方id
 
 说明：如果是长消息，根据消息id，获取消息内容
 */

#define MSGLIST    @"/messages/mbmsglist"
/*
 NULL
 */

#pragma mark - mbnewchat
#define MB_NEWCHAT     @"/chats/mbNewChat"
/*
 参数：u_id，token
 说明：获取用户未读消息数目
 */
#define MB_NEWCLASS    @"/classes/mbNewClass"
/*
 参数：u_id，token
 说明：获取用户的好友统计数目（好友申请）和班级内新消息统计数字（包括班级成员申请和班级未读通知数）
 */
#define MB_NEWVERSION   @"/debugs/mbGetNew"
/*
 参数：u_id，token
 type：设备系统类型（iOS或Android）
 build:内部版本号，检查是否有更新版本（iOS已经不用，iOS 检查更新会去请求App Store）
 
 说明：从服务器获取是否有更新版本（Android） 和   邀请文字模板
 */

#pragma mark - debugs
#define MB_ADVISE     @"/debugs/mbAdvise"  //'u_id','content'
/*
 参数：u_id，token
 content：反馈意见内容
 ~phone：联系电话
 
 说明：用户提交反馈意见
 */


#pragma mark - 三方
#define BINDACCOUNT    @"/users/mbBindAccount"  //u_id,a_id,a_type
/*
 参数：u_id，token
 a_id：三方账号的id；
 a_type：三方账号类型；
 n_name：三方账号昵称
 说明：登陆后绑定三方账号
 */
#define GETACCOUNTLIST   @"/users/mbGetAccountList"  //u_id
/*
 参数：u_id，token
 说明：获取自己已经绑定的三方账号列表 和 是否已经进行教师认证
 */
#define LOGINBYAUTHOR    @"/users/mbLoginByAnother"   //a_id','a_type','d_name', 'd_imei', 'd_type', 'c_ver', 'c_os', 'p_cid', 'p_uid'
/*
 参数：
 a_id：三方账号的id；
 a_type：三方账号类型；
 c_ver：客户端版本号
 d_name：客户端设备名
 d_imei：客户端设备唯一吗
 c_os：客户端设备系统名
 d_type：客户端设备系统名
 registrationID：激光推送设备id
 n_name：三方账号昵称
 r_name:用户名
 sex：性别  （1：男，0：女  ，-1：保密）
 reg：是否是第一次注册（0：第一次登陆需要完善信息；
                     1：直接登陆）
 
 说明：三方登陆
 */
#define UNBINDACCOUNT   @"/users/mbUnbindAccount"
/*
 参数：u_id,token,
      a_type:三方账号类型(rr:人人;
                        sw:新浪微博;
                        qq:QQ;
                        wx:微信)
 说明：解绑三方账号，只有一个账号时不能解绑
 */

#define QQNICKNAME  [NSString stringWithFormat:@"%@-qqNickName",[Tools user_id]]
#define SINANICKNAME  [NSString stringWithFormat:@"%@-sinaNickName",[Tools user_id]]
#define RRNICKNAME    [NSString stringWithFormat:@"%@-rrNickName",[Tools user_id]]
#define WXNICKNAME    [NSString stringWithFormat:@"%@-wxNickName",[Tools user_id]]

#pragma mark - settingKeys

//班级设置
#define AdminCheckApply   @"a_c_a"
#define AdminCheckDiary   @"a_c_d"
#define AdminInviteMem    @"a_i_m"
#define AdminSendNotice   @"a_s_n"
#define ParentComment     @"p_com"
#define ParentInviteMem   @"p_i_m"
#define ParentSendDiary   @"p_s_d"
#define ParentTeacherFriend  @"p_t_f"
#define StudentInviteMem  @"s_i_m"
#define StudentSendDiary  @"s_s_d"
#define StudentTeacherFriend  @"s_t_f"
#define StudentVisiteTime   @"s_v_t"
#define VisitorAccess     @"o_v_d"

//个人在班级中设置
#define UserSendComment   @"u_s_c"
#define UserSendLike      @"u_s_l"
#define UserReceiveDiary   @"u_r_d"
#define UserChatTeacher    @"u_c_t"

//个人设置
#define NewChatAlert     @"n_c_a"
#define NewDiaryAlert    @"n_d_a"
#define NewNoticeMotion  @"n_n_m"
#define NewNoticeAlert   @"n_n_a"

//班级新
#define UCDIARY    @"ucdiary"
#define DIARY      @"diary"
#define UCMEMBER   @"ucmember"
#define NOTICE     @"notice"

//新消息
#define NewChatMsgNum  @"newchatmsgnum"
#define NewClassNum    @"newclassnum"

#define UCFRIENDSUM   @"ucfriendsnum"


#define IMAGE_NAME @"logo80"
#define IMAGE_EXT @"png"
#endif
