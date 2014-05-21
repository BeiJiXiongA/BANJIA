//
//  DemoViewController.m
//  HtmlDemo
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "DemoViewController.h"
#import "TFHpple.h"
#import "OperatDB.h"
#import "School.h"
#import "Header.h"

#define YSTART  (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)?0.0f:20.0f)

#define SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)

#ifdef YSTART
#define SCREEN_HEIGHT  (([[UIScreen mainScreen] bounds].size.height)-20)
#else
#define SCREEN_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)
#endif


@interface DemoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *bgView;
    UIView *buttonbg;
    int schoolCount;
    
    NSMutableArray *quArray;
    NSMutableString *citiesString;
    NSMutableString *cityID;
    
    UITableView *provinceTableView;
    NSMutableArray *provinceArray;
    BOOL provinceOpen;
    UILabel *provinceLabel;
    int provinceIndex;
    
    UITableView *cityTableView;
    NSMutableArray *cityArray;
    BOOL cityOpen;
    UILabel *cityLabel;
    int cityIndex;
    
    UITableView *areaTableView;
    NSMutableArray *areaArray;
    BOOL areaOpen;
    UILabel *areaLabel;
    int areaIndex;
    
    UITableView *schoolTableView;
    NSMutableArray *schoolArray;
    BOOL schoolOpen;
    UILabel *schoolLabel;
    int schoolIndex;
    
    NSString *schoolType;
}
@end

