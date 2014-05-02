//
//  ShowDetailImageViewController.m
//  HtmlDemo
//
//  Created by TeekerZW on 14-2-11.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ShowDetailImageViewController.h"
#import <Accelerate/Accelerate.h>
#import "UIImage+URBImageEffects.h"
#import "UIView+URBMediaFocusViewController.h"
#import "Header.h"

//static const CGFloat __overlayAlpha = 0.9f;						// opacity of the black overlay displayed below the focused image
static const CGFloat __animationDuration = 0.18f;				// the base duration for present/dismiss animations (except physics-related ones)
static const CGFloat __maximumDismissDelay = 0.5f;				// maximum time of delay (in seconds) between when image view is push out and dismissal animations begin
//static const CGFloat __resistance = 0.0f;						// linear resistance applied to the image’s dynamic item behavior
//static const CGFloat __density = 1.0f;							// relative mass density applied to the image's dynamic item behavior
static const CGFloat __velocityFactor = 1.0f;					// affects how quickly the view is pushed out of the view
//static const CGFloat __angularVelocityFactor = 1.0f;			// adjusts the amount of spin applied to the view during a push force, increases towards the view bounds
static const CGFloat __minimumVelocityRequiredForPush = 50.0f;	// defines how much velocity is required for the push behavior to be applied

/* parallax options */
static const CGFloat __backgroundScale = 0.9f;					// defines how much the background view should be scaled
static const CGFloat __blurRadius = 2.0f;						// defines how much the background view is blurred
static const CGFloat __blurSaturationDeltaMask = 0.8f;
static const CGFloat __blurTintColorAlpha = 0.2f;				// defines how much to tint the background view

@interface ShowDetailImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, weak) UIViewController *targetViewController;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, readonly) UIWindow *keyWindow;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *urlData;

@property (nonatomic, strong) UIView *blurredSnapshotView;
@property (nonatomic, strong) UIView *snapshotView;

@end

@implementation ShowDetailImageViewController {
	CGRect _originalFrame;
	CGFloat _minScale;
	CGFloat _maxScale;
	CGFloat _lastPinchScale;
	UIInterfaceOrientation _currentOrientation;
	BOOL _hasLaidOut;
	BOOL _unhideStatusBarOnDismiss;
}

- (id)init {
	self = [super init];
	if (self) {
		_hasLaidOut = NO;
		_unhideStatusBarOnDismiss = YES;
		
		self.shouldBlurBackground = YES;
		self.parallaxEnabled = YES;
		self.shouldDismissOnTap = NO;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setup];
}

