//
//  XDTabBar.m
//  XDCommonApp
//
//  Created by 容芳志 on 13-6-5.
//  Copyright (c) 2013年 xin wang. All rights reserved.
//

#import "XDTabBar.h"
#import "Header.h"

#define TAB_ARROW_IMAGE_TAG 2394859
#define SELECTED_ITEM_TAG   2394860

@interface XDTabBar (PrivateMethods)

- (CGFloat)horizontalLocationFor:(NSUInteger)tabIndex;
- (void)addTabBarArrowAtIndex:(NSUInteger)itemIndex;
- (UIButton *)buttonAtIndex:(NSUInteger)itemIndex width:(CGFloat)width;

@end

@implementation XDTabBar
@synthesize buttons;
@synthesize button0,button1,button2,button3;
@synthesize label0,label1,label2,label3;
- (id)initWithItemCount:(NSUInteger)itemCount
               itemSize:(CGSize)itemSize
                    tag:(NSInteger)objectTag
               delegate:(NSObject <XDTabBarDelegate>*)YCTabBarDelegate {
    
    if (self = [super init]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleWidth;
        
        // The tag allows callers withe multiple controls to distinguish between them
        self.tag = objectTag;
        
        // Set the delegate
        delegate = YCTabBarDelegate;
        
        // Add the background image
        UIImage* backgroundImage = [delegate backgroundImage];
        UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        backgroundImageView.frame = CGRectMake(0, UI_MAINSCREEN_HEIGHT - UI_TAB_BAR_HEIGHT, self.frame.size.width, backgroundImage.size.height);
        backgroundImageView.frame = CGRectMake(0, UI_MAINSCREEN_HEIGHT - UI_TAB_BAR_HEIGHT-5, self.frame.size.width, UI_TAB_BAR_HEIGHT+10);
        backgroundImageView.backgroundColor = [UIColor purpleColor];
        [self addSubview:backgroundImageView];
        
        // Adjust our width based on the number of items & the width of each item
        self.frame = CGRectMake(0, 0, itemSize.width * itemCount, itemSize.height);
        
        // Initalize the array we use to store our buttons
        self.buttons = [[NSMutableArray alloc] initWithCapacity:itemCount];
        
        // horizontalOffset tracks the proper x value as we add buttons as subviews
        CGFloat horizontalOffset = 0;
        
        for (NSUInteger i = 0 ; i < itemCount ; i++) {
            UIButton* button = [self buttonAtIndex:i
                                             width:self.frame.size.width / itemCount];
            
            // Register for touch events
            [button addTarget:self
                       action:@selector(touchDownAction:)
             forControlEvents:UIControlEventTouchDown];
            [button addTarget:self
                       action:@selector(touchUpInsideAction:)
             forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self
                       action:@selector(otherTouchesAction:)
             forControlEvents:UIControlEventTouchUpOutside];
            [button addTarget:self
                       action:@selector(otherTouchesAction:)
             forControlEvents:UIControlEventTouchDragOutside];
            [button addTarget:self
                       action:@selector(otherTouchesAction:)
             forControlEvents:UIControlEventTouchDragInside];
            
            [buttons addObject:button];
            
            CGFloat padding = (itemSize.width - button.frame.size.width) / 2;
            button.frame = CGRectMake(horizontalOffset + padding,
                                      UI_MAINSCREEN_HEIGHT - UI_TAB_BAR_HEIGHT,
                                      button.frame.size.width,
                                      UI_TAB_BAR_HEIGHT);
            
            // Add the button as our subview
            [self addSubview:button];
            
            // Advance the horizontal offset
            horizontalOffset = horizontalOffset + itemSize.width;
            
//            if (i == itemCount-1)
//            {
//                button.frame = CGRectMake(horizontalOffset + padding-itemSize.width-29,
//                                          UI_MAINSCREEN_HEIGHT - UI_TAB_BAR_HEIGHT,
//                                          button.frame.size.width,
//                                          UI_TAB_BAR_HEIGHT);
//            }
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)dimAllButtonsExcept:(UIButton*)selectedButton {
    for (UIButton* button in buttons) {
        if (button == selectedButton) {
            button.selected = YES;
            button.highlighted = button.selected ? NO : YES;
            button.tag = SELECTED_ITEM_TAG;
            
            UIImageView* tabBarArrow = (UIImageView*)[self viewWithTag:TAB_ARROW_IMAGE_TAG];
            NSUInteger selectedIndex = [buttons indexOfObjectIdenticalTo:button];
            if (tabBarArrow) {
                [UIView animateWithDuration:0.2 animations:^{
                    CGRect frame = tabBarArrow.frame;
                    frame.origin.x = [self horizontalLocationFor:selectedIndex];
                    tabBarArrow.frame = frame;
                }];
            } else {
                [self addTabBarArrowAtIndex:selectedIndex];
            }
        } else {
            button.selected = NO;
            button.highlighted = NO;
            button.tag = 0;
        }
    }
}

- (void)touchDownAction:(UIButton*)button
{
//    [self dimAllButtonsExcept:button];
    if ([delegate respondsToSelector:@selector(touchDownAtItemAtIndex:)])
        [delegate touchDownAtItemAtIndex:[buttons indexOfObject:button]];
}

- (void)touchUpInsideAction:(UIButton*)button {
//    [self dimAllButtonsExcept:button];
    if ([delegate respondsToSelector:@selector(touchUpInsideItemAtIndex:)])
        [delegate touchUpInsideItemAtIndex:[buttons indexOfObject:button]];
}

- (void)otherTouchesAction:(UIButton*)button {
    [self dimAllButtonsExcept:button];
}

- (void)selectItemAtIndex:(NSInteger)index {
    UIButton* button = [buttons objectAtIndex:index];
    [self dimAllButtonsExcept:button];
}

- (CGFloat)horizontalLocationFor:(NSUInteger)tabIndex {
    UIImage* tabBarArrowImage = [delegate tabBarArrowImage];
    UIButton* button = [buttons objectAtIndex:tabIndex];
    CGFloat tabItemWidth = button.frame.size.width;
    CGFloat halfTabItemWidth = (tabItemWidth - tabBarArrowImage.size.width) / 2.0;
    return button.frame.origin.x + halfTabItemWidth;
}

- (void)addTabBarArrowAtIndex:(NSUInteger)itemIndex {
    UIImage* tabBarArrowImage = [delegate tabBarArrowImage];
    UIImageView* tabBarArrow = [[UIImageView alloc] initWithImage:tabBarArrowImage];
    tabBarArrow.tag = TAB_ARROW_IMAGE_TAG;
    
    CGFloat verticalLocation = self.frame.size.height - tabBarArrowImage.size.height;
    tabBarArrow.frame = CGRectMake(
                                   [self horizontalLocationFor:itemIndex],
                                   verticalLocation,
                                   tabBarArrowImage.size.width,
                                   tabBarArrowImage.size.height
                                   );
    
    [self addSubview:tabBarArrow];
}

- (UIButton *)buttonAtIndex:(NSUInteger)itemIndex width:(CGFloat)width {
    if (itemIndex == 0)
    {
        UIImage* rawButtonImage = [delegate imageFor:self atIndex:itemIndex];
        button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button0.frame = CGRectMake(0.0, 10, rawButtonImage.size.width, rawButtonImage.size.height);
        UIImage* buttonPressedImage = [delegate hightlightedImageFor:self
                                                             atIndex:itemIndex];
        
        // Set the gray & blue images as the button states
        [button0 setImage:rawButtonImage forState:UIControlStateNormal];
        [button0 setImage:buttonPressedImage forState:UIControlStateHighlighted];
        [button0 setImage:buttonPressedImage forState:UIControlStateSelected];
        [button0 setBackgroundImage:[delegate selectedItemImage]
                          forState:UIControlStateHighlighted];
        [button0 setBackgroundImage:[delegate selectedItemImage]
                          forState:UIControlStateSelected];
        
        button0.adjustsImageWhenHighlighted = NO;
        
        label0 = [[UILabel alloc] init];
        label0.frame = CGRectMake(button0.frame.origin.x+button0.frame.size.width-30, button0.frame.origin.y-9, 10, 10);
        label0.hidden = YES;
        label0.layer.cornerRadius = 5;
        label0.clipsToBounds = YES;
        label0.layer.borderColor = [UIColor whiteColor].CGColor;
        label0.layer.borderWidth = 1;
        label0.textAlignment = NSTextAlignmentCenter;
        label0.backgroundColor = [UIColor redColor];
        label0.font = [UIFont systemFontOfSize:10];
        label0.textColor = [UIColor whiteColor];
        [button0 addSubview:label0];
        return button0;
    }
    else if (itemIndex == 1)
    {
        UIImage* rawButtonImage = [delegate imageFor:self atIndex:itemIndex];
        button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button1.frame = CGRectMake(0.0, 10, rawButtonImage.size.width, rawButtonImage.size.height);
        UIImage* buttonPressedImage = [delegate hightlightedImageFor:self
                                                             atIndex:itemIndex];
        
        // Set the gray & blue images as the button states
        [button1 setImage:rawButtonImage forState:UIControlStateNormal];
        [button1 setImage:buttonPressedImage forState:UIControlStateHighlighted];
        [button1 setImage:buttonPressedImage forState:UIControlStateSelected];
        [button1 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateHighlighted];
        [button1 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateSelected];
        
        button1.adjustsImageWhenHighlighted = NO;
        
        label1 = [[UILabel alloc] init];
        
        
        label1.hidden = YES;
        label1.layer.cornerRadius = 7;
        label1.frame = CGRectMake(button1.frame.origin.x+button1.frame.size.width-27, button1.frame.origin.y-9, 14, 14);
        
        label1.clipsToBounds = YES;
        label1.layer.borderColor = [UIColor whiteColor].CGColor;
        label1.layer.borderWidth = 1;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor redColor];
        label1.font = [UIFont systemFontOfSize:10];
        label1.textColor = [UIColor whiteColor];
        [button1 addSubview:label1];
        return button1;
    }
    else if (itemIndex == 2)
    {
        UIImage* rawButtonImage = [delegate imageFor:self atIndex:itemIndex];
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button2.frame = CGRectMake(0.0, 10, rawButtonImage.size.width, rawButtonImage.size.height);
        UIImage* buttonPressedImage = [delegate hightlightedImageFor:self
                                                             atIndex:itemIndex];
        
        // Set the gray & blue images as the button states
        [button2 setImage:rawButtonImage forState:UIControlStateNormal];
        [button2 setImage:buttonPressedImage forState:UIControlStateHighlighted];
        [button2 setImage:buttonPressedImage forState:UIControlStateSelected];
        [button2 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateHighlighted];
        [button2 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateSelected];
        
        button2.adjustsImageWhenHighlighted = NO;
        
        label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(button1.frame.origin.x+button1.frame.size.width-27, button1.frame.origin.y-9, 14, 14);
//        label2.hidden = YES;
        label2.layer.cornerRadius = 7;
    
        label2.clipsToBounds = YES;
        label2.layer.borderColor = [UIColor whiteColor].CGColor;
        label2.layer.borderWidth = 1;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor redColor];
        label2.font = [UIFont systemFontOfSize:10];
        label2.textColor = [UIColor whiteColor];
        [button2 addSubview:label2];
        return button2;
    }
    else if (itemIndex == 3)
    {
        UIImage* rawButtonImage = [delegate imageFor:self atIndex:itemIndex];
        button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button3.frame = CGRectMake(0.0, 10, rawButtonImage.size.width, rawButtonImage.size.height);
        UIImage* buttonPressedImage = [delegate hightlightedImageFor:self
                                                             atIndex:itemIndex];
        
        // Set the gray & blue images as the button states
        [button3 setImage:rawButtonImage forState:UIControlStateNormal];
        [button3 setImage:buttonPressedImage forState:UIControlStateHighlighted];
        [button3 setImage:buttonPressedImage forState:UIControlStateSelected];
        [button3 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateHighlighted];
        [button3 setBackgroundImage:[delegate selectedItemImage]
                           forState:UIControlStateSelected];
        
        button3.adjustsImageWhenHighlighted = NO;
        
        label3 = [[UILabel alloc] init];
        label3.frame = CGRectMake(button1.frame.origin.x+button1.frame.size.width-27, button1.frame.origin.y-9, 14, 14);
        label3.hidden = YES;
        label3.layer.cornerRadius = 7;
        label3.clipsToBounds = YES;
        label3.layer.borderColor = [UIColor whiteColor].CGColor;
        label3.layer.borderWidth = 1;
        label3.textAlignment = NSTextAlignmentCenter;
        label3.backgroundColor = [UIColor redColor];
        label3.font = [UIFont systemFontOfSize:10];
        label3.textColor = [UIColor whiteColor];
        [button3 addSubview:label3];
        return button3;
    }
    return nil;
}


@end