@implementation DemoViewController

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
    citiesString = [[NSMutableString alloc] initWithCapacity:0];
    [citiesString insertString:@"\"1100:北京市\" = [\"110101:东城区\",\"110102:西城区\",\"110103:崇文区\",\"110104:宣武区\",\"110105:朝阳区\",\"110106:丰台区\",\"110107:石景山区\",\"110108:海淀区\",\"110109:门头沟区\",\"110111:房山区\",\"110112:通州区\",\"110113:顺义区\",\"110114:昌平区\",\"110115:大兴区\",\"110116:怀柔区\",\"110117:平谷区\",\"110228:密云县\",\"110229:延庆县\"];\"3100:上海市\" = [\"310101:黄浦区\",\"310103:卢湾区\",\"310104:徐汇区\",\"310105:长宁区\",\"310106:静安区\",\"310107:普陀区\",\"310108:闸北区\",\"310109:虹口区\",\"310110:杨浦区\",\"310112:闵行区\",\"310113:宝山区\",\"310114:嘉定区\",\"310115:浦东新区\",\"310116:金山区\",\"310117:松江区\",\"310118:青浦区\",\"310119:南汇区\",\"310120:奉贤区\",\"310230:崇明县\"];\"1200:天津市\" = [\"120101:和平区\",\"120102:河东区\",\"120103:河西区\",\"120104:南开区\",\"120105:河北区\",\"120106:红桥区\",\"120107:塘沽区\",\"120108:汉沽区\",\"120109:大港区\",\"120110:东丽区\",\"120111:西青区\",\"120112:津南区\",\"120113:北辰区\",\"120114:武清区\",\"120115:宝坻区\",\"120221:宁河县\",\"120223:静海县\",\"120225:蓟县\"];\"5000:重庆市\" = [\"500101:万州区\",\"500102:涪陵区\",\"500103:渝中区\",\"500104:大渡口区\",\"500105:江北区\",\"500106:沙坪坝区\",\"500107:九龙坡区\",\"500108:南岸区\",\"500109:北碚区\",\"500110:万盛区\",\"500111:双桥区\",\"500112:渝北区\",\"500113:巴南区\",\"500114:黔江区\",\"500115:长寿区\",\"500116:江津区\",\"500117:合川区\",\"500118:永川区\",\"500119:南川区\",\"500222:綦江县\",\"500223:潼南县\",\"500224:铜梁县\",\"500225:大足县\",\"500226:荣昌县\",\"500227:璧山县\",\"500228:梁平县\",\"500229:城口县\",\"500230:丰都县\",\"500231:垫江县\",\"500232:武隆县\",\"500233:忠县\",\"500234:开县\",\"500235:云阳县\",\"500236:奉节县\",\"500237:巫山县\",\"500238:巫溪县\",\"500240:石柱土家族自治县\",\"500241:秀山土家族苗族自治县\",\"500242:酉阳土家族苗族自治县\",\"500243:彭水苗族土家族自治县\"];\"2300:黑龙江省\" = [\"2301:哈尔滨市\",\"2302:齐齐哈尔市\",\"2303:鸡西市\",\"2304:鹤岗市\",\"2305:双鸭山市\",\"2306:大庆市\",\"2307:伊春市\",\"2308:佳木斯市\",\"2309:七台河市\",\"2310:牡丹江市\",\"2311:黑河市\",\"2312:绥化市\",\"2327:大兴安岭地区\"];\"2200:吉林省\" = [\"2201:长春市\",\"2202:吉林市\",\"2203:四平市\",\"2204:辽源市\",\"2205:通化市\",\"2206:白山市\",\"2207:松原市\",\"2208:白城市\",\"2224:延边朝鲜族自治州\"];\"2100:辽宁省\" = [\"2101:沈阳市\",\"2102:大连市\",\"2103:鞍山市\",\"2104:抚顺市\",\"2105:本溪市\",\"2106:丹东市\",\"2107:锦州市\",\"2108:营口市\",\"2109:阜新市\",\"2110:辽阳市\",\"2111:盘锦市\",\"2112:铁岭市\",\"2113:朝阳市\",\"2114:葫芦岛市\"];\"3700:山东省\" = [\"3701:济南市\",\"3702:青岛市\",\"3703:淄博市\",\"3704:枣庄市\",\"3705:东营市\",\"3706:烟台市\",\"3707:潍坊市\",\"3708:济宁市\",\"3709:泰安市\",\"3710:威海市\",\"3711:日照市\",\"3712:莱芜市\",\"3713:临沂市\",\"3714:德州市\",\"3715:聊城市\",\"3716:滨州市\",\"3717:菏泽市\"];\"1400:山西省\" = [\"1401:太原市\",\"1402:大同市\",\"1403:阳泉市\",\"1404:长治市\",\"1405:晋城市\",\"1406:朔州市\",\"1407:晋中市\",\"1408:运城市\",\"1409:忻州市\",\"1410:临汾市\",\"1411:吕梁市\"];\"6100:陕西省\" =[\"6101:西安市\",\"6102:铜川市\",\"6103:宝鸡市\",\"6104:咸阳市\",\"6105:渭南市\",\"6106:延安市\",\"6107:汉中市\",\"6108:榆林市\",\"6109:安康市\",\"6110:商洛市\"];\"1300:河北省\" =[\"1301:石家庄市\",\"1302:唐山市\",\"1303:秦皇岛市\",\"1304:邯郸市\",\"1305:邢台市\",\"1306:保定市\",\"1307:张家口市\",\"1308:承德市\",\"1309:沧州市\",\"1310:廊坊市\",\"1311:衡水市\"];\"4100:河南省\" =[\"4101:郑州市\",\"4102:开封市\",\"4103:洛阳市\",\"4104:平顶山市\",\"4105:安阳市\",\"4106:鹤壁市\",\"4107:新乡市\",\"4108:焦作市\",\"4109:濮阳市\",\"4110:许昌市\",\"4111:漯河市\",\"4112:三门峡市\",\"4113:南阳市\",\"4114:商丘市\",\"4115:信阳市\",\"4116:周口市\",\"4117:驻马店市\",\"4118:济源市\"];\"4200:湖北省\" =[\"4201:武汉市\",\"4202:黄石市\",\"4203:十堰市\",\"4205:宜昌市\",\"4206:襄樊市\",\"4207:鄂州市\",\"4208:荆门市\",\"4209:孝感市\",\"4210:荆州市\",\"4211:黄冈市\",\"4212:咸宁市\",\"4213:随州市\",\"4228:恩施土家族苗族自治州\",\"429004:仙桃市\",\"429005:潜江市\",\"429006:天门市\",\"429021:神农架林区\"];\"4300:湖南省\" =[\"4301:长沙市\",\"4302:株洲市\",\"4303:湘潭市\",\"4304:衡阳市\",\"4305:邵阳市\",\"4306:岳阳市\",\"4307:常德市\",\"4308:张家界市\",\"4309:益阳市\",\"4310:郴州市\",\"4311:永州市\",\"4312:怀化市\",\"4313:娄底市\",\"4331:湘西土家族苗族自治州\"];\"4600:海南省\" = [\"4601:海口市\",\"4602:三亚市\",\"469001:五指山市\",\"469002:琼海市\",\"469003:儋州市\",\"469005:文昌市\",\"469006:万宁市\",\"469007:东方市\",\"469025:定安县\",\"469026:屯昌县\",\"469027:澄迈县\",\"469028:临高县\",\"469030:白沙黎族自治县\",\"469031:昌江黎族自治县\",\"469033:乐东黎族自治县\",\"469034:陵水黎族自治县\",\"469035:保亭黎族苗族自治县\",\"469036:琼中黎族苗族自治县\"];\"3200:江苏省\" =[\"3201:南京市\",\"3202:无锡市\",\"3203:徐州市\",\"3204:常州市\",\"3205:苏州市\",\"3206:南通市\",\"3207:连云港市\",\"3208:淮安市\",\"3209:盐城市\",\"3210:扬州市\",\"3211:镇江市\",\"3212:泰州市\",\"3213:宿迁市\"];\"3600:江西省\" =[\"3601:南昌市\",\"3602:景德镇市\",\"3603:萍乡市\",\"3604:九江市\",\"3605:新余市\",\"3606:鹰潭市\",\"3607:赣州市\",\"3608:吉安市\",\"3609:宜春市\",\"3610:抚州市\",\"3611:上饶市\"];\"4400:广东省\" =[\"4401:广州市\",\"4402:韶关市\",\"4403:深圳市\",\"4404:珠海市\",\"4405:汕头市\",\"4406:佛山市\",\"4407:江门市\",\"4408:湛江市\",\"4409:茂名市\",\"4412:肇庆市\",\"4413:惠州市\",\"4414:梅州市\",\"4415:汕尾市\",\"4416:河源市\",\"4417:阳江市\",\"4418:清远市\",\"4419:东莞市\",\"4420:中山市\",\"4451:潮州市\",\"4452:揭阳市\",\"4453:云浮市\"];\"4500:广西壮族自治区\" =[\"4501:南宁市\",\"4502:柳州市\",\"4503:桂林市\",\"4504:梧州市\",\"4505:北海市\",\"4506:防城港市\",\"4507:钦州市\",\"4508:贵港市\",\"4509:玉林市\",\"4510:百色市\",\"4511:贺州市\",\"4512:河池市\",\"4513:来宾市\",\"4514:崇左市\"];\"5300:云南省\" =[\"5301:昆明市\",\"5303:曲靖市\",\"5304:玉溪市\",\"5305:保山市\",\"5306:昭通市\",\"5307:丽江市\",\"5308:普洱市\",\"5309:临沧市\",\"5323:楚雄彝族自治州\",\"5325:红河哈尼族彝族自治州\",\"5326:文山壮族苗族自治州\",\"5328:西双版纳傣族自治州\",\"5329:大理白族自治州\",\"5331:德宏傣族景颇族自治州\",\"5333:怒江傈僳族自治州\",\"5334:迪庆藏族自治州\"];\"5200:贵州省\" =[\"5201:贵阳市\",\"5202:六盘水市\",\"5203:遵义市\",\"5204:安顺市\",\"5222:铜仁地区\",\"5223:黔西南布依族苗族自治州\",\"5224:毕节地区\",\"5226:黔东南苗族侗族自治州\",\"5227:黔南布依族苗族自治州\"];\"5100:四川省\" =[\"5101:成都市\",\"5103:自贡市\",\"5104:攀枝花市\",\"5105:泸州市\",\"5106:德阳市\",\"5107:绵阳市\",\"5108:广元市\",\"5109:遂宁市\",\"5110:内江市\",\"5111:乐山市\",\"5113:南充市\",\"5114:眉山市\",\"5115:宜宾市\",\"5116:广安市\",\"5117:达州市\",\"5118:雅安市\",\"5119:巴中市\",\"5120:资阳市\",\"5132:阿坝藏族羌族自治州\",\"5133:甘孜藏族自治州\",\"5134:凉山彝族自治州\"];\"1500:内蒙古自治区\" =[\"1501:呼和浩特市\",\"1502:包头市\",\"1503:乌海市\",\"1504:赤峰市\",\"1505:通辽市\",\"1506:鄂尔多斯市\",\"1507:呼伦贝尔市\",\"1508:巴彦淖尔市\",\"1509:乌兰察布市\",\"1522:兴安盟\",\"1525:锡林郭勒盟\",\"1529:阿拉善盟\"];\"6400:宁夏回族自治区\" =[\"6401:银川市\",\"6402:石嘴山市\",\"6403:吴忠市\",\"6404:固原市\",\"6405:中卫市\"];\"6200:甘肃省\" =[\"6201:兰州市\",\"6202:嘉峪关市\",\"6203:金昌市\",\"6204:白银市\",\"6205:天水市\",\"6206:武威市\",\"6207:张掖市\",\"6208:平凉市\",\"6209:酒泉市\",\"6210:庆阳市\",\"6211:定西市\",\"6212:陇南市\",\"6229:临夏回族自治州\",\"6230:甘南藏族自治州\"];\"6300:青海省\" =[\"6301:西宁市\",\"6321:海东地区\",\"6322:海北藏族自治州\",\"6323:黄南藏族自治州\",\"6325:海南藏族自治州\",\"6326:果洛藏族自治州\",\"6327:玉树藏族自治州\",\"6328:海西蒙古族藏族自治州\"];\"5400:西藏自治区\" =[\"5401:拉萨市\",\"5421:昌都地区\",\"5422:山南地区\",\"5423:日喀则地区\",\"5424:那曲地区\",\"5425:阿里地区\",\"5426:林芝地区\"];\"6500:新疆维吾尔自治区\" =[\"6501:乌鲁木齐市\",\"6502:克拉玛依市\",\"6521:吐鲁番地区\",\"6522:哈密地区\",\"6523:昌吉回族自治州\",\"6527:博尔塔拉蒙古自治州\",\"6528:巴音郭楞蒙古自治州\",\"6529:阿克苏地区\",\"6530:克孜勒苏柯尔克孜自治州\",\"6531:喀什地区\",\"6532:和田地区\",\"6540:伊犁哈萨克自治州\",\"6542:塔城地区\",\"6543:阿勒泰地区\",\"659001:石河子市\",\"659002:阿拉尔市\",\"659003:图木舒克市\",\"659004:五家渠市\"];\"3400:安徽省\" =[\"3401:合肥市\",\"3402:芜湖市\",\"3403:蚌埠市\",\"3404:淮南市\",\"3405:马鞍山市\",\"3406:淮北市\",\"3407:铜陵市\",\"3408:安庆市\",\"3410:黄山市\",\"3411:滁州市\",\"3412:阜阳市\",\"3413:宿州市\",\"3414:巢湖市\",\"3415:六安市\",\"3416:亳州市\",\"3417:池州市\",\"3418:宣城市\"];\"3300:浙江省\" =[\"3301:杭州市\",\"3302:宁波市\",\"3303:温州市\",\"3304:嘉兴市\",\"3305:湖州市\",\"3306:绍兴市\",\"3307:金华市\",\"3308:衢州市\",\"3309:舟山市\",\"3310:台州市\",\"3311:丽水市\"];\"3500:福建省\" =[\"3501:福州市\",\"3502:厦门市\",\"3503:莆田市\",\"3504:三明市\",\"3505:泉州市\",\"3506:漳州市\",\"3507:南平市\",\"3508:龙岩市\",\"3509:宁德市\"];\"8100:香港特别行政区\" =[\"8101:中西区\",\"8102:湾仔区\",\"8103:东区\",\"8104:南区\",\"8105:油尖旺区\",\"8106:深水埗区\",\"8107:九龙城区\",\"8108:黄大仙区\",\"8109:观塘区\",\"8110:荃湾区\",\"8111:葵青区\",\"8112:沙田区\",\"8113:西贡区\",\"8114:大埔区\",\"8115:北区\",\"8116:元朗区\",\"8117:屯门区\",\"8118:离岛区\"]"
                       atIndex:[citiesString length]];
    
    cityID = [[NSMutableString alloc] initWithCapacity:0];
    
    NSRange range = [citiesString rangeOfString:@"\""];
    while (range.location != NSNotFound)
    {
        [citiesString deleteCharactersInRange:range];
        range = [citiesString rangeOfString:@"\""];
    }
    NSRange range1 = [citiesString rangeOfString:@" "];
    while (range1.location != NSNotFound)
    {
        [citiesString deleteCharactersInRange:range1];
        range1 = [citiesString rangeOfString:@" "];
    }
    schoolType  = @"highschool";
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    bgView.backgroundColor = [UIColor grayColor];
    [self.bgView addSubview:bgView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:view];
    
    buttonbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 30)];
    buttonbg.backgroundColor = [UIColor redColor];
    [bgView addSubview:buttonbg];
    
    NSArray *buttonNames = [NSArray arrayWithObjects:@"高中",@"初中",@"小学", nil];
    for (int i=0; i<[buttonNames count]; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(SCREEN_WIDTH/2*i, 0, SCREEN_WIDTH/2, 30);
        [button setTitle:[buttonNames objectAtIndex:i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0)
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [bgView addSubview:button];
    }
    
    CGFloat tableViewHeight = 30;
    
    provinceArray = [[NSMutableArray alloc] initWithCapacity:0];
    provinceOpen = NO;
    provinceIndex = 0;
    provinceTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, YSTART+40, SCREEN_WIDTH-20, tableViewHeight) style:UITableViewStylePlain];
    provinceTableView.tag = 2000;
    provinceTableView.delegate = self;
    provinceTableView.dataSource = self;
    provinceTableView.bounces = NO;
    provinceTableView.backgroundColor = [UIColor clearColor];
    
    
    cityArray = [[NSMutableArray alloc] initWithCapacity:0];
    cityOpen = NO;
    cityIndex = 0;
    cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, YSTART+40+50, SCREEN_WIDTH-20, tableViewHeight) style:UITableViewStylePlain];
    cityTableView.tag = 2001;
    cityTableView.bounces = NO;
    cityTableView.delegate = self;
    cityTableView.dataSource = self;
    cityTableView.backgroundColor = [UIColor greenColor];
    
    
    areaArray = [[NSMutableArray alloc] initWithCapacity:0];
    areaOpen = NO;
    areaIndex = 0;
    areaTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, YSTART+100+40, SCREEN_WIDTH-20, tableViewHeight) style:UITableViewStylePlain];
    areaTableView.tag = 2002;
    areaTableView.bounces = NO;
    areaTableView.delegate = self;
    areaTableView.dataSource = self;
    areaTableView.backgroundColor = [UIColor greenColor];
    
    
    schoolArray = [[NSMutableArray alloc] initWithCapacity:0];
    schoolOpen = NO;
    schoolIndex = 0;
    schoolTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, YSTART+150+40, SCREEN_WIDTH-20, tableViewHeight) style:UITableViewStylePlain];
    schoolTableView.tag = 2003;
    schoolTableView.bounces = NO;
    schoolTableView.delegate = self;
    schoolTableView.dataSource = self;
    schoolTableView.backgroundColor = [UIColor greenColor];
    [bgView addSubview:schoolTableView];
    [bgView addSubview:areaTableView];
    [bgView addSubview:cityTableView];
    [bgView addSubview:provinceTableView];
    
    //省
    [self getProvince];
