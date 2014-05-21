//
//  KKNavigationController+JDSideMenu.m
//  BANJIA
//
//  Created by TeekerZW on 5/3/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "KKNavigationController+JDSideMenu.h"

@implementation KKNavigationController (JDSideMenu)

- (JDSideMenu *)sideMenuController
{
    if ([self.parentViewController isKindOfClass:[JDSideMenu class]]) {
        return (JDSideMenu *)self.parentViewController;
    }
    
    return nil;
}

@end
