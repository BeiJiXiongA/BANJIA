//
//  LocationViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14/9/19.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "LocationViewController.h"

@implementation LocationViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"地点";
    
    locationListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    locationListTableView.delegate = self;
    locationListTableView.dataSource = self;
    [self.bgView addSubview:locationListTableView];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locationArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *locationIder = @"locationider";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locationIder];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationIder];
    }
    cell.textLabel.text = @"来镇家园";
    cell.detailTextLabel.text = @"kljkjkaslfsfaldjkasdljf";
    return cell;
}
@end