//    [self writeToFile];
//    [self saveToDatabase];
    [self updateData];

}

-(void)unShowSelfViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveToDatabase
{
    OperatDB *db = [[OperatDB alloc] init];
    [db createTableWithSchoolType:@"highschool"];
    [db createTableWithSchoolType:@"juniorschool"];
    
    for (int i=0; i<[provinceArray count]; ++i)
    {
        NSDictionary *provinceDict = [provinceArray objectAtIndex:i];
        NSLog(@"province-%d- %@ == %@ begin...",i,[[provinceDict allKeys] firstObject],[[provinceDict allValues] firstObject]);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:[[provinceDict allValues] firstObject]  forKey:[[provinceDict allKeys] firstObject]];
        
        NSArray *tmpCityArray = [self getCityWithProvinceDict:provinceDict];
        
        
        for (int i=0; i<[tmpCityArray count]; ++i)
        {
            NSDictionary *cityDict = [cityArray objectAtIndex:i];
            NSArray *tmpAreaArray = [self AnalyticalQu:cityDict];
            
            NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [dict1 setObject:[[cityDict allValues] firstObject] forKey:[[cityDict allKeys] firstObject]];
            
            [cityID deleteCharactersInRange:NSMakeRange(0, [cityID length])];
            [cityID insertString:[[cityDict allKeys] firstObject] atIndex:[cityID length]];
            
            for (int i=0; i<[tmpAreaArray count]; ++i)
            {
                NSDictionary *areaDict = [tmpAreaArray objectAtIndex:i];
                NSString *areaKey = [[areaDict allKeys] firstObject];
                NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] initWithCapacity:0];
                [dict2 setObject:[areaDict objectForKey:areaKey] forKey:areaKey];
                schoolType = @"highschool";
                NSArray *schoolArray1 = [self AnalyticalSchoolWithAreaID:areaKey];
                for (int i=0; i<[schoolArray1 count]; ++i)
                {
                    schoolCount++;
                    School *school = [[School alloc] init];
                    school.province = [[provinceDict allValues] firstObject];
                    school.city = [[cityDict allValues] firstObject];
                    school.area = [[areaDict allValues] firstObject];
                    school.schoolname = [schoolArray1 objectAtIndex:i];
                    [db saveSchool:school andSchoolType:@"highschool"];
                }
                schoolType = @"juniorschool";
                NSArray *schoolArray2 = [self AnalyticalSchoolWithAreaID:areaKey];
                for (int i=0; i<[schoolArray2 count]; ++i)
                {
                    schoolCount++;
                    schoolCount++;
                    School *school = [[School alloc] init];
                    school.province = [[provinceDict allValues] firstObject];
                    school.city = [[cityDict allValues] firstObject];
                    school.area = [[areaDict allValues] firstObject];
                    school.schoolname = [schoolArray2 objectAtIndex:i];
                    [db saveSchool:school andSchoolType:@"juniorschool"];
                }
            }
        }
    }
    NSLog(@"school count %d",schoolCount);
}

