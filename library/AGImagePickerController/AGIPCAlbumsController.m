//
//  AGIPCAlbumsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAlbumsController.h"

#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"
#import "ALAsset+AGIPC.h"
#import "AGIPCGridItem.h"

@interface AGIPCAlbumsController ()<SelectAssetsDone>
{
    NSMutableArray *_assetsGroups;
    AGImagePickerController *_imagePickerController;
}

@property (ag_weak, nonatomic, readonly) NSMutableArray *assetsGroups;

@end

@interface AGIPCAlbumsController ()

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;

- (void)loadAssetsGroups;
- (void)reloadData;

- (void)cancelAction:(id)sender;

@end

@implementation AGIPCAlbumsController

#pragma mark - Properties

@synthesize imagePickerController = _imagePickerController;
@synthesize alreadySelectedAssets;
- (NSMutableArray *)assetsGroups
{
    if (_assetsGroups == nil)
    {
        _assetsGroups = [[NSMutableArray alloc] init];
        [self loadAssetsGroups];
    }
    
    return _assetsGroups;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAlreadySelect:(NSArray *)alreadySelected
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.imagePickerController = imagePickerController;
        self.alreadySelectedAssets = [[NSMutableArray alloc] initWithArray:alreadySelected];
        [self selectedAssets:alreadySelected];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedChanged:) name:@"selectedchanged" object:nil];
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    
    // Setup Notifications
    [self registerForNotifications];
    
    // Navigation Bar Items
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
}

-(void)selectedChanged:(NSNotification *)notification
{
    DDLOG(@"selectedChanged %@",notification.object);
    AGIPCGridItem *item = [notification object];
    if (item.selected)
    {
        if (![self.alreadySelectedAssets containsObject:item.asset])
        {
            [self.alreadySelectedAssets addObject:item.asset];
        }
    }
    else
    {
        if ([self.alreadySelectedAssets containsObject:item.asset])
        {
            [self.alreadySelectedAssets removeObject:item.asset];
        }
    }
    
    if (0 == [self.alreadySelectedAssets count] )
    {
        self.navigationController.navigationBar.topItem.prompt = nil;
    }
    else
    {
        //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
        // Display supports up to select several photos at the same time, springox(20131220)
        NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
        if (0 < maxNumber)
        {
            self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [self.alreadySelectedAssets count], maxNumber];
        }
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
    [self unregisterFromNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Loading", nil, [NSBundle mainBundle], @"Loading...", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    ALAssetsGroup *group = (self.assetsGroups)[indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSUInteger numberOfAssets = group.numberOfAssets;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", numberOfAssets];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)self.assetsGroups[indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithImagePickerController:self.imagePickerController andAssetsGroup:self.assetsGroups[indexPath.row] andAlreadyAssets:self.alreadySelectedAssets];
    controller.selectAssetsDoneDel = self;
    DDLOG(@"self.alreadySelectedAssets %d",[self.alreadySelectedAssets count]);
	[self.navigationController pushViewController:controller animated:YES];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 57;
}

-(BOOL)containThisAsset:(ALAsset *)alasset
{
    for (int i=0; i<[self.alreadySelectedAssets count]; i++)
    {
        ALAsset *asset = [self.alreadySelectedAssets objectAtIndex:i];
        if ([asset isEqual:alasset])
        {
            return YES;
        }
    }
    return NO;
}

-(void)selectedAssets:(NSArray *)alreadySelectAssets
{
    if (0 == [self.alreadySelectedAssets count] )
    {
        self.navigationController.navigationBar.topItem.prompt = nil;
    }
    else
    {
        //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
        // Display supports up to select several photos at the same time, springox(20131220)
        NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
        if (0 < maxNumber)
        {
            self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [self.alreadySelectedAssets count], maxNumber];
        }
    }
}

-(void)selectedChanged:(ALAsset *)alasset selected:(BOOL)isSelected
{
    if (isSelected)
    {
        if (![self.alreadySelectedAssets containsObject:alasset])
        {
            [self.alreadySelectedAssets addObject:alasset];
        }
    }
    else
    {
        if ([self.alreadySelectedAssets containsObject:alasset])
        {
            [self.alreadySelectedAssets removeObject:alasset];
        }
    }
    
    if (0 == [self.alreadySelectedAssets count] )
    {
        self.navigationController.navigationBar.topItem.prompt = nil;
    }
    else
    {
        //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
        // Display supports up to select several photos at the same time, springox(20131220)
        NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
        if (0 < maxNumber)
        {
            self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [self.alreadySelectedAssets count], maxNumber];
        }
    }
}

#pragma mark - Private

- (void)loadAssetsGroups
{
    __ag_weak AGIPCAlbumsController *weakSelf = self;
    
    [self.assetsGroups removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        @autoreleasepool {
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
            {
                if (group == nil || group.numberOfAssets == 0)
                {
                    return;
                }
                
                if (weakSelf.imagePickerController.shouldShowSavedPhotosOnTop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                        [self.assetsGroups insertObject:group atIndex:0];
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] > ALAssetsGroupSavedPhotos) {
                        [self.assetsGroups insertObject:group atIndex:1];
                    } else {
                        [self.assetsGroups addObject:group];
                    }
                } else {
                    [self.assetsGroups addObject:group];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadData];
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                [self.imagePickerController performSelector:@selector(didFail:) withObject:error];
            };	
            
            [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                   usingBlock:assetGroupEnumerator 
                                 failureBlock:assetGroupEnumberatorFailure];
            
        }
        
    });
}

-(void)didFail:(id)sender
{
    
}

- (void)reloadData
{
    [self.tableView reloadData];
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Albums", nil, [NSBundle mainBundle], @"Albums", nil);
}

- (void)cancelAction:(id)sender
{
    [self.alreadySelectedAssets removeAllObjects];
    [self.imagePickerController performSelector:@selector(didCancelPickingAssets)];
}

-(void)didCancelPickingAssets
{
    
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self loadAssetsGroups];
}

@end
