//
//  DemoVIew.m
//  MyProject
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import "DemoVIew.h"

@implementation DemoVIew
@synthesize demoTableView,dataArray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.demoTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.demoTableView.delegate = self;
        self.demoTableView.dataSource = self;
        [self addSubview:demoTableView];
    }
    return self;
}

-(void)layoutView
{
    if ([self.demoTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.demoTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    headerView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.demoTableView orientation:EGOPullOrientationDown];
    headerView.delegate = self;
    
    footerView = [[FooterView alloc] initWithScrollView:self.demoTableView];
    footerView.delegate = self;
}

-(void)getMore
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        sleep(1);
        [self.dataArray addObject:@"HH"];
            dispatch_sync(dispatch_get_main_queue(), ^{
            [self.demoTableView reloadData];
            if (footerView)
            {
                [footerView removeFromSuperview];
                footerView = [[FooterView alloc] initWithScrollView:self.demoTableView];
                footerView.delegate = self;
            }
            else
            {
                footerView = [[FooterView alloc] initWithScrollView:self.demoTableView];
                footerView.delegate = self;
            }
            _reloading = NO;
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.demoTableView];
        });
    });
}

-(void)getNew
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        sleep(1);
        [self.dataArray removeObject:@"HH"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.demoTableView reloadData];
            if (footerView)
            {
                [footerView removeFromSuperview];
                footerView = [[FooterView alloc] initWithScrollView:self.demoTableView];
                footerView.delegate = self;
            }
            else
            {
                footerView = [[FooterView alloc] initWithScrollView:self.demoTableView];
                footerView.delegate = self;
            }
            _reloading = NO;
            [headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.demoTableView];
        });
    });
    
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getNew];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self getMore];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [headerView egoRefreshScrollViewDidScroll:self.demoTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:self.demoTableView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [headerView egoRefreshScrollViewDidEndDragging:self.demoTableView];
    [footerView egoRefreshScrollViewDidEndDragging:self.demoTableView];
}


#pragma mark - tableview

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger editIndex = indexPath.row;
    [self.dataArray removeObjectAtIndex:editIndex];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *datacell = @"datacell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:datacell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datacell];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger fromIndex = sourceIndexPath.row;
    NSInteger toIndex = destinationIndexPath.row;
    [self.dataArray exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
