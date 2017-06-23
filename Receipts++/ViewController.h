//
//  ViewController.h
//  Receipts++
//
//  Created by Jimmy Hoang on 2017-06-22.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddReceiptViewController.h"
@import CoreData;

@interface ViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource,
AddReceiptViewControllerDelegate
>

@property (nonatomic, strong) NSPersistentContainer* persistentContainer;


- (void)saveContext;

@end

