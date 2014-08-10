//
//  SelectCityViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/16/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SelectCityViewController.h"
#import "ChineseToPinyin.h"

#define SEARCHTAG   1000
#define HOTTAG      2000

@interface SelectCityViewController ()<UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    UISearchBar *mySearchBar;
    UITableView *searchResultTableView;
    UITableView *hotTableView;
    OperatDB *db;
    
    UIView *searchView;
    
    NSMutableArray *cityArray;
    NSMutableArray *searchArray;
    NSMutableArray *hotCityArray;
    
    UITapGestureRecognizer *tapTgr;
}
@end

@implementation SelectCityViewController
@synthesize selectCityDel;
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
    
    self.titleLabel.text = @"选择城市";
    
    db = [[OperatDB alloc] init];
    
    
    tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
    searchView.userInteractionEnabled = YES;
    [searchView addGestureRecognizer:tapTgr];
    
    cityArray = [[NSMutableArray alloc] initWithCapacity:0];
    searchArray = [[NSMutableArray alloc] initWithCapacity:0];
    hotCityArray = [[NSMutableArray alloc] initWithCapacity:0];

    
    NSArray *array = @[@"北京",@"天津",@"上海",@"广州",@"海南"];
    for (int i=0; i<[array count]; i++)
    {
        NSArray *tmparray = [db findSetWithDictionary:@{@"cityname":[array objectAtIndex:i],@"citylevel":@"2"} andTableName:CITYTABLE];
        if ([tmparray count] > 0)
        {
            [hotCityArray addObject:[tmparray firstObject]];
        }
    }
    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH-20, SCREEN_HEIGHT-40-UI_TAB_BAR_HEIGHT-43)];
    searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.bgView addSubview:searchView];
    [self.bgView sendSubviewToBack:searchView];
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(5, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH-10, 40)];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"输入城市名称";
    mySearchBar.backgroundColor = RGB(214, 214, 214, 1);
    [self.bgView addSubview:mySearchBar];
    
    UITextField* searchField = nil;
    for (UIView* subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchField = (UITextField*)subview;
            searchField.frame = CGRectMake(0, 0, mySearchBar.frame.size.width, 40);
            [searchField setBackground:nil];
            searchField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
            [searchField setBackgroundColor:[UIColor clearColor]];
            [searchField setBorderStyle:UITextBorderStyleNone];
            break;
        }
    }
    
    for (UIView *subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }

    searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    searchResultTableView.backgroundColor = [UIColor whiteColor];
    searchResultTableView.dataSource = self;
    searchResultTableView.delegate = self;
    searchResultTableView.tag = SEARCHTAG;
    searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [searchView addSubview:searchResultTableView];
    
    if (SYSVERSION >= 7.0)
    {
        searchResultTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    
    hotTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, mySearchBar.frame.origin.y+mySearchBar.frame.size.height, SCREEN_WIDTH-10, SCREEN_HEIGHT - mySearchBar.frame.origin.y-mySearchBar.frame.size.height-5) style:UITableViewStylePlain];
    hotTableView.tag = HOTTAG;
    hotTableView.delegate = self;
    hotTableView.dataSource = self;
    hotTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    hotTableView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:hotTableView];
    hotTableView.sectionIndexTrackingBackgroundColor=[UIColor grayColor];
    
    [self getCities];
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

-(void)getCities
{
    NSArray *array = [db findSetWithDictionary:@{@"citylevel":@"2"} orderByName:@"cityname" andTableName:CITYTABLE];
    if ([array count] > 0)
    {
        [cityArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:array andKey:@"cityname"]];
        [hotTableView reloadData];
    }
}

#pragma mark - searchcity

-(void)cancelSearch
{
    [searchArray removeAllObjects];
    mySearchBar.text = nil;
    //    [searchResultTableView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        [self.bgView sendSubviewToBack:searchView];
        searchResultTableView.hidden = YES;
        mySearchBar.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 40);
        searchResultTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        mySearchBar.showsCancelButton = NO;
        hotTableView.hidden = NO;
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }];
    
    [mySearchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        [searchView addGestureRecognizer:tapTgr];
        [self.bgView bringSubviewToFront:searchView];
        mySearchBar.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, 40);
        searchResultTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        searchView.frame = CGRectMake(0, 40+YSTART, SCREEN_WIDTH, SCREEN_HEIGHT-40);
        hotTableView.hidden = YES;
        searchResultTableView.hidden = NO;
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        searchBar.showsCancelButton = YES;
    }];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithText:searchText];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchContent = [searchBar text];
    [self searchWithText:searchContent];
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    DDLOG_CURRENT_METHOD;
}
-(void)searchWithText:(NSString *)searchContent
{
    [searchArray removeAllObjects];
    if ([searchContent length] > 0)
    {
        NSArray *classMemberArray = [db fuzzyfindSetWithDictionary:@{@"citylevel":@"2"}
                                                      andTableName:CITYTABLE
                                                andFuzzyDictionary:@{@"cityname":mySearchBar.text,
                                                                     @"jianpin":mySearchBar.text,
                                                                     @"quanpin":mySearchBar.text}];
        for (int i=0; i<[classMemberArray count]; ++i)
        {
            NSDictionary *dict = [classMemberArray objectAtIndex:i];
            [searchArray addObject:dict];
        }
    }
    [searchResultTableView reloadData];
}


