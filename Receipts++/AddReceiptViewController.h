//
//  AddReceiptViewController.h
//  Receipts++
//
//  Created by Jimmy Hoang on 2017-06-22.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Receipt+CoreDataClass.h"
#import "Tag+CoreDataClass.h"
@import CoreData;

@protocol AddReceiptViewControllerDelegate <NSObject>

-(void)reloadData;

@end

@interface AddReceiptViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate
>

@property (nonatomic, strong) NSPersistentContainer* persistentContainer;
@property (nonatomic, strong) NSArray<Tag*>* tags;
@property (nonatomic, strong) id<AddReceiptViewControllerDelegate> delegate;

- (void)saveContext;

@end