-(void)writeToFile
{
    NSString *provincePath = [NSString stringWithFormat:@"/Users/tike/Desktop/province/city.plist"];
    NSMutableArray *rootArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<[provinceArray count]; ++i)
    {
        NSDictionary *provinceDict = [provinceArray objectAtIndex:i];
        NSLog(@"provincedict %d-- %@ == %@ begin...",i,[[provinceDict allKeys] firstObject],[[provinceDict allValues] firstObject]);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:[[provinceDict allValues] firstObject]  forKey:[[provinceDict allKeys] firstObject]];
        
        NSArray *tmpCityArray = [self getCityWithProvinceDict:provinceDict];
        
//        NSMutableArray *cityArray1 = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i=0; i<[tmpCityArray count]; ++i)
        {
            NSDictionary *cityDict = [cityArray objectAtIndex:i];
            NSArray *tmpAreaArray = [self AnalyticalQu:cityDict];
            
            NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [dict1 setObject:[[cityDict allValues] firstObject] forKey:[[cityDict allKeys] firstObject]];
            
            [cityID deleteCharactersInRange:NSMakeRange(0, [cityID length])];
            [cityID insertString:[[cityDict allKeys] firstObject] atIndex:[cityID length]];
            
            NSMutableArray *areaArray1 = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i=0; i<[tmpAreaArray count]; ++i)
            {
                NSDictionary *areaDict = [tmpAreaArray objectAtIndex:i];
                NSString *areaKey = [[areaDict allKeys] firstObject];
                NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSRange range = [areaKey rangeOfString:@"qu_"];
                if (range.location != NSNotFound)
                {
                    [dict2 setObject:[areaDict objectForKey:areaKey] forKey:[areaKey substringFromIndex:range.location+range.length]];
                }
                schoolType = @"highschool";
                NSArray *schoolArray1 = [self AnalyticalSchoolWithAreaID:areaKey];
                for (int i=0; i<[schoolArray1 count]; ++i)
                {
                    NSString *str = [NSString stringWithFormat:@"%@.%@.%@.%@",[[provinceDict allValues] firstObject],[[cityDict allValues] firstObject],[areaDict objectForKey:areaKey],[schoolArray1 objectAtIndex:i]];
                    [rootArray addObject:str];
                }
//                [dict2 setObject:schoolArray1 forKey:@"high"];
                schoolType = @"juniorschool";
                NSArray *schoolArray2 = [self AnalyticalSchoolWithAreaID:areaKey];
                for (int i=0; i<[schoolArray2 count]; ++i)
                {
                    NSString *str = [NSString stringWithFormat:@"%@.%@.%@.%@",[[provinceDict allValues] firstObject],[[cityDict allValues] firstObject],[areaDict objectForKey:areaKey],[schoolArray2 objectAtIndex:i]];
                    [rootArray addObject:str];
                }
//                [dict2 setObject:schoolArray2 forKey:@"junior"];
//                [areaArray1 addObject:dict2];
            }
            
