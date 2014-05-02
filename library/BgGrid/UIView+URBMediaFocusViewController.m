//
//  UIView+URBMediaFocusViewController.m
//  HtmlDemo
//
//  Created by TeekerZW on 14-2-10.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "UIView+URBMediaFocusViewController.h"

@implementation UIView (URBMediaFocusViewController)
- (UIImage *)snapshotImageWithScale:(CGFloat)scale {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
	if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
		[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
	}
	else {
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	}
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}
@end