- (void)setup {
//	self.view.frame = self.keyWindow.bounds;
	
	self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, CGRectGetWidth(self.keyWindow.frame), CGRectGetHeight(self.keyWindow.frame)+20)];
	self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.9f];
	self.backgroundView.alpha = 0.0f;
	self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.backgroundView];
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.backgroundColor = [UIColor clearColor];
	self.scrollView.delegate = self;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollEnabled = NO;
	[self.view addSubview:self.scrollView];
	
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.alpha = 0.0f;
	self.imageView.userInteractionEnabled = YES;
	[self.scrollView addSubview:self.imageView];
	
	/* setup gesture recognizers */
	self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	self.panRecognizer.delegate = self;
	[self.imageView addGestureRecognizer:self.panRecognizer];
	
	// double tap gesture to return scaled image back to center for easier dismissal
	self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
	self.doubleTapRecognizer.delegate = self;
	self.doubleTapRecognizer.numberOfTapsRequired = 2;
	self.doubleTapRecognizer.numberOfTouchesRequired = 1;
	[self.imageView addGestureRecognizer:self.doubleTapRecognizer];
	
	// tap recognizer on area outside image view for dismissing
	self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissFromTap:)];
	self.tapRecognizer.delegate = self;
	self.tapRecognizer.numberOfTapsRequired = 1;
	self.tapRecognizer.numberOfTouchesRequired = 1;
	[self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
	[self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)showImage:(UIImage *)image fromView:(UIView *)fromView withView:(UIView *)snapView {
	[self showImage:image fromView:fromView inViewController:nil withView:snapView];
}

- (void)showImageFromURL:(NSURL *)url fromView:(UIView *)fromView {
	[self showImageFromURL:url fromView:fromView inViewController:nil];
}

- (void)showImage:(UIImage *)image fromView:(UIView *)fromView inViewController:(UIViewController *)parentViewController withView:(UIView *)snapView {
	
	self.fromView = fromView;
	self.targetViewController = parentViewController;
	
	self.imageView.transform = CGAffineTransformIdentity;
	self.imageView.image = image;
	self.imageView.alpha = 1;
		
	// update scrollView.contentSize to the size of the image
	self.scrollView.contentSize = image.size;
	CGFloat scaleWidth = CGRectGetWidth(self.scrollView.frame) / self.scrollView.contentSize.width;
	CGFloat scaleHeight = CGRectGetHeight(self.scrollView.frame) / self.scrollView.contentSize.height;
	CGFloat scale = MIN(scaleWidth, scaleHeight);
	
	// image view's destination frame is the size of the image capped to the width/height of the target view
	CGPoint midpoint = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
	CGSize scaledImageSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
	CGRect targetRect = CGRectMake(midpoint.x - scaledImageSize.width / 2.0, midpoint.y - scaledImageSize.height / 2.0, scaledImageSize.width, scaledImageSize.height);
    DDLOG(@"targetrect=%@",NSStringFromCGRect(targetRect));
	self.imageView.frame = targetRect;
	// set initial frame of image view to match that of the presenting image
	//self.imageView.frame = CGRectMake(midpoint.x - image.size.width / 2.0, midpoint.y - image.size.height / 2.0, image.size.width, image.size.height);
	self.imageView.frame = [self.view convertRect:fromView.frame fromView:nil];
	_originalFrame = targetRect;
	// rotate imageView based on current device orientation
	[self reposition];
    
	if (scale < 1.0f) {
		self.scrollView.minimumZoomScale = 1.0f;
		self.scrollView.maximumZoomScale = 1.0f / scale;
	}
	else {
		self.scrollView.minimumZoomScale = 1.0f / scale;
		self.scrollView.maximumZoomScale = 1.0f;
	}
	
	_minScale = self.scrollView.minimumZoomScale;
	_maxScale = self.scrollView.maximumZoomScale;
	_lastPinchScale = 1.0f;
	_hasLaidOut = YES;
	
    //	NSLog(@"calculated scale=%f, scrollView.minimumzoomScale=%f, scrollView.maximumzoomScale=%f", scale, self.scrollView.minimumZoomScale, self.scrollView.maximumZoomScale);
    //	NSLog(@"targetRect=%@", NSStringFromCGRect(targetRect));
	
	// register for device orientation changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	// register with the device that we want to know when the device orientation changes
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	if (self.targetViewController) {
	}
	else
    {
		// add this view to the main window if no targetViewController was set
        [self.keyWindow addSubview:self.view];
		
		if (self.snapshotView) {
            [self.keyWindow insertSubview:self.snapshotView belowSubview:self.view];
			[self.keyWindow insertSubview:self.blurredSnapshotView aboveSubview:self.snapshotView];
		}
	}
	
}

- (void)showImageFromURL:(NSURL *)url fromView:(UIView *)fromView inViewController:(XDContentViewController *)parentViewController {
	self.fromView = fromView;
	self.targetViewController = parentViewController;
	
	NSString *key = [url.description MD5Hash];
	NSData *data = [FTWCache objectForKey:key];
	if (data)
    {
        [self.urlData appendData:data];
    }
}

- (void)showImage:(UIImage *)image fromView:(UIView *)fromView inViewController:(XDContentViewController *)parentViewController {
	
	self.fromView = fromView;
	self.targetViewController = parentViewController;
	
	CGRect fromRect = [self.view convertRect:fromView.frame fromView:fromView];
	self.imageView.transform = CGAffineTransformIdentity;
	self.imageView.image = image;
	self.imageView.alpha = 1;
	self.imageView.frame = fromRect;
	// create snapshot of background if parallax is enabled
	if (self.parallaxEnabled) {
		[self createViewsForParallaxWithView:parentViewController.bgView];
		
		// hide status bar, but store whether or not we need to unhide it later when dismissing this view
		// NOTE: in iOS 7+, this only works if you set `UIViewControllerBasedStatusBarAppearance` to YES in your Info.plist
		_unhideStatusBarOnDismiss = ![UIApplication sharedApplication].statusBarHidden;
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	}
	
	// update scrollView.contentSize to the size of the image
	self.scrollView.contentSize = image.size;
	CGFloat scaleWidth = CGRectGetWidth(self.scrollView.frame) / self.scrollView.contentSize.width;
	CGFloat scaleHeight = CGRectGetHeight(self.scrollView.frame) / self.scrollView.contentSize.height;
	CGFloat scale = MIN(scaleWidth, scaleHeight);
	
	// image view's destination frame is the size of the image capped to the width/height of the target view
	CGPoint midpoint = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
	CGSize scaledImageSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
	CGRect targetRect = CGRectMake(midpoint.x - scaledImageSize.width / 2.0, midpoint.y - scaledImageSize.height / 2.0, scaledImageSize.width, scaledImageSize.height);
	self.imageView.frame = targetRect;
	
	// set initial frame of image view to match that of the presenting image
	//self.imageView.frame = CGRectMake(midpoint.x - image.size.width / 2.0, midpoint.y - image.size.height / 2.0, image.size.width, image.size.height);
	self.imageView.frame = [self.view convertRect:fromView.frame fromView:nil];
	_originalFrame = targetRect;
	// rotate imageView based on current device orientation
	[self reposition];
    
	if (scale < 1.0f) {
		self.scrollView.minimumZoomScale = 1.0f;
		self.scrollView.maximumZoomScale = 1.0f / scale;
	}
	else {
		self.scrollView.minimumZoomScale = 1.0f / scale;
		self.scrollView.maximumZoomScale = 1.0f;
	}
	
	_minScale = self.scrollView.minimumZoomScale;
	_maxScale = self.scrollView.maximumZoomScale;
	_lastPinchScale = 1.0f;
	_hasLaidOut = YES;
	
    //	NSLog(@"calculated scale=%f, scrollView.minimumzoomScale=%f, scrollView.maximumzoomScale=%f", scale, self.scrollView.minimumZoomScale, self.scrollView.maximumZoomScale);
    //	NSLog(@"targetRect=%@", NSStringFromCGRect(targetRect));
	
	// register for device orientation changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	// register with the device that we want to know when the device orientation changes
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	if (self.targetViewController) {
		[self willMoveToParentViewController:self.targetViewController];
        //		self.targetViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        //		[self.targetViewController.view tintColorDidChange];
		[self.targetViewController addChildViewController:self];
		[self.targetViewController.view addSubview:self.view];
		
		if (self.snapshotView) {
			[self.targetViewController.view insertSubview:self.snapshotView belowSubview:self.view];
			[self.targetViewController.view insertSubview:self.blurredSnapshotView aboveSubview:self.snapshotView];
		}
	}
	else {
		// add this view to the main window if no targetViewController was set
        //		self.keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        //		[self.keyWindow tintColorDidChange];
		[self.keyWindow addSubview:self.view];
		
		if (self.snapshotView) {
			[self.keyWindow insertSubview:self.snapshotView belowSubview:self.view];
			[self.keyWindow insertSubview:self.blurredSnapshotView aboveSubview:self.snapshotView];
		}
	}
	
	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.backgroundView.alpha = 1.0f;
		self.imageView.alpha = 1.0f;
		self.imageView.frame = targetRect;
		
		if (self.snapshotView) {
			self.blurredSnapshotView.alpha = 1.0f;
//			self.blurredSnapshotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, __backgroundScale, __backgroundScale);
//			self.snapshotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, __backgroundScale, __backgroundScale);
		}
		
	} completion:^(BOOL finished) {
		//[self.imageView addGestureRecognizer:self.pinchRecognizer];
		if (self.targetViewController) {
			[self didMoveToParentViewController:self.targetViewController];
		}
		
		if ([self.delegate respondsToSelector:@selector(showDetailImageViewControllerDidAppear:)]) {
			[self.delegate showDetailImageViewControllerDidAppear:self];
		}
	}];
}


