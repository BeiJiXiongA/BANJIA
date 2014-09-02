//
//  API.h
//  School
//
//  Created by TeekerZW on 14-1-25.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#ifndef School_API_h
#define School_API_h

#pragma mark - 接口网址

//正式服务器
//#define HOST_URL       @"http://api.banjiaedu.com"
//#define IMAGEURL       @"http://img.banjiaedu.com"
//#define MEDIAURL      @"http://media.banjiaedu.com"


//测试服务器
#define HOST_URL       @"http://mytest.banjiaedu.com"
#define IMAGEURL       @"http://imgtest.banjiaedu.com"
#define MEDIAURL       @"http://mediatest.banjiaedu.com"

//头像地址 人(host)\ur\(uid)\(img_icon||img_bk).(你想要啥格式就写啥)

//班级地址 人(host)\cl\(cid)\(img_icon||img_bk).(你想要啥格式就写啥)

#pragma mark - userprotocol
#define USER_PROTOCOL   @"/protocol.html"

#define HOME_AD   @"/debugs/mbGetAD"

#pragma mark - users
#define MB_REG         @"/users/mbReg"
#define MB_AUTHCODE    @"/users/mbAuthCode"
#define CHECKPHONE     @"/users/mbCheckPhone"
#define BINDPHONE      @"/users/mbBindPhone"
#define HOMEDATA       @"/users/mbindex"

#define NEWREGIST      @"/users/mbRegist"
#define MB_CHECKOUT    @"/users/mbCheckCode"
#define MB_SUBPWD         @"/users/mbSubPwd"
#define MB_RESETPWD      @"/users/mbUpdatePwd"
#define MB_SUBINFO        @"/users/mbSubInfo"
#define MB_LOGIN          @"/users/mbLogin"
#define MB_LOGOUT         @"/users/mbLogout"
#define MB_GETUSERINFO    @"/users/mbGetUserInfo"
#define SETUSERIMAGE    @"/users/mbUpdateUserImg"
#define MB_APPLY_FRIEND    @"/users/mbApplyFriend"
#define MB_ADD_FRIEND      @"/users/mbAddFriend"
#define MB_REFUSE_FRIEND   @"/users/mbRefuseFriend"
#define MB_FRIENDLIST      @"/users/mbFriendList"
#define MB_SETUSERSET      @"/users/mbSetUserSet"
#define MB_GETUSERSET     @"/users/mbGetUserSet"
#define MB_SETUSERINFO    @"/users/mbSetUserInfo"   //u_id,birth
#define MB_RMFRIEND       @"/users/mbRmFriend"
#define SCOREDETAIL   @"/users/mbExamDetails"
#define MB_TRANSMIT     @"/users/mbRetransmit"
#define MB_INVITE     @"/users/mbInvite"

#define MB_SETUSERSETOFCLASS  @"/users/mbSetUserSetByClass"
#define MB_GETUSERSETOFCLASS  @"/users/mbSetUserSetByClass"
#define CHECKCONTACTS       @"/users/mbCheckContacts" //u_id', 'Contacts'


#pragma mark -school
#define SEARCHSCHOOL      @"/schools/mbSchoolSearch"
#define CREATESCHOOL      @"/schools/mbAddSchool"
#define GETHOTSCHOOLS        @"/schools/mbTopSchools"
#define GETCITYS         @"/schools/mbGetCity"
#define CITYLIST         @"/schools/mbCityList"
#define SEARCHSCHOOLBYCITY   @"/schools/mbSearchSchoolByCity"
#define SEARCHSCHOOLBYBAIDU   @"/schools/mbSearchSchool"
#define SEARCHNEARBYSCHOOL    @"/schools/mbNearBy"
#define NEARBYSCHOOLDETAIL    @"/schools/mbDetail"
#define GETCITIES            @"/schools/mbCitiesList"

