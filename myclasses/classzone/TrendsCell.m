//
//  TrendsCell.m
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "TrendsCell.h"
#import "Header.h"
#import "UIButton+WebCache.h"
#import "CommentCell.h"

@implementation TrendsCell
@synthesize headerImageView,nameLabel,timeLabel,locationLabel,contentLabel,imagesScrollView,imagesView,transmitButton,praiseButton,commentButton,praiseImageView,commentImageView,bgView,nameTextField,transmitImageView,commentsTableView,commentsArray,praiseArray;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameTextField = [[MyTextField alloc] init];
        nameTextField.hidden = YES;
        [self.contentView addSubview:nameTextField];
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:bgView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(5, 5, 50, 50);
        headerImageView.hidden = YES;
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(60, 5, 100, 30);
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.hidden = YES;
        [bgView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.hidden = YES;
        [bgView addSubview:timeLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, SCREEN_WIDTH-170, 20)];
        locationLabel.textColor = [UIColor lightGrayColor];
        locationLabel.hidden = YES;
        locationLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:locationLabel];
        
        contentLabel = [[UITextView alloc] init];
        contentLabel.frame = CGRectMake(10, 60, SCREEN_WIDTH-20, 35);
        contentLabel.scrollEnabled = NO;
        contentLabel.showsVerticalScrollIndicator = NO;
        contentLabel.editable = NO;
        contentLabel.hidden = YES;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:contentLabel];
        
        imagesScrollView = [[UIScrollView alloc] init];
        imagesScrollView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
//        [bgView addSubview:imagesScrollView];
        
        imagesView = [[UIView alloc] init];
        imagesView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        [bgView addSubview:imagesView];
        
        transmitImageView = [[UIImageView alloc] init];
        transmitImageView.hidden = YES;
        [transmitImageView setImage:[UIImage imageNamed:@"icon_forwarding"]];
        [bgView addSubview:transmitImageView];
        
        transmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [transmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        transmitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        transmitButton.hidden = YES;
        [transmitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        transmitButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        transmitButton.layer.borderWidth = 0.5;
        [bgView addSubview:transmitButton];
        
        praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        praiseButton.frame = CGRectMake(10, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        praiseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        praiseButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        praiseButton.layer.borderWidth = 0.5;
        praiseButton.hidden = YES;
        [bgView addSubview:praiseButton];
        
        praiseImageView = [[UIImageView alloc] init];
        praiseImageView.hidden = YES;
        [praiseImageView setImage:[UIImage imageNamed:@"icon_heart"]];
        [self.contentView addSubview:praiseImageView];
        
        commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.frame = CGRectMake((SCREEN_WIDTH - 20)/2, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        commentButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        commentButton.layer.borderWidth = 0.5;
        commentButton.hidden = YES;
        [bgView addSubview:commentButton];
        
        commentImageView = [[UIImageView alloc] init];
        commentImageView.hidden = YES;
        [commentImageView setImage:[UIImage imageNamed:@"icon_comment"]];
        [bgView addSubview:commentImageView];
        
        commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-6, 0) style:UITableViewStylePlain];
        commentsTableView.delegate = self;
        commentsTableView.dataSource = self;
        commentsTableView.scrollEnabled = NO;
        commentsTableView.backgroundColor = BGVIEWCOLOR;
        if ([commentsTableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [commentsTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        [self.bgView addSubview:commentsTableView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentsArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if ([praiseArray count] > 0)
        {
//            int row = [praiseArray count]%4 == 0 ? ([praiseArray count]/4):([praiseArray count]/4+1);
            return 30;
        }
        else
        {
            return 0;
        }
    }
    NSDictionary *commentDict = [commentsArray objectAtIndex:indexPath.row-1];
    NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
    NSString *content = [commentDict objectForKey:@"content"];
    NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
    CGSize s = [Tools getSizeWithString:contentString andWidth:SCREEN_WIDTH-6 andFont:[UIFont systemFontOfSize:14]];
    return s.height>30?(s.height+0):30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if ([praiseArray count] > 0)
        {
            static NSString *cellName = @"praisecell";
            CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil)
            {
                cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.commentContentLabel.frame = CGRectMake(25, 0, SCREEN_WIDTH-50, 30);
            cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
//            cell.nameButton.frame = CGRectMake(SCREEN_WIDTH-80, 0, 60, 30);
//            cell.nameButton.backgroundColor = LIGHT_BLUE_COLOR;
//            [cell.nameButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
            
//            for (int i=0; i<[praiseArray count]; ++i)
//            {
//                NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
//                UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                headerButton.frame = CGRectMake(45*(i%4), 45*(i/4), 40, 40);
//                [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
//                headerButton.layer.cornerRadius = 20;
//                headerButton.tag = 3333+i;
//                headerButton.clipsToBounds = YES;
//                [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.praiseView addSubview:headerButton];
//            }
//            int row = [praiseArray count]%4 == 0 ? ([praiseArray count]/4):([praiseArray count]/4+1);
//            cell.praiseView.frame = CGRectMake(25, 30, 180, 50*row);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        return nil;
    }
    else
    {
        static NSString *cellName = @"commentcell";
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil)
        {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        NSDictionary *commitDict = [commentsArray objectAtIndex:indexPath.row-1];
        NSString *name = [[commitDict objectForKey:@"by"] objectForKey:@"name"];
        NSString *content = [commitDict objectForKey:@"content"];
        cell.commentDict = commitDict;
        [cell setNeedsDisplay];
        cell.nameButton.tag = 3333+(indexPath.row-1);
        cell.nameButton.frame = CGRectMake(25, 0, [name length]*18, 30);
        CGSize s = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-6 andFont:[UIFont systemFontOfSize:14]];
        cell.commentContentLabel.frame = CGRectMake(cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, 0, 200, s.height>30?s.height:30);
        [cell.nameButton setTitle:[NSString stringWithFormat:@"%@:",name] forState:UIControlStateNormal];
        cell.commentContentLabel.text = content;
        [cell.nameButton addTarget:self action:@selector(nameClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0)
    {
        DDLOG(@"comment %@",[commentsArray objectAtIndex:indexPath.row-1]);
    }
}

-(void)nameClick:(UIButton *)button
{
    DDLOG(@"comment %@",[commentsArray objectAtIndex:button.tag-3333]);
}
-(void)praiseClick:(UIButton *)button
{
    DDLOG(@"praise header %@",[praiseArray objectAtIndex:button.tag - 3333]);
}
@end
