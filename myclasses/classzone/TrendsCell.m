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
#import "NSString+Emojize.h"

#import "PersonDetailViewController.h"


@implementation TrendsCell
@synthesize headerImageView,nameLabel,timeLabel,locationLabel,contentLabel,imagesScrollView,imagesView,transmitButton,praiseButton,commentButton,bgView,nameTextField,commentsTableView,commentsArray,praiseArray,showAllComments,nameButtonDel,diaryDetailDict,geduan1,geduan2,openPraise,topImageView,verticalLineView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
//        praiseArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        openPraise = YES;
        
        nameTextField = [[MyTextField alloc] init];
        nameTextField.hidden = YES;
        [self.contentView addSubview:nameTextField];
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:bgView];
        
        topImageView = [[UIImageView alloc] init];
        topImageView.hidden = YES;
        [self.bgView addSubview:topImageView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(12, 12, 43, 43);
        headerImageView.hidden = YES;
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(60, 5, 100, 30);
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.hidden = YES;
        [bgView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = TIMECOLOR;
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.hidden = YES;
        [bgView addSubview:timeLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, SCREEN_WIDTH-170, 20)];
        locationLabel.textColor = TIMECOLOR;
        locationLabel.hidden = YES;
        locationLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:locationLabel];
        
        contentLabel = [[UITextView alloc] init];
        contentLabel.frame = CGRectMake(10, 60, SCREEN_WIDTH-20, 35);
        contentLabel.scrollEnabled = NO;
        contentLabel.showsVerticalScrollIndicator = NO;
        contentLabel.editable = NO;
        contentLabel.hidden = YES;
        contentLabel.textColor = CONTENTCOLOR;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:contentLabel];
        
        imagesScrollView = [[UIScrollView alloc] init];
        imagesScrollView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