//            [dict1 setObject:areaArray1 forKey:@"areas"];
//            
//            [cityArray1 addObject:dict1];
            
        }
        
//        [dict setObject:cityArray1 forKey:@"cities"];
//        [rootArray addObject:dict];
    }
    [rootArray writeToFile:provincePath atomically:YES];
    NSLog(@"write completed!");
}

-(void)updateData
{
    //市
    NSDictionary *dict = [provinceArray objectAtIndex:provinceIndex];
    [self getCityWithProvinceDict:dict];
    //区县
    NSDictionary *dict1 = [cityArray objectAtIndex:cityIndex];
    [cityID deleteCharactersInRange:NSMakeRange(0, [cityID length])];
    [cityID insertString:[[dict1 allKeys] firstObject] atIndex:[cityID length]];
    [self AnalyticalQu:dict1];
    //学校
    NSDictionary *dict2 = [areaArray objectAtIndex:areaIndex];
    [self AnalyticalSchoolWithAreaID:[[dict2 allKeys] firstObject]];
    
    [provinceTableView reloadData];
    [cityTableView reloadData];
    [areaTableView reloadData];
    [schoolTableView reloadData];
}

-(void)buttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        buttonbg.frame = CGRectMake(SCREEN_WIDTH/2*(button.tag - 1000), 0, SCREEN_WIDTH/2, 30);
        for(UIView *v in bgView.subviews)
        {
            if ([v isKindOfClass:[UIButton class]])
            {
                if (v.tag == button.tag)
                {
                    [(UIButton *)v setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else
                {
                    [(UIButton *)v setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        }
    }];
    
    if (button.tag == 1000)
    {
        schoolType = @"highschool";
    }
    else if(button.tag == 1001)
    {
        schoolType = @"juniorschool";
    }
    schoolIndex = 0;
    [self updateData];
}

-(void)headerButtonClick:(UIButton *)button
{
    if (button.tag == 2000)
    {
        provinceOpen = !provinceOpen;
        cityOpen = NO;
        areaOpen = NO;
        schoolOpen = NO;
    }
    else if (button.tag == 2001)
    {
        provinceOpen = NO;
        cityOpen = !cityOpen;
        areaOpen = NO;
        schoolOpen = NO;

    }
    else if(button.tag == 2002)
    {
        provinceOpen = NO;
        cityOpen = NO;
        areaOpen = !areaOpen;
        schoolOpen = NO;
    }
    else if(button.tag == 2003)
    {
        provinceOpen = NO;
        cityOpen = NO;
        areaOpen = NO;
        schoolOpen = !schoolOpen;
    }
    [self updateData];
//    [provinceTableView reloadData];
//    [cityTableView reloadData];
//    [areaTableView reloadData];
//    [schoolTableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 30)];
    headerView.backgroundColor = [UIColor greenColor];
    if (tableView.tag == 2000)
    {
        NSDictionary *dict = [provinceArray objectAtIndex:provinceIndex];
        provinceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 30)];
        provinceLabel.backgroundColor = [UIColor clearColor];
        provinceLabel.text = [[dict allValues] firstObject];
        [headerView addSubview:provinceLabel];
    }
    else if (tableView.tag == 2001)
    {
        NSDictionary *dict = [cityArray objectAtIndex:cityIndex];
        cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 30)];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.text = [[dict allValues] firstObject];
        [headerView addSubview:cityLabel];
    }
    else if (tableView.tag == 2002)
    {
        NSDictionary *dict = [areaArray objectAtIndex:areaIndex];
        areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 30)];
        areaLabel.backgroundColor = [UIColor clearColor];
        areaLabel.text = [[dict allValues] firstObject];
        [headerView addSubview:areaLabel];
    }
    else if (tableView.tag == 2003)
    {
        schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 30)];
        schoolLabel.backgroundColor = [UIColor clearColor];
        if ([schoolArray count] > 0)
        {
            schoolLabel.text = [schoolArray objectAtIndex:schoolIndex];
        }
        else
        {
            schoolLabel.text = @"这里暂时还没有学校";
        }
        [headerView addSubview:schoolLabel];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, SCREEN_WIDTH-50, 30);
    button.backgroundColor = [UIColor clearColor];
    button.tag = tableView.tag;
    [button addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 2000)
    {
        if (!provinceOpen)
        {
            [UIView animateWithDuration:0.2 animations:^{
                provinceTableView.frame = CGRectMake(10, YSTART+40, SCREEN_WIDTH-20, 30);
                cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                NSLog(@"close %.0f--%.0f",cityTableView.frame.origin.y,cityTableView.frame.size.height);
            }];
            return 0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat height = (30*[provinceArray count]>200?200:(30*[provinceArray count]+30));
            provinceTableView.frame = CGRectMake(10, YSTART+40, SCREEN_WIDTH-20, height);
            cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            NSLog(@"pro open %.0f--%.0f",provinceTableView.frame.origin.y,provinceTableView.frame.size.height);
            NSLog(@"open %.0f--%.0f",cityTableView.frame.origin.y,cityTableView.frame.size.height);
        }];
        return [provinceArray count];
    }
    else if(tableView.tag == 2001)
    {
        if (!cityOpen)
        {
            [UIView animateWithDuration:0.2 animations:^{
                cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            }];
            return 0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat height = (30*[cityArray count]>200?200:(30*[cityArray count]+30));
            cityTableView.frame = CGRectMake(10, provinceTableView.frame.origin.y+provinceTableView.frame.size.height+20, SCREEN_WIDTH-20, height);
            areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
        }];
        return [cityArray count];
    }
    else if(tableView.tag == 2002)
    {
        if (!areaOpen)
        {
            [UIView animateWithDuration:0.2 animations:^{
                areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
                schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            }];
            return 0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat height = (30*[areaArray count]>200?200:(30*[areaArray count]+30));
            areaTableView.frame = CGRectMake(10, cityTableView.frame.origin.y+cityTableView.frame.size.height+20, SCREEN_WIDTH-20, height);
            schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
        }];
        return [areaArray count];
    }
    else if(tableView.tag == 2003)
    {
        if (!schoolOpen)
        {
            [UIView animateWithDuration:0.2 animations:^{
                schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, 30);
            }];
            return 0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat height = (30*[schoolArray count]>200?200:(30*[schoolArray count]+30));
            schoolTableView.frame = CGRectMake(10, areaTableView.frame.origin.y+areaTableView.frame.size.height+20, SCREEN_WIDTH-20, height);
        }];
        return [schoolArray count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000)
    {
        static NSString *proviceName = @"province";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:proviceName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:proviceName];
        }
        NSDictionary *dict = [provinceArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:[[dict allKeys] firstObject]];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        return cell;
    }
    else if(tableView.tag == 2001)
    {
        static NSString *cityName = @"city";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityName];
        }
        NSDictionary *dict = [cityArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:[[dict allKeys] firstObject]];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        return cell;
    }
    else if(tableView.tag == 2002)
    {
        static NSString *areaName = @"area";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:areaName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:areaName];
        }
        NSDictionary *dict = [areaArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:[[dict allKeys] firstObject]];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        return cell;
    }
    else if(tableView.tag == 2003)
    {
        static NSString *schoolName = @"school";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolName];
        }
        cell.textLabel.text = [schoolArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000)
    {
        provinceIndex = indexPath.row;
        cityIndex = 0;
        areaIndex = 0;
        schoolIndex = 0;
    }
    else if(tableView.tag == 2001)
    {
        cityIndex = indexPath.row;
        areaIndex = 0;
        schoolIndex = 0;
    }
    else if(tableView.tag == 2002)
    {
        areaIndex = indexPath.row;
        schoolIndex = 0;
    }
    else if(tableView.tag == 2003)
    {
        schoolIndex = indexPath.row;
    }
    provinceOpen = NO;
    cityOpen = NO;
    areaOpen = NO;
    schoolOpen = NO;
    [self updateData];
}
-(void)getProvince
{
    
//高中    juniorschool
    NSMutableArray *tmpProvinceArray = [[NSMutableArray alloc] initWithArray:[citiesString componentsSeparatedByString:@";"]];
    for (int i=0; i<[tmpProvinceArray count]; ++i)
    {
        NSArray *array1 = [[tmpProvinceArray objectAtIndex:i] componentsSeparatedByString:@"="];
        NSArray *array2 = [[array1 firstObject] componentsSeparatedByString:@":"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:[array2 lastObject] forKey:[array2 firstObject]];
        [provinceArray addObject:dict];
    }
}