- (void)cancelURLConnectionIfAny {
    if (self.urlConnection) [self.urlConnection cancel];
};

- (void)dismiss:(BOOL)animated {
	if (animated) {
		[self dismissToTargetView];
	}
	else {
		self.backgroundView.alpha = 0.0f;
		self.imageView.alpha = 0.0f;
		[self cleanup];
	}
}

- (void)dismissAfterPush {
	[self hideSnapshotView];
	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.backgroundView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self cleanup];
	}];
}

- (void)dismissToTargetView {
	[self hideSnapshotView];
	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.imageView.frame = [self.view convertRect:self.fromView.frame fromView:nil];
		//self.imageView.alpha = 0.0f;
		self.backgroundView.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[self cleanup];
	}];
	// offset image fade out slightly than background/frame animation
	[UIView animateWithDuration:__animationDuration - 0.1 delay:0.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.imageView.alpha = 1.0f;
	} completion:nil];
}

- (void)hideSnapshotView {
	// only unhide status bar if it wasn't hidden before this view appeared
	if (_unhideStatusBarOnDismiss) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	}
	
	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.blurredSnapshotView.alpha = 1.0f;
		self.blurredSnapshotView.transform = CGAffineTransformIdentity;
		self.snapshotView.transform = CGAffineTransformIdentity;
	} completion:^(BOOL finished){
		[self.snapshotView removeFromSuperview];
		[self.blurredSnapshotView removeFromSuperview];
		self.snapshotView = nil;
		self.blurredSnapshotView = nil;
	}];
}

