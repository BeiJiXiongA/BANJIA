//
//  XDContentViewController+JDSideMenu.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController+JDSideMenu.h"

@implementation XDContentViewController (JDSideMenu)

- (JDSideMenu *)sideMenuController
{
    if ([self.parentViewController isKindOfClass:[JDSideMenu class]])
    {
        return (JDSideMenu*)self.parentViewController;
    }
    
    return nil;
}
@end