//        [bgView addSubview:imagesScrollView];
        
        imagesView = [[UIView alloc] init];
        imagesView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        [bgView addSubview:imagesView];
        
        transmitButton = [MyButton buttonWithType:UIButtonTypeCustom];
        [transmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        transmitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        transmitButton.hidden = YES;
        [transmitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        transmitButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        transmitButton.layer.borderWidth = 0;
        [bgView addSubview:transmitButton];
        transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        transmitButton.iconImageView.frame = CGRectMake(11, 9, 17, 17);
        
        
        praiseButton = [MyButton buttonWithType:UIButtonTypeCustom];
        praiseButton.frame = CGRectMake(10, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        praiseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        praiseButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        praiseButton.layer.borderWidth = 0;
        praiseButton.hidden = YES;
        [bgView addSubview:praiseButton];
        
        praiseButton.iconImageView.frame = CGRectMake(11, 10, 15, 15);
        
        commentButton = [MyButton buttonWithType:UIButtonTypeCustom];
        commentButton.frame = CGRectMake((SCREEN_WIDTH - 20)/2, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        commentButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        commentButton.layer.borderWidth = 0;
        commentButton.hidden = YES;
        [bgView addSubview:commentButton];
        commentButton.iconImageView.image= [UIImage imageNamed:@"icon_comment"];
        
        geduan1 = [[UIView alloc] init];
        geduan1.frame = CGRectMake(transmitButton.frame.size.width+
                                   transmitButton.frame.origin.x,
                                   transmitButton.frame.origin.y+ 5, 1, 25);
        geduan1.backgroundColor = UIColorFromRGB(0xe4e4e2);
        geduan1.hidden = YES;
        [self.bgView addSubview:geduan1];
        
        geduan2 = [[UIView alloc] init];
        geduan2.frame = CGRectMake(praiseButton.frame.size.width+
                                   praiseButton.frame.origin.x,
                                   praiseButton.frame.origin.y+ 5, 1, 25);
        geduan2.backgroundColor = UIColorFromRGB(0xe4e4e2);
        geduan2.hidden = YES;
        [self.bgView addSubview:geduan2];
        
        commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-10, 0) style:UITableViewStylePlain];
        commentsTableView.delegate = self;
        commentsTableView.dataSource = self;
        commentsTableView.scrollEnabled = NO;
        commentsTableView.layer.borderColor =UIColorFromRGB(0xe4e4e2).CGColor;
        commentsTableView.layer.borderWidth = 0.5;
        commentsTableView.separatorColor = UIColorFromRGB(0xe4e4e2);
        commentsTableView.backgroundColor = UIColorFromRGB(0xfcfcfc);
        if ([commentsTableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [commentsTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        [self.bgView addSubview:commentsTableView];
        
        verticalLineView = [[UIView alloc] init];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [self.contentView insertSubview:verticalLineView belowSubview:self.bgView];
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
    if (commentsArray && praiseArray)
    {
        if(showAllComments)
        {
            return [commentsArray count]+1;
        }
        else
        {
            return ([commentsArray count]>6?7:[commentsArray count]) +1;
        }
        
    }
    else if(commentsArray && !praiseArray)
    {
        if (showAllComments)
        {
            return [commentsArray count];
        }
        else
        {
            return [commentsArray count] > 6 ? 7 : [commentsArray count];
        }
    }
    else if(!commentsArray && praiseArray)
    {
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"index path row %d height for row",indexPath.row);
    
    CGFloat chaHeight = 15;
    if (commentsArray && praiseArray)
    {
        if (!showAllComments)
        {
            if (indexPath.row == 0)
            {
                return PraiseCellHeight;
            }
            else if(indexPath.row < 7)
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [commentDict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                return s.height > 25 ? (s.height+chaHeight) : 35 ;
            }
            else if(indexPath.row == 7)
            {
                return 35;
            }
        }
        else
        {
            if (indexPath.row == 0)
            {
                if (openPraise)
                {
                    int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                    return (PraiseH+5)*row+PraiseCellHeight;
                }
                return PraiseCellHeight;
            }
            else
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [commentDict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                return s.height > 25 ? (s.height+chaHeight) : 35 ;
            }
        }
    }
    else if(commentsArray && !praiseArray)
    {
        if (!showAllComments)
        {
            if (indexPath.row < 6)
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
                NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [commentDict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                return s.height > 25 ? (s.height+chaHeight) : 35;
            }
            else if(indexPath.row == 6)
            {
                return 35;
            }
        }
        else
        {
            NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
            NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
            NSString *content = [commentDict objectForKey:@"content"];
            NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
            CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
            return s.height > 25 ? (s.height+chaHeight) : 35;
        }
    }
    else if(praiseArray && !commentsArray)
    {
        if (indexPath.row == 0)
        {
            if (showAllComments)
            {
                if (openPraise)
                {
                    int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                    return (PraiseH+5)*row+PraiseCellHeight;
                }

            }
            return PraiseCellHeight;
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"index path row %d",indexPath.row);
    
    static NSString *cellName = @"homepraisecell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil)
    {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
//    cell.nameButton.hidden = YES;
    CGFloat c_width = 15;
    cell.openPraiseButton.hidden = YES;
    [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
    [cell.nameButton setImage:nil forState:UIControlStateNormal];
    if (showAllComments)
    {
        if (praiseArray && commentsArray)
        {
            if (indexPath.row == 0)
            {
                cell.nameButton.enabled = NO;
                
                cell.praiseView.hidden = NO;
                cell.nameButton.hidden = NO;
                [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
                
                
                cell.nameButton.frame = CGRectMake(12, 9, 18, 18);
                cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
                [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
                
                cell.commentContentLabel.frame = CGRectMake(35, 2.5, SCREEN_WIDTH-50, 30);
                cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.openPraiseButton.frame = CGRectMake(SCREEN_WIDTH-70, 3, 130, 130);
                cell.openPraiseButton.backgroundColor = [UIColor blackColor];
//                [cell.openPraiseButton addTarget:self action:@selector(openThisPraise) forControlEvents:UIControlEventTouchUpInside];
                cell.openPraiseButton = NO;
                
                for (UIView *v in cell.praiseView.subviews)
                {
                    [v removeFromSuperview];
                }
                
                for (int i=0; i<[praiseArray count]; ++i)
                {
                    NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
                    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    headerButton.frame = CGRectMake((PraiseW+5)*(i%ColumnPerRow), (PraiseH+5)*(i/ColumnPerRow), PraiseW, PraiseH);
                    [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
                    headerButton.layer.cornerRadius = 2;
                    headerButton.tag = 3333+i;
                    headerButton.clipsToBounds = YES;
                    [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.praiseView addSubview:headerButton];
                }
                int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                cell.praiseView.frame = CGRectMake(12, 30, SCREEN_WIDTH-24, (PraiseH+9)*row);
                
                return cell;
            }
            else
            {
                cell.nameButton.hidden = NO;
                cell.praiseView.hidden = YES;
                [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
                
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [NSString stringWithFormat:@"%@:",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                NSString *content = [commitDict objectForKey:@"content"];
                CGSize s = [Tools getSizeWithString:[content emojizedString] andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                CGFloat originalY = 2.5;
                if (s.height > 30)
                {
                    originalY = 6.5;
                    cell.nameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                }
                cell.nameButton.tag = 3333+(indexPath.row-1);
                cell.nameButton.frame = CGRectMake(12, originalY+1, [name length]*c_width, 30);
                if (s.height > 30)
                {
                    cell.nameButton.frame = CGRectMake(12, originalY, [name length]*c_width, 30);
                }
                cell.commentContentLabel.frame = CGRectMake(cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, originalY, SCREEN_WIDTH-40-cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, s.height>30?s.height:30);
                [cell.nameButton setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
                cell.commentContentLabel.text = [content emojizedString];
//                [cell.nameButton addTarget:self action:@selector(nameClick:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
        }
        else if(commentsArray && !praiseArray)
        {
            cell.nameButton.hidden = NO;
            cell.praiseView.hidden = YES;
            [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
            
            
            NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
            NSString *name = [NSString stringWithFormat:@"%@:",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
            NSString *content = [commitDict objectForKey:@"content"];
            CGSize s = [Tools getSizeWithString:[content emojizedString] andWidth:200 andFont:[UIFont systemFontOfSize:14]];
            CGFloat originalY = 2.5;
            if (s.height > 30)
            {
                originalY = 6.5;
                cell.nameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            }
            
            [cell.nameButton setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.nameButton setBackgroundColor:[UIColor clearColor]];
            
            cell.nameButton.tag = 3333+(indexPath.row);
            cell.nameButton.frame = CGRectMake(12, originalY+1, [name length]*c_width, 30);
            if (s.height > 30)
            {
                cell.nameButton.frame = CGRectMake(12, originalY, [name length]*c_width, 30);
            }
            cell.commentContentLabel.frame = CGRectMake(cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, originalY, SCREEN_WIDTH-40-cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, s.height>30?s.height:30);
            [cell.nameButton setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
            cell.commentContentLabel.text = [content emojizedString];
            [cell.nameButton addTarget:self action:@selector(nameClick:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else if(!commentsArray && praiseArray)
        {
            cell.nameButton.hidden = NO;
            cell.nameButton.enabled = NO;
            cell.praiseView.hidden = NO;
            [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
            
            cell.nameButton.frame = CGRectMake(12, 9, 18, 18);
            cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
            [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
            
            cell.commentContentLabel.frame = CGRectMake(35, 3, SCREEN_WIDTH-50, 30);
            cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.openPraiseButton.frame = CGRectMake(SCREEN_WIDTH-70, 3, 30, 30);
            cell.openPraiseButton.backgroundColor = [UIColor greenColor];
            [cell.openPraiseButton addTarget:self action:@selector(openThisPraise) forControlEvents:UIControlEventTouchUpInside];
            cell.openPraiseButton = NO;
            
            for (UIView *v in cell.praiseView.subviews)
            {
                [v removeFromSuperview];
            }
            
            for (int i=0; i<[praiseArray count]; ++i)
            {
                NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
                if ([praiseDict isEqual:[NSNull null]])
                {
                    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    headerButton.frame = CGRectMake((PraiseW+5)*(i%ColumnPerRow), (PraiseH+5)*(i/ColumnPerRow), PraiseW, PraiseH);
                    [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
                    headerButton.layer.cornerRadius = 2;
                    headerButton.tag = 3333+i;
                    headerButton.clipsToBounds = YES;
                    [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.praiseView addSubview:headerButton];
                }
            }
            
            int row = [praiseArray count] % ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
            cell.praiseView.frame = CGRectMake(12, 30, SCREEN_WIDTH-24, 40*row);

            return cell;
        }
    }
    else
    {
        
        if (praiseArray && commentsArray)
        {
            if (indexPath.row == 0)
            {
                cell.nameButton.hidden = NO;
                cell.nameButton.enabled = NO;
                [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
                cell.praiseView.hidden = YES;
                
                cell.nameButton.frame = CGRectMake(12, 9, 18, 18);
                cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
                [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
                
                cell.commentContentLabel.frame = CGRectMake(35, 2.5, SCREEN_WIDTH-50, 30);
                cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else if(indexPath.row < 7)
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
                
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [NSString stringWithFormat:@"%@:",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                NSString *content = [commitDict objectForKey:@"content"];
                CGSize s = [Tools getSizeWithString:[content emojizedString] andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                CGFloat originalY = 2.5;
                if (s.height > 30)
                {
                    originalY = 6.5;
                    cell.nameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                }
                cell.nameButton.tag = 3333+(indexPath.row-1);
                cell.nameButton.frame = CGRectMake(12, originalY+1, [name length]*c_width, 30);
                if (s.height > 30)
                {
                    cell.nameButton.frame = CGRectMake(12, originalY, [name length]*c_width, 30);
                }
                cell.commentContentLabel.frame = CGRectMake(cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, originalY, SCREEN_WIDTH-40-cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, s.height>30?s.height:30);
                [cell.nameButton setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
                cell.commentContentLabel.text = [content emojizedString];
                [cell.nameButton addTarget:self action:@selector(nameClick:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
            else
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setImage:[UIImage imageNamed:@"home_more"] forState:UIControlStateNormal];
                cell.nameButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, 35);
                [cell.nameButton setTitle:@"查看更多" forState:UIControlStateNormal];
                [cell.nameButton addTarget:self action:@selector(showDiaryDetail) forControlEvents:UIControlEventTouchUpInside];
                [cell.nameButton setTitleColor:TIMECOLOR forState:UIControlStateNormal];
                return cell;
            }
        }
        else if(commentsArray && !praiseArray)
        {
            if (indexPath.row < 6)
            {
                cell.nameButton.hidden = NO;
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
                NSString *name = [NSString stringWithFormat:@"%@:",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                NSString *content = [commitDict objectForKey:@"content"];
                CGSize s = [Tools getSizeWithString:[content emojizedString] andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                CGFloat originalY = 2.5;
                if (s.height > 30)
                {
                    originalY = 6.5;
                    cell.nameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                }
                cell.nameButton.tag = 3333+(indexPath.row);
                cell.nameButton.frame = CGRectMake(25, originalY+1, [name length]*c_width, 30);
                
                [cell.nameButton setBackgroundImage:nil forState:UIControlStateNormal];
                [cell.nameButton setBackgroundColor:[UIColor clearColor]];
                
                if (s.height > 30)
                {
                    cell.nameButton.frame = CGRectMake(25, originalY, [name length]*c_width, 30);
                }
                [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
                cell.commentContentLabel.frame = CGRectMake(cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, originalY, SCREEN_WIDTH-40-cell.nameButton.frame.size.width+cell.nameButton.frame.origin.x, s.height>30?s.height:30);
                [cell.nameButton setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
                cell.commentContentLabel.text = [content emojizedString];
                [cell.nameButton addTarget:self action:@selector(nameClick:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
            else
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setImage:[UIImage imageNamed:@"home_more"] forState:UIControlStateNormal];
                cell.nameButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, 35);
                [cell.nameButton setTitle:@"查看更多" forState:UIControlStateNormal];
                [cell.nameButton setTitleColor:TIMECOLOR forState:UIControlStateNormal];
                [cell.nameButton addTarget:self action:@selector(showDiaryDetail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
        }
        else if(!commentsArray && praiseArray)
        {
            cell.nameButton.hidden = NO;
            cell.nameButton.enabled = NO;
            cell.nameButton.frame = CGRectMake(12, 9, 18, 18);
            cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
            [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
            [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
            
            cell.commentContentLabel.frame = CGRectMake(35, 3, SCREEN_WIDTH-50, 30);
            cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *dict;
//    if ([praiseArray count] > 0)
//    {
//        dict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
//    }
//    else
//    {
//        dict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
//    }
    if (praiseArray && commentsArray)
    {
        if (indexPath.row == 0)
        {
            [self showDiaryDetail];
        }
        else
        {
            if ([self.nameButtonDel respondsToSelector:@selector(cellCommentDiary:)])
            {
                [self.nameButtonDel cellCommentDiary:diaryDetailDict];
            }
        }
    }
    else if (praiseArray && ! commentsArray)
    {
        [self showDiaryDetail];
    }
    else if(!praiseArray && commentsArray)
    {
        if ([self.nameButtonDel respondsToSelector:@selector(cellCommentDiary:)])
        {
            [self.nameButtonDel cellCommentDiary:diaryDetailDict];
        }
    }
}

-(void)nameClick:(UIButton *)button
{
    DDLOG(@"comment %@",[commentsArray objectAtIndex:button.tag-3333]);
    NSDictionary *dict = [commentsArray objectAtIndex:button.tag-3333];
    if ([self.nameButtonDel respondsToSelector:@selector(showPersonDetail:)])
    {
        [self.nameButtonDel showPersonDetail:dict];
    }
}
-(void)praiseClick:(UIButton *)button
{
    DDLOG(@"praise header %@",[praiseArray objectAtIndex:button.tag - 3333]);
    NSDictionary *dict = [praiseArray objectAtIndex:button.tag-3333];
    if ([self.nameButtonDel respondsToSelector:@selector(showPersonDetail:)])
    {
        [self.nameButtonDel showPersonDetail:dict];
    }
}
-(void)showDiaryDetail
{
    if ([self.nameButtonDel respondsToSelector:@selector(nameButtonClick:)])
    {
        [self.nameButtonDel nameButtonClick:diaryDetailDict];
    }
}

-(void)openThisPraise
{
    openPraise = !openPraise;
    [commentsTableView reloadData];
}
@end

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