#pragma mark - Private Methods

- (UIWindow *)keyWindow {
	return [UIApplication sharedApplication].keyWindow;
}

- (void)createViewsForParallaxWithView:(UIView *)snapView {
	// container view for window
	// inset container view so we can blur the edges, but we also need to scale up so when __backgroundScale is applied, everything lines up
	CGRect containerFrame = CGRectMake(0, YSTART, CGRectGetWidth(self.keyWindow.frame) * (1.0f / __backgroundScale), CGRectGetHeight(self.keyWindow.frame) * (1.0f / __backgroundScale));
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectIntegral(containerFrame)];
	containerView.backgroundColor = [UIColor whiteColor];
	
	// add snapshot of window to the container
	UIImage *windowSnapshot = [snapView snapshotImageWithScale:[UIScreen mainScreen].scale];
	UIImageView *windowSnapshotView = [[UIImageView alloc] initWithImage:windowSnapshot];
	windowSnapshotView.center = containerView.center;
	[containerView addSubview:windowSnapshotView];
    containerView.center = self.keyWindow.center;
	
	UIImageView *snapshotView;
	// only add blurred view if radius is above 0
	if (self.shouldBlurBackground && __blurRadius) {
		UIImage *snapshot = [containerView snapshotImageWithScale:[UIScreen mainScreen].scale];
		snapshot = [snapshot URB_applyBlurWithRadius:__blurRadius
										   tintColor:[UIColor colorWithWhite:0.0f alpha:__blurTintColorAlpha]
							   saturationDeltaFactor:__blurSaturationDeltaMask
										   maskImage:nil];
		snapshotView = [[UIImageView alloc] initWithImage:snapshot];
		snapshotView.center = containerView.center;
		snapshotView.alpha = 1.0f;
		snapshotView.userInteractionEnabled = NO;
	}
	
	self.snapshotView = containerView;
	self.blurredSnapshotView = snapshotView;
}