#pragma mark - classes
#define CREATECLASS       @"/classes/mbAddClass"
#define CLASSESOFSCHOOL   @"/classes/mbClassesListBySchool"
#define GETCLASSESBYUSER  @"/classes/mbClassesListByUser"
#define GETUSERSBYCLASS   @"/classes/mbUsersListByClass"
#define CLASSINFO         @"/classes/mbClassesInfo"
#define JOINCLASS         @"/classes/mbJoinClass"
#define ALLOWJOIN         @"/classes/mbAllowJoin"
#define REFUSEJOIN        @"/classes/mbRefuseJoin"
#define CLASSSETTING      @"/classes/mbSetOptions"
#define CLASSGETSETVALUE       @"/classes/mbGetOptions"
#define MB_ADMINLIST       @"/classes/mbAdminList"  //c_id
#define CHANGE_MEM_TITLE      @"/classes/mbSetTitle"   //'u_id','m_id','c_id','title
#define KICKUSERFROMCLASS  @"/classes/mbTickMember"  //u_id','m_id','c_id','role
#define APPOINTADMIN       @"/classes/mbsetAdmin"     //u_id,o_id,c_id
#define TRANSADMIN         @"/classes/mbTransferAdmin"
#define GETSETTING      @"/classes/mbUserMatchClass" //u_id,c_id
#define RMADMIN        @"/classes/mbRmAdmin"    //u_id o_id
#define SIGNOUTCLASS    @"/classes/mbSignoutClass" //u_id,c_id,role
#define SETCLASSIMAGE    @"/classes/mbUpdateClassImg"
#define SETCLASSINFO     @"/classes/mbSetClassInfo"
#define NEWCEATECLASS      @"/v11/classes/mbaddclass"
#define SEARCHCLASS     @"/classes/mbSearchClass"
#define BINDSCHOOL     @"/classes/mbBindSchool"
#define SCORELIST     @"/classes/mbExamsList"
#define GETCHILDBYNAME  @"/classes/mbMemberAutoCom"
#define SETDEFPARENT  @"/classes/mbSetDefParent"

#define DELCLASS  @"/classes/mbDelClass"

#pragma mark - diaries
#define ADDDIARY        @"/Diaries/mbAddDiaries"

#define GETDIARIESLIST @"/v11/Diaries/mbGetDiariesList"

#define OLDGETDIARIESLIST  @"/Diaries/mbGetDiariesList"
#define COMMENT_DIARY   @"/Diaries/mbDiariesComment"
#define GET_COMMENTS    @"/Diaries/mbCommentList"
#define LIKE_DIARY      @"/Diaries/mbDiariesLike"
#define LIKE_LIST       @"/Diaries/mbLikesList"
#define GETDIARY_DETAIL @"/Diaries/mbDiariesInfo"
#define ALLOW_DIARY     @"/Diaries/mbAllowDiary"  //u_id,c_id,p_id
#define IGNORE_DIARY    @"/Diaries/mbRefuseDiary"
#define GETNEWDIARIES   @"/Diaries/mbGetUnckeckedList"  //c_id
#define DELETEDIARY     @"/Diaries/mbDelDiary"

#pragma mark - notices
#define GETNOTIFICATIONS @"/notices/mbGetNoticesList"
#define GETNOTICEVIEWLIST  @"/notices/mbGetViewList"
#define ADDNOTIFICATION @"/notices/mbAddNotices"
//#define READNTICES        @"/notices/mbReceipt"
#define READNTICES        @"/notices/mbNoticeRead"
#define DELETENOTICE      @"/notices/mbDelNotice"

#pragma mark - chat
#define CREATE_CHAT_MSG  @"/v11/chats/mbChat"
#define GETCHATLOG       @"/chats/mbGetChatLog"
#define GETCHATLIST     @"/chats/mbNewChatList"
#define LASTVIEWTIME    @"/chats/mbLastViewTime"
#define UPLOADCHATFILE     @"/chats/mbUploadChatFile"
#define CREATEGROUPCHAT   @"/chats/mbcreateGroupChat"
#define GROUPCHATLIST     @"/chats/mbGetGroupChatList"   //u_id','~c_id'
#define GROUPCHAT       @"/chats/mbGroupChat"   //'u_id', 'g_id', 'content'
#define GETGROUPINFO    @"/chats/mbGetGroupInfo"
#define EXITGROUPCHAT    @"/chats/mbOffGroupChat"
#define SETGROUPCHAT   @"/chats/mbSetGroupChat"
#define JOINGROUPCHAR  @"/chats/mbJoinCgroup"


#define MSGLIST    @"/messages/mbmsglist"

#pragma mark - mbnewchat
#define MB_NEWCHAT     @"/chats/mbNewChat"
#define MB_NEWCLASS    @"/classes/mbNewClass"
#define MB_NEWVERSION   @"/debugs/mbGetNew"

#pragma mark - debugs
#define MB_ADVISE     @"/debugs/mbAdvise"  //'u_id','content'

#pragma mark - 三方
#define BINDACCOUNT    @"/users/mbBindAccount"  //u_id,a_id,a_type
#define GETACCOUNTLIST   @"/users/mbGetAccountList"  //u_id
#define LOGINBYAUTHOR    @"/users/mbLoginByAnother"   //a_id','a_type','d_name', 'd_imei', 'd_type', 'c_ver', 'c_os', 'p_cid', 'p_uid'
#define UNBINDACCOUNT   @"/users/mbUnbindAccount"

#define QQNICKNAME  [NSString stringWithFormat:@"%@-qqNickName",[Tools user_id]]
#define SINANICKNAME  [NSString stringWithFormat:@"%@-sinaNickName",[Tools user_id]]
#define RRNICKNAME    [NSString stringWithFormat:@"%@-rrNickName",[Tools user_id]]
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
