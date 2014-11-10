//
//  JDSideMenu.h
//  StatusBarTest
//
//  Created by Markus Emrich on 11/11/13.
//  Copyright (c) 2013 Markus Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDContentViewController.h"
#import "MyPanGestureRecognizer.h"


@protocol SideMenuDelegate;

@interface JDSideMenu : UIViewController

@property (nonatomic, readonly) UIViewController *contentController;
@property (nonatomic, readonly) UIViewController *menuController;

@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) BOOL tapGestureEnabled;
@property (nonatomic, assign) BOOL panGestureEnabled;
@property (nonatomic, assign) id<SideMenuDelegate> sideMenuDelegate;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) MyPanGestureRecognizer *panRecognizer;

- (id)initWithContentController:(UIViewController*)contentController
                 menuController:(UIViewController*)menuController;

- (void)setContentController:(UIViewController*)contentController
                     animted:(BOOL)animated;

- (void)panRecognized:(UIPanGestureRecognizer*)recognizer;

// show / hide manually
- (void)showMenuAnimated:(BOOL)animated;
- (void)hideMenuAnimated:(BOOL)animated;

- (BOOL)isMenuVisible;

// background
- (void)setBackgroundImage:(UIImage*)image;

@end
@protocol SideMenuDelegate <NSObject>

-(void)openSideMueu:(JDSideMenu *)sideMenu;
-(void)closeSideMenu:(JDSideMenu *)sideMenu;
@end