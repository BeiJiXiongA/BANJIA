//
//  ImageCell.m
//  School
//
//  Created by TeekerZW on 14-3-14.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell
@synthesize thumImageView,deleteButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        thumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62.5, 62.5)];
        thumImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:thumImageView];
        
//        UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(0, 0, 60, 20);
        [deleteButton setImage:[UIImage imageNamed:@"icon_del"] forState:UIControlStateNormal];
//        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
//        [deleteButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.contentView addSubview:deleteButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
