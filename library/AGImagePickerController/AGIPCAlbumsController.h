//
//  AGIPCAlbumsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AGImagePickerController.h"

@interface AGIPCAlbumsController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong) AGImagePickerController *imagePickerController;
@property (nonatomic, strong) NSMutableDictionary *alreadySelectedAssets;
@property (nonatomic, strong) NSMutableArray *alreadyKeyArray;

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAlreadySelect:(NSDictionary *)alreadySelected andKeyArray:(NSArray *)keyArray;

@end
