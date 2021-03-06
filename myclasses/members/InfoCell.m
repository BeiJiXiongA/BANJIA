//
//  InfoCell.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell
@synthesize nameLabel,contentLabel,button1,button2,headerImageView,bgImageView,nameBgView,sexureImageView,lineImageView;
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
        headerImageView.clipsToBounds = YES;
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        [self.contentView addSubview:headerImageView];
                
        nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:contentLabel];
        
        sexureImageView = [[UIImageView alloc] init];
        sexureImageView.hidden = YES;
        sexureImageView.layer.cornerRadius = 3;
        sexureImageView.clipsToBounds = YES;
        [self.contentView addSubview:sexureImageView];
        
        button1 = [MyButton buttonWithType:UIButtonTypeCustom];
        button1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button1];
        
        button2 = [MyButton buttonWithType:UIButtonTypeCustom];
        button2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button2];
        
        lineImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:lineImageView];
        
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
