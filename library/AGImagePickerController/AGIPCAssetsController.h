//
//  AGIPCAssetsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

#import "AGImagePickerController.h"
#import "AGIPCGridItem.h"

@protocol SelectAssetsDone;

@interface AGIPCAssetsController : UITableViewController<UITableViewDataSource, UITableViewDelegate, AGIPCGridItemDelegate>

@property (strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableDictionary *selectImageDict;
@property (nonatomic, strong) NSMutableArray *selectKeyArray;

@property (strong) AGImagePickerController *imagePickerController;
@property (nonatomic, assign) id<SelectAssetsDone> selectAssetsDoneDel;

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup andAlreadyAssets:(NSDictionary *)alreadySssets andKeyArray:(NSArray *)keyArray;

@end

@protocol SelectAssetsDone <NSObject>

-(void)selectedAssets:(NSArray *)alreadySelectAssets;

-(void)selectedChanged:(ALAsset *)alasset selected:(BOOL)isSelected;

@end
