//
//  AddReceiptViewController.m
//  Receipts++
//
//  Created by Jimmy Hoang on 2017-06-22.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

#import "AddReceiptViewController.h"

NSString * const addHeaderReuseIdentifier = @"headerReuseIdentifier";
NSString * const addCellReuseIdentifier = @"cellReuseIdentifier";

@interface AddReceiptViewController ()
@property (weak, nonatomic) IBOutlet UITextField* amountTextField;
@property (weak, nonatomic) IBOutlet UITextField* descriptionTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker* timestampDatePicker;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSMutableSet* tagsChecked;
@property (nonatomic, assign) id currentResponder;

@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:addCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:addHeaderReuseIdentifier];
    self.tableView.allowsMultipleSelection = YES;
    
    self.context = self.persistentContainer.viewContext;
  
    self.tagsChecked = [NSMutableSet set];
    
    UITapGestureRecognizer *viewTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [viewTapped setNumberOfTapsRequired:1];
    [viewTapped setNumberOfTouchesRequired:1];
    [viewTapped setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:viewTapped];
}

#pragma mark - TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentResponder = nil;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Actions
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)donePressed:(id)sender {
    Receipt* newReceipt  = [[Receipt alloc] initWithContext:self.context];
    newReceipt.note      = self.descriptionTextField.text;
    newReceipt.amount    = [self.amountTextField.text doubleValue];
    newReceipt.timestamp = self.timestampDatePicker.date;

    for (Tag* tag in self.tagsChecked) {
        tag.receipt = [tag.receipt setByAddingObject:newReceipt];
    }
    
    [self saveContext];
    [self.delegate reloadData];
}
-(void)resignOnTap:(UITapGestureRecognizer*)sender {
    [self.currentResponder resignFirstResponder];
}


#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:addCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text   = self.tags[indexPath.row].tagName;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:addHeaderReuseIdentifier];
    header.textLabel.text               = @"Categories";
    return header;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tagsChecked addObject:self.tags[indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.tagsChecked removeObject:self.tags[indexPath.row]];
}

@end