-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag == HOTTAG)
    {
        NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *letters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
        [sectionArray addObject:@"*"];
        for (int i=0; i<[letters count]; ++i)
        {
            NSString *letter = [letters objectAtIndex:i];
            for (int j=0; j<[cityArray count]; ++j)
            {
                NSString *first = [[cityArray objectAtIndex:j] objectForKey:@"key"];
                if ([letter isEqualToString:first])
                {
                    [sectionArray addObject:letter];
                }
            }
        }
        return sectionArray;

    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == HOTTAG)
    {
        return [cityArray count]+1;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == HOTTAG)
    {
        if (section == 0)
        {
            return [hotCityArray count];
        }
        NSDictionary *dict = [cityArray objectAtIndex:section-1];
        return [[dict objectForKey:@"count"] integerValue];
    }
    [UIView animateWithDuration:0.2 animations:^{
        searchResultTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [searchArray count]*40>(SCREEN_HEIGHT-40)?(SCREEN_HEIGHT-40):([searchArray count]*40));
    }];
    if ([searchArray count] > 0)
    {
        [searchView removeGestureRecognizer:tapTgr];
    }
    else
    {
        [searchView addGestureRecognizer:tapTgr];
    }
    return [searchArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == HOTTAG)
    {
        return 30;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == HOTTAG)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 26.5)];
        //    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
        headerView.backgroundColor = RGB(234, 234, 234, 1);
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1.5, headerView.frame.size.width, 26.5)];
        //    headerLabel.backgroundColor = UIColorFromRGB(0x4abcc2);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont systemFontOfSize:17];
        headerLabel.textColor = TITLE_COLOR;
        if (section == 0)
        {
            headerLabel.text = @"    热门城市";
        }
        else
        {
            NSDictionary *dict = [cityArray objectAtIndex:section-1];
            headerLabel.text = [NSString stringWithFormat:@"    %@",[dict objectForKey:@"key"]];
        }
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == HOTTAG)
    {
        static NSString *schoolName = @"citycell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolName];
        }
        if (indexPath.section == 0)
        {
            NSDictionary *cityDict = [hotCityArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [cityDict objectForKey:@"cityname"];
        }
        else
        {
            NSDictionary *dict = [cityArray objectAtIndex:indexPath.section-1];
            NSDictionary *cityDict = [[dict objectForKey:@"array"] objectAtIndex:indexPath.row];
            cell.textLabel.text = [cityDict objectForKey:@"cityname"];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        return cell;
    }
    else if (tableView.tag == SEARCHTAG)
    {
        static NSString *schoolName = @"searchcitycell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolName];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolName];
        }
        NSDictionary *cityDict = [searchArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [cityDict objectForKey:@"cityname"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == HOTTAG)
    {
        if (indexPath.section == 0)
        {
            NSDictionary *dict = [hotCityArray objectAtIndex:indexPath.row];
            if ([self.selectCityDel respondsToSelector:@selector(selectCityWithDict:)])
            {
                [self.selectCityDel selectCityWithDict:dict];
            }
        }
        else
        {
            NSDictionary *dict = [cityArray objectAtIndex:indexPath.section-1];
            NSDictionary *cityDict = [[dict objectForKey:@"array"] objectAtIndex:indexPath.row];
            if ([self.selectCityDel respondsToSelector:@selector(selectCityWithDict:)])
            {
                [self.selectCityDel selectCityWithDict:cityDict];
            }
        }
    }
    else if(tableView.tag == SEARCHTAG)
    {
        NSDictionary *dict = [searchArray objectAtIndex:indexPath.row];
        if ([self.selectCityDel respondsToSelector:@selector(selectCityWithDict:)])
        {
            [self.selectCityDel selectCityWithDict:dict];
        }
        [self cancelSearch];
        [self searchBarCancelButtonClicked:mySearchBar];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [mySearchBar resignFirstResponder];
    mySearchBar.showsCancelButton = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
