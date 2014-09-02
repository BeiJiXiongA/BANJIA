//
//  HeaderCell.m
//  优佳齿科
//
//  Created by mac120 on 13-11-22.
//  Copyright (c) 2013年 mac120. All rights reserved.
//
#import "ADHeaderCell.h"

@implementation ADHeaderCell
@synthesize headerScrollView,headerPageControl,closeAd;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        headerScrollView = [[UIScrollView alloc] init];
        headerScrollView.delegate = self;
        headerScrollView.hidden = YES;
        [self.contentView addSubview:headerScrollView];
        
        headerPageControl = [[UIPageControl alloc] init];
        [self.contentView addSubview:headerPageControl];
        
        closeAd = [UIButton buttonWithType:UIButtonTypeCustom];
        closeAd.hidden = YES;
        [self.contentView addSubview:closeAd];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    headerPageControl.currentPage = scrollView.contentOffset.x/SCREEN_WIDTH;
    
    if ([self.headerDel respondsToSelector:@selector(getHeaderIndex:andIndex:)])
    {
        [self.headerDel getHeaderIndex:self andIndex:headerPageControl.currentPage];
    }
}

@end