- (void)adjustFrame {
	CGRect imageFrame = self.imageView.frame;
	
	// snap x sides
	if (CGRectGetWidth(imageFrame) > CGRectGetWidth(self.view.frame)) {
		if (CGRectGetMinX(imageFrame) > 0) {
			imageFrame.origin.x = 0;
		}
		else if (CGRectGetMaxX(imageFrame) < CGRectGetWidth(self.view.frame)) {
			imageFrame.origin.x = CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageFrame);
		}
	}
	else if (self.imageView.center.x != CGRectGetMidX(self.view.frame)) {
		imageFrame.origin.x = CGRectGetMidX(self.view.frame) - CGRectGetWidth(imageFrame) / 2.0f;
	}
	
	// snap y sides
	if (CGRectGetHeight(imageFrame) > CGRectGetHeight(self.view.frame)) {
		if (CGRectGetMinY(imageFrame) > 0) {
			imageFrame.origin.y = 0;
		}
		else if (CGRectGetMaxY(imageFrame) < CGRectGetHeight(self.view.frame)) {
			imageFrame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(imageFrame);
		}
	}
	else if (self.imageView.center.y != CGRectGetMidY(self.view.frame)) {
		imageFrame.origin.y = CGRectGetMidY(self.view.frame) - CGRectGetHeight(imageFrame) / 2.0f;
	}
	
	[UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.imageView.frame = imageFrame;
	} completion:^(BOOL finished) {
		
	}];
}

- (void)centerScrollViewContents {
	CGSize contentSize = self.scrollView.contentSize;
	CGFloat offsetX = (CGRectGetWidth(self.scrollView.frame) > contentSize.width) ? (CGRectGetWidth(self.scrollView.frame) - contentSize.width) / 2.0f : 0.0f;
	CGFloat offsetY = (CGRectGetHeight(self.scrollView.frame) > contentSize.height) ? (CGRectGetHeight(self.scrollView.frame) - contentSize.height) / 2.0f : 0.0f;
	self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2.0f + offsetX, self.scrollView.contentSize.height / 2.0f + offsetY);
}

- (void)returnToCenter {
    //	[self.animator removeAllBehaviors];
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.imageView.transform = CGAffineTransformIdentity;
		self.imageView.frame = _originalFrame;
	} completion:nil];
}

- (void)cleanup {
	[self.view removeFromSuperview];
	
	if (self.targetViewController) {
        //		self.targetViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        //		[self.targetViewController.view tintColorDidChange];
		[self willMoveToParentViewController:nil];
		[self removeFromParentViewController];
	}
	else {
        //		self.keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        //		[self.keyWindow tintColorDidChange];
	}
    //	[self.animator removeAllBehaviors];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if ([self.delegate respondsToSelector:@selector(showDetailImageViewControllerDidDisappear:)]) {
		[self.delegate showDetailImageViewControllerDidDisappear:self];
	}
}

#pragma mark - Gesture Methods

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	UIView *view = gestureRecognizer.view;
//	CGPoint location = [gestureRecognizer locationInView:self.view];
	CGPoint boxLocation = [gestureRecognizer locationInView:self.imageView];
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    }
	else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //		self.panAttachmentBehavior.anchorPoint = location;
	}
	else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //		[self.animator removeBehavior:self.panAttachmentBehavior];
		
		// need to scale velocity values to tame down physics on the iPad
		CGFloat deviceScale = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 0.25f : 1.0f;
		CGPoint velocity = [gestureRecognizer velocityInView:self.view];
		CGFloat velocityAdjust = 10.0f * deviceScale;
		
		if (fabs(velocity.x / velocityAdjust) > __minimumVelocityRequiredForPush || fabs(velocity.y / velocityAdjust) > __minimumVelocityRequiredForPush) {
			UIOffset offsetFromCenter = UIOffsetMake(boxLocation.x - CGRectGetMidX(self.imageView.bounds), boxLocation.y - CGRectGetMidY(self.imageView.bounds));
			CGFloat pushVelocity = sqrtf(powf(velocity.x, 2.0f) + powf(velocity.y, 2.0f));
			
			// calculate angles needed for angular velocity formula
			CGFloat locationAngle = atan2f(offsetFromCenter.vertical, offsetFromCenter.horizontal);
			if (locationAngle > 0) {
				locationAngle -= M_PI * 2;
			}
			
			// angle (θ) is the angle between the push vector (V) and vector component parallel to radius, so it should always be positive
			// angular velocity formula: w = (abs(V) * sin(θ)) / abs(r)
			
			
			// delay for dismissing is based on push velocity also
			CGFloat delay = __maximumDismissDelay - (pushVelocity / 10000.0f);
			[self performSelector:@selector(dismissAfterPush) withObject:nil afterDelay:delay * __velocityFactor];
		}
		else {
			[self returnToCenter];
		}
	}
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"handleDoubleTapGesture");
	if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale)
    {
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	}
	else
    {
		CGPoint tapPoint = [self.imageView convertPoint:[gestureRecognizer locationInView:gestureRecognizer.view] fromView:self.scrollView];
		CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        
		CGFloat w = CGRectGetWidth(self.imageView.frame) / newZoomScale;
		CGFloat h = CGRectGetHeight(self.imageView.frame) / newZoomScale;
		CGRect zoomRect = CGRectMake(tapPoint.x - (w / 2.0f), tapPoint.y - (h / 2.0f), w, h);
		
		[self.scrollView zoomToRect:zoomRect animated:YES];
	}
}