-(NSArray *)getCityWithProvinceDict:(NSDictionary *)provinceDict
{
    [cityArray removeAllObjects];
    NSString *provinceNum = [[provinceDict allKeys] firstObject];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    if([self isInZhiXia:[provinceNum substringToIndex:2]])
    {
        NSString *cityName;
        NSMutableString *cityNum = [[NSMutableString alloc] initWithCapacity:0];
        NSString *key = [[provinceDict allKeys] firstObject];
        cityName = [provinceDict objectForKey:key];
        [cityNum insertString:[key substringToIndex:3] atIndex:[cityNum length]];
        [cityNum insertString:@"1" atIndex:[cityNum length]];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:cityName forKey:cityNum];
        [cityArray addObject:dict];
        [tmpArray addObject:dict];
    }
    else
    {
        NSRange range1 = [citiesString rangeOfString:provinceNum];
        NSString *str1 = [citiesString substringFromIndex:range1.location+range1.length];
        NSRange range2 = [str1 rangeOfString:@"=["];
        NSString *str2 = [str1 substringFromIndex:range2.location+range2.length];
        NSRange range3 = [str2 rangeOfString:@"];"];
        NSMutableString *str3 = [[NSMutableString alloc] initWithCapacity:0];;
        [str3 insertString:[str2 substringToIndex:range3.location] atIndex:[str3 length]];
        NSArray *array = [str3 componentsSeparatedByString:@","];
        for (int i=0; i<[array count]; ++i)
        {
            NSString *cityStr = [array objectAtIndex:i];
            NSRange range = [cityStr rangeOfString:@":"];
            NSString *cityNum = [cityStr substringToIndex:range.location];
            NSString *cityName = [cityStr substringFromIndex:range.location+range.length];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:cityName  forKey:cityNum];
            [cityArray addObject:dict];
            [tmpArray addObject:dict];
        }
    }
    return tmpArray;
}
/*
 11 北京
 12 天津
 31 上海
 50 重庆
 81 香港
 */
