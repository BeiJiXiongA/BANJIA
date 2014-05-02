//
//  SubGroupViewController.m
//  School
//
//  Created by TeekerZW on 14-3-5.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "SubGroupViewController.h"
#import "Header.h"
#include "MemberCell.h"
#import "ApplyInfoViewController.h"
#import "StudentDetailViewController.h"
#import "MemberDetailViewController.h"
#import "ParentsDetailViewController.h"
@interface SubGroupViewController ()<UITableViewDataSource,
UITableViewDelegate,
ApplyInfoDelegate,
StuDetailDelegate>
{
    UITableView *tmpTableView;
}
@end

@implementation SubGroupViewController
@synthesize tmpArray,classID,admin,subGroupDel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    DDLOG(@"tmp array = %@",tmpArray);
    
    tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.backgroundColor = [UIColor clearColor];
    tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:tmpTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tmpArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *memCell = @"subgroup";
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:memCell];
    if (cell == nil)
    {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memCell];
    }
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    cell.memNameLabel.text = [dict objectForKey:@"name"];
    
    cell.remarkLabel.hidden = YES;
    cell.button2.hidden = YES;
    cell.button1.hidden = YES;
    cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH - 130, 15, 100, 30);
    if ([[dict objectForKey:@"checked"] integerValue] == 0)
    {
        cell.remarkLabel.hidden = YES;
        cell.button2.hidden = NO;
        [cell.button2 setTitle:@"查看" forState:UIControlStateNormal];
        cell.button2.tag = indexPath.row + 3000;
        [cell.button2 addTarget:self action:@selector(checkApply:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        if ([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
        {
            cell.remarkLabel.hidden = NO;
            cell.remarkLabel.text = [dict objectForKey:@"title"];
        }
        if ([[dict objectForKey:@"role"] isEqualToString:@"students"] && [[dict objectForKey:@"title"] length]>0)
        {
            cell.remarkLabel.hidden = NO;
            cell.remarkLabel.text = [dict objectForKey:@"title"];
        }

    }
    cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
    cell.headerImageView.clipsToBounds = YES;
    [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
    [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 20, 10, 16)];
    
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"line3"];
    bgImageBG.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    DDLOG(@"dict ===%@",dict);
    if ([[dict objectForKey:@"checked"] intValue] == 0)
    {
        ApplyInfoViewController *applyInfoViewController = [[ApplyInfoViewController alloc] init];
        applyInfoViewController.classID = classID;
        applyInfoViewController.applyDel = self;
        applyInfoViewController.role = [dict objectForKey:@"role"];
        applyInfoViewController.j_id = [dict objectForKey:@"uid"];
        applyInfoViewController.title = [dict objectForKey:@"title"];
        applyInfoViewController.applyName = [dict objectForKey:@"name"];
        [applyInfoViewController showSelfViewController:self];
    }
    else if ([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        MemberDetailViewController *memDetail = [[MemberDetailViewController alloc] init];
        memDetail.teacherID = [dict objectForKey:@"uid"];
        memDetail.teacherName = [dict objectForKey:@"name"];
        memDetail.classID = classID;
        memDetail.admin = YES;
        if (admin)
        {
            memDetail.admin = YES;
        }
        else
        {
            memDetail.admin = NO;
        }
        [memDetail showSelfViewController:self];
    }
    else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
    {
        ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
        parentDetail.parentID = [dict objectForKey:@"uid"];
        parentDetail.parentName = [dict objectForKey:@"name"];
        parentDetail.classID = classID;
        parentDetail.admin = YES;
        if (admin)
        {
            parentDetail.admin = YES;
        }
        else
        {
            parentDetail.admin = NO;
        }
        [parentDetail showSelfViewController:self];
    }
    else if([[dict objectForKey:@"role"] isEqualToString:@"students"])
    {
        StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
        studentDetail.studentID = [dict objectForKey:@"uid"];
        studentDetail.studentName = [dict objectForKey:@"name"];
        studentDetail.classID = classID;
        studentDetail.memDel = self;
        studentDetail.admin = YES;
        if (admin)
        {
            studentDetail.admin = YES;
        }
        else
        {
            studentDetail.admin = NO;
        }
        [studentDetail showSelfViewController:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - applydelegate
-(void)updateList:(BOOL)update
{
    if (update)
    {
        if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
        {
            [self.subGroupDel subGroupUpdate:YES];
        }
        [self unShowSelfViewController];
    }
}


#pragma mark - studentDetailDel
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
        {
            [self.subGroupDel subGroupUpdate:YES];
        }
        [self unShowSelfViewController];
    }
}

-(void)checkApply:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag - 3000];
    ApplyInfoViewController *applyInfoViewController = [[ApplyInfoViewController alloc] init];
    applyInfoViewController.classID = classID;
    applyInfoViewController.applyDel = self;
    applyInfoViewController.role = [dict objectForKey:@"role"];
    applyInfoViewController.j_id = [dict objectForKey:@"uid"];
    applyInfoViewController.title = [dict objectForKey:@"title"];
    applyInfoViewController.applyName = [dict objectForKey:@"name"];
    [applyInfoViewController showSelfViewController:self];
}

@end