- (void)handleDismissFromTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"handleDismissFromTap");
	CGPoint location = [gestureRecognizer locationInView:self.view];
	// make sure tap was on background and not image view
	if (self.shouldDismissOnTap || !CGRectContainsPoint(self.imageView.frame, location)) {
		[self dismissToTargetView];
	}
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	// zoomScale of 1.0 is always our starting point, so anything other than that we disable the pan gesture recognizer
	if (scrollView.zoomScale <= 1.0f) {
		[self.imageView addGestureRecognizer:self.panRecognizer];
		scrollView.scrollEnabled = NO;
	}
	else {
		[self.imageView removeGestureRecognizer:self.panRecognizer];
		scrollView.scrollEnabled = YES;
	}
	[self centerScrollViewContents];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	CGFloat transformScale = self.imageView.transform.a;
	BOOL shouldRecognize = transformScale > _minScale;
	
	// make sure tap and double tap gestures aren't recognized simultaneously
	shouldRecognize = !([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]);
	
	return shouldRecognize;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.loadingView stopAnimating];
	[self.loadingView removeFromSuperview];
	
	if (self.urlData) {
		UIImage *image = [UIImage imageWithData:self.urlData];
		[self showImage:image fromView:self.fromView inViewController:self.targetViewController];
		
		if ([self.delegate respondsToSelector:@selector(showDetailImageViewController:didFinishLoadingImage:)]) {
			[self.delegate showDetailImageViewController:self didFinishLoadingImage:image];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([self.delegate respondsToSelector:@selector(showDetailImageViewController:didFailLoadingImageWithError:)]) {
		[self.delegate showDetailImageViewController:self didFailLoadingImageWithError:error];
	}
}

#pragma mark - Orientation Helpers

- (void)deviceOrientationChanged:(NSNotification *)notification {
	NSLog(@"device orientation changed");
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (_currentOrientation != orientation) {
		_currentOrientation = orientation;
		[self reposition];
	}
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	// calculate a rotation transform that matches the required orientation
	if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		transform = CGAffineTransformMakeRotation(M_PI);
	}
	else if (orientation == UIInterfaceOrientationLandscapeLeft) {
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	}
	else if (orientation == UIInterfaceOrientationLandscapeRight) {
		transform = CGAffineTransformMakeRotation(M_PI_2);
	}
	
	return transform;
}

- (void)reposition {
	CGAffineTransform baseTransform = [self transformForOrientation:_currentOrientation];
	
	// determine if the rotation we're about to undergo is 90 or 180 degrees
	CGAffineTransform t1 = self.imageView.transform;
	CGAffineTransform t2 = baseTransform;
	CGFloat dot = t1.a * t2.a + t1.c * t2.c;
	CGFloat n1 = sqrtf(t1.a * t1.a + t1.c * t1.c);
	CGFloat n2 = sqrtf(t2.a * t2.a + t2.c * t2.c);
	CGFloat rotationDelta = acosf(dot / (n1 * n2));
	BOOL isDoubleRotation = (rotationDelta > M_PI_2);
	
	// use the system rotation duration
	CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
	// iPad lies about its rotation duration
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { duration = 0.4; }
	
	// double the animation duration if we're rotation 180 degrees
	if (isDoubleRotation) { duration *= 2; }
	
	// if we haven't laid out the subviews yet, we don't want to animate rotation and position transforms
	if (_hasLaidOut) {
		[UIView animateWithDuration:duration animations:^{
			self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, baseTransform);
		}];
	}
	else {
		self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, baseTransform);
	}
}
@end
