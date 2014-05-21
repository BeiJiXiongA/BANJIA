//
//  UINavigationController+JDSideMenu.m
//  BANJIA
//
//  Created by TeekerZW on 5/6/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "UINavigationController+JDSideMenu.h"

@implementation UINavigationController (JDSideMenu)
- (JDSideMenu *)sideMenuController
{
    if ([self.parentViewController isKindOfClass:[JDSideMenu class]]) {
        return (JDSideMenu *)self.parentViewController;
    }
    
    return nil;
}
@end
