//
//  ChooseSchoolViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "ChooseSchoolViewController.h"
#import "Header.h"
#import "ClassesViewController.h"
#import "CreateClassViewController.h"

@interface ChooseSchoolViewController ()<UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate>
{
    UIImageView *selectView;
//    UITextField *searchTextField;
    
    NSMutableArray *tmpArray;
    NSDictionary *tmpDict;
    
    NSString *levelStr;
    
    UILabel *tipLabel;
    UIButton *createClassButton;
    
    UISearchBar *mySearchBar;
    UITableView *searchResultTableView;
}
@end

@implementation ChooseSchoolViewController

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
    
    self.titleLabel.text = @"请选择学校";
    
    levelStr = @"1";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    selectView = [[UIImageView alloc] init];
    [selectView setImage:[UIImage imageNamed:@"select"]];
    selectView.frame = CGRectMake(15, UI_NAVIGATION_BAR_HEIGHT+10, (SCREEN_WIDTH-30)/3, 30);
    [self.bgView addSubview:selectView];
    
    NSArray *buttonNamesArray = [NSArray arrayWithObjects:@"小学",@"中学",@"其他", nil];
    NSArray *buttonBgArray = [NSArray arrayWithObjects:@"left",@"mid",@"right", nil];
    for (int i=0; i<[buttonNamesArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((SCREEN_WIDTH-30)/3*i+15, UI_NAVIGATION_BAR_HEIGHT+10, (SCREEN_WIDTH-30)/3, 30);
        [button setTitle:[buttonNamesArray objectAtIndex:i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0)
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        }
        [button setBackgroundImage:[UIImage imageNamed:[buttonBgArray objectAtIndex:i]] forState:UIControlStateNormal];
        [self.bgView addSubview:button];
    }
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(15, selectView.frame.size.height+selectView.frame.origin.y, SCREEN_WIDTH-30, 40)];
    mySearchBar.delegate = self;
    mySearchBar.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:mySearchBar];
    
    UITextField* searchField = nil;
    for (UIView* subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchField = (UITextField*)subview;
            searchField.leftView=nil;
            searchField.placeholder = @"输入学校名称或所在地区";
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
//    
//    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2)];
//    
//    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:mySearchBar.frame];
//    inputImageView.image = inputImage;
//    [self.bgView insertSubview:inputImageView belowSubview:mySearchBar];

    
    searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, mySearchBar.frame.origin.y+mySearchBar.frame.size.height, SCREEN_WIDTH-30, SCREEN_HEIGHT - mySearchBar.frame.origin.y-mySearchBar.frame.size.height) style:UITableViewStylePlain];
    searchResultTableView.backgroundColor = [UIColor clearColor];
    searchResultTableView.dataSource = self;
    searchResultTableView.delegate = self;
    searchResultTableView.backgroundColor = [UIColor clearColor];
    searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:searchResultTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - searchbardelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithText:searchText];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchResultTableView reloadData];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
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


-(void)handleSearchItem:(NSString *)itemStr
{
    
}


-(void)buttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        selectView.frame = CGRectMake((SCREEN_WIDTH-30)/3*(button.tag-1000)+15, UI_NAVIGATION_BAR_HEIGHT+10, (SCREEN_WIDTH-30)/3, 30);
        if (button.tag - 1000 == 0)
        {
            levelStr = @"1";
        }
        else if(button.tag-1000 == 1)
        {
            levelStr = @"2";
        }
        else if(button.tag-1000 == 2)
        {
            levelStr = @"3";
        }
        
    } completion:^(BOOL finished) {
        for (int i=1000; i<1003; i++)
        {
            if (i == button.tag)
            {
                [(UIButton *)[self.bgView viewWithTag:i] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else
            {
                [(UIButton *)[self.bgView viewWithTag:i] setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
            }
        }
    }];
    
    [self searchWithText:mySearchBar.text];
}

-(void)searchWithText:(NSString *)searchContent
{
    [tmpArray removeAllObjects];
    if ([searchContent length] <= 0)
    {
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"name":searchContent,@"token":[Tools client_token],@"u_id":[Tools user_id],@"level":levelStr} API:SEARCHSCHOOL];
        
        [tipLabel removeFromSuperview];
        [createClassButton removeFromSuperview];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"schoolSearchResult responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                tmpDict = [responseDict objectForKey:@"data"];
                if ([tmpDict count]<=0)
                {
                    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+10, SCREEN_WIDTH-30, 40)];
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.text = [NSString stringWithFormat:@"我们在数据库里没有查到您输入的学校，班级小组会尽快为您核实信息。"];
                    tipLabel.numberOfLines = 2;
                    tipLabel.textColor = TITLE_COLOR;
                    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    tipLabel.font = [UIFont systemFontOfSize:16];
                    tipLabel.textAlignment = NSTextAlignmentCenter;
                    [self.bgView addSubview:tipLabel];
                    
                    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
                    createClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
                    createClassButton.frame = CGRectMake(SCREEN_WIDTH/2-40, tipLabel.frame.size.height+tipLabel.frame.origin.y+40, 80, 30);
                    [createClassButton addTarget:self action:@selector(createClassClick) forControlEvents:UIControlEventTouchUpInside];
                    [self.bgView addSubview:createClassButton];
                    [createClassButton setBackgroundImage:btnImage forState:UIControlStateNormal];
                    searchResultTableView.hidden = YES;
                }
                else
                {
                    [createClassButton removeFromSuperview];;
                    [tipLabel removeFromSuperview];
                    searchResultTableView.hidden = NO;
                    [searchResultTableView reloadData];
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
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }

}

-(void)createClassClick
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"name":[mySearchBar text],
                                                                      @"level":levelStr} API:CREATESCHOOL];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *schoolID = [responseDict objectForKey:@"data"];
                CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
                createClassViewController.schoolName = mySearchBar.text;
                createClassViewController.schoolLevel = levelStr;
                createClassViewController.schoollID = schoolID;
                [createClassViewController showSelfViewController:self];
                [mySearchBar resignFirstResponder];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tmpDict count]>0)
    {
        return [[tmpDict allKeys] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *schoolName = @"schoolname";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolName];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolName];
    }
    NSString *key = [[tmpDict allKeys] objectAtIndex:indexPath.row];
    NSDictionary *dict = [tmpDict objectForKey:key];
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[tmpDict allKeys] objectAtIndex:indexPath.row];
    NSDictionary *dict = [tmpDict objectForKey:key];

    ClassesViewController *classesViewController = [[ClassesViewController alloc] init];
    classesViewController.schoolName = [dict objectForKey:@"name"];
    classesViewController.schoollID = [dict objectForKey:@"_id"];
    classesViewController.schoolLevel = levelStr;
    [classesViewController showSelfViewController:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [mySearchBar resignFirstResponder];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [mySearchBar resignFirstResponder];
}
#pragma mark - aboutInput
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in self.bgView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            if (![v isExclusiveTouch])
            {
                [v resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    self.bgView.center = CENTER_POINT;
                }completion:^(BOOL finished) {
                    
                }];
            }
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        
    }completion:^(BOOL finished) {
        
    }];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}


@end
