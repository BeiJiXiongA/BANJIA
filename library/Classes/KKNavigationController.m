//
//  KKNavigationController.m
//  TS
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved.  MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//


#import "KKNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import "KKNavigationController+JDSideMenu.h"

@interface KKNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    UIPanGestureRecognizer *recognizer;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation KKNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.canDragBack = YES;
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, SCREEN_HEIGHT);

//    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
//    UIImage *navImage = [UIImage imageNamed:@"navi_bg.png"];
//    [self.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
//    
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationBar.backgroundColor = [UIColor redColor];
    self.navigationBar.hidden = YES;
    
    UIImageView *shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                        action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
//    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.screenShotsList addObject:[self capture]];
    
    [self.view addGestureRecognizer:recognizer];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    UIBezierPath *p = [UIBezierPath bezierPathWithRect:CGRectMake(0, YSTART, SCREEN_WIDTH, SCREEN_HEIGHT-YSTART)];
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextAddPath(con, p.CGPath);
    [self.view.layer renderInContext:con];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)moveViewWithX:(float)x
{
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/800);

    blackMask.alpha = alpha;

    CGFloat aa = abs(startBackViewX)/kkBackViewWidth;
    CGFloat y = x*aa;

    CGFloat lastScreenShotViewHeight = kkBackViewHeight;
    
    //TODO: FIX self.edgesForExtendedLayout = UIRectEdgeNone  SHOW BUG

// *  if u use self.edgesForExtendedLayout = UIRectEdgeNone; pls add

//    if (SYSVERSION >= 7.0) {
//        lastScreenShotViewHeight = lastScreenShotViewHeight - 20;
//    }
    
    [lastScreenShotView setFrame:CGRectMake(startBackViewX+y,
                                            0,
                                            kkBackViewWidth,
                                            lastScreenShotViewHeight)];

}



-(BOOL)isBlurryImg:(CGFloat)tmp
{
    return YES;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack)
    {
//        [self.sideMenuController panRecognized:recoginzer];
        [self.view removeGestureRecognizer:recoginzer];
        if(recoginzer.state == UIGestureRecognizerStateEnded)
        {
            
            if ([self.sideMenuController isMenuVisible])
            {
                [self.sideMenuController hideMenuAnimated:YES];
            }
            else
            {
                [self.sideMenuController showMenuAnimated:YES];
            }
        }
        
        return;
    }
    
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
//            self.view.frame = CGRectMake(0, YSTART, frame.size.width , frame.size.height);
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
       
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        startBackViewX = startX;
        [lastScreenShotView setFrame:CGRectMake(startBackViewX,
                                                lastScreenShotView.frame.origin.y,
                                                lastScreenShotView.frame.size.height,
                                                lastScreenShotView.frame.size.width)];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}
@end