-(BOOL)isInZhiXia:(NSString *)str
{
    NSArray *array = [NSArray arrayWithObjects:@"11",@"12",@"31",@"50",@"81", nil];
    NSString *substr = [str substringToIndex:2];
    for (int i=0; i<[array count]; ++i)
    {
        if ([substr isEqualToString:[array objectAtIndex:i]])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isInTeShu:(NSString *)str
{
    NSArray *array = [NSArray arrayWithObjects:@"429",@"469",@"659", nil];
    NSString *substr = [str substringToIndex:3];
    for (int i=0; i<[array count]; ++i)
    {
        if ([substr isEqualToString:[array objectAtIndex:i]])
        {
            return YES;
        }
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)AnalyticalQu:(NSDictionary *)quDict
{
    [areaArray removeAllObjects];
    NSMutableArray *tmpAreaArry = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *quNum = [[quDict allKeys] firstObject];
    NSString *highStr = [NSString stringWithFormat:@"http://support.renren.com/highschool/%@.html",quNum];
    NSString *quStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:highStr] encoding:NSUTF8StringEncoding error:nil];
    
    NSRange rang1=[quStr rangeOfString:@"<ul id=\"schoolCityQuList\" class=\"module-qulist\">"];
    if (rang1.length >0)
    {
        NSMutableString *quStr2=[[NSMutableString alloc]initWithString:[quStr substringFromIndex:rang1.location+rang1.length]];
        NSRange rang2=[quStr2 rangeOfString:@"</ul>"];
        NSMutableString *quStr3=[[NSMutableString alloc]initWithString:[quStr2 substringToIndex:rang2.location]];
        NSData *dataTitle=[quStr3 dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
        NSArray *elements=[xpathParser searchWithXPathQuery:@"//a"];
        quArray=[[NSMutableArray alloc]init];
        for (TFHppleElement *element in elements)
        {
            NSString *quququ = [element objectForKey:@"onclick"];
            NSRange range = [quququ rangeOfString:@"city_qu_"];
            NSString *aaa = [quququ substringFromIndex:range.location];
            NSString *quid = [aaa substringToIndex:[aaa length]-2];
            NSMutableDictionary *quDict = [NSMutableDictionary dictionaryWithObject:[element content] forKey:quid];
            [quArray addObject:quDict];
            [areaArray addObject:quDict];
            [tmpAreaArry addObject:quDict];
        }
    }
    else
    {
        [areaArray addObject:quDict];
        [tmpAreaArry addObject:quDict];
    }
    return tmpAreaArry;
}

-(NSMutableArray *)AnalyticalSchoolWithAreaID:(NSString *)quID
{
    NSMutableArray *tmpSchoolArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *areaID = [[NSMutableString alloc]initWithCapacity:0];
    NSRange range = [quID rangeOfString:@"city_qu_"];
    if (range.location == NSNotFound)
    {
        [areaID insertString:@"city_qu_" atIndex:[areaID length]];
        [areaID insertString:quID atIndex:[areaID length]];
    }
    else
    {
        [areaID insertString:quID atIndex:[areaID length]];
    }
    NSString *url = [NSString stringWithFormat:@"http://support.renren.com/%@/%@.html",schoolType,cityID];
    NSString *quStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    NSRange rang1=[quStr rangeOfString:[NSString stringWithFormat:@"<ul id=\"%@\" style=\"display:none;\">",areaID]];
    
    if (rang1.length > 0)
    {
        NSMutableString *quStr2=[[NSMutableString alloc]initWithString:[quStr substringFromIndex:rang1.location+rang1.length]];
        NSRange rang2=[quStr2 rangeOfString:@"</ul>"];
        NSMutableString *quStr3=[[NSMutableString alloc]initWithString:[quStr2 substringToIndex:rang2.location]];
        NSData *dataTitle=[quStr3 dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
        NSArray *elements=[xpathParser searchWithXPathQuery:@"//a"];
        schoolArray=[[NSMutableArray alloc]init];
        for (TFHppleElement *element in elements)
        {
            [schoolArray addObject:[element content]];
            [tmpSchoolArray addObject:[element content]];
        }
    }
    return tmpSchoolArray;
}
@end