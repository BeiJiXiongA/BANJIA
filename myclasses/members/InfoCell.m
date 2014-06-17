//
//  InfoCell.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell
@synthesize nameLabel,contentLabel,button1,button2,headerImageView,bgImageView,nameBgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameBgView = [[UIView alloc] init];
        [self.contentView addSubview:nameBgView];
        
        bgImageView = [[UIImageView alloc] init];
        bgImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:bgImageView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:headerImageView];
                
        nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:contentLabel];
        
        button1 = [MyButton buttonWithType:UIButtonTypeCustom];
        button1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button1];
        
        button2 = [MyButton buttonWithType:UIButtonTypeCustom];
        button2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button2];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
