//
//  ViewController.m
//  Receipts++
//
//  Created by Jimmy Hoang on 2017-06-22.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

#import "ViewController.h"
#import "Receipt+CoreDataClass.h"
#import "Tag+CoreDataClass.h"

NSString * const addReceiptSegue = @"addReceiptSegue";
NSString * const headerReuseIdentifier = @"headerReuseIdentifier";
NSString * const cellReuseIdentifier = @"cellReuseIdentifier";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSArray<Receipt*>* receipts;
@property (nonatomic, strong) NSArray<Tag*>* tags;
@property (nonatomic, strong) NSSet* receiptsPrinted;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.receiptsPrinted       = [NSSet set];
    self.context               = self.persistentContainer.viewContext;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:headerReuseIdentifier];
    [self refreshTags];
}

-(void)viewWillAppear:(BOOL)animated {
    [self refreshTags];
}


#pragma mark - Tag Methods
-(void)createTags {
    Tag* personal    = [[Tag alloc] initWithContext:self.context];
    personal.tagName = @"Personal";
    
    Tag* family    = [[Tag alloc] initWithContext:self.context];
    family.tagName = @"Family";
    
    Tag* business    = [[Tag alloc] initWithContext:self.context];
    business.tagName = @"Business";
    
    [self saveContext];
}

-(void)fetchTags {
    NSFetchRequest* fetchRequest        = [Tag fetchRequest];
    NSSortDescriptor* tagSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:YES];
    [fetchRequest setSortDescriptors:@[tagSortDescriptor]];
    
    NSError* tagFetchError = nil;
    
    self.tags = [self.context executeFetchRequest:fetchRequest error:&tagFetchError];
    
    if (tagFetchError) {
        NSLog(@"Error fetching tags");
        NSLog(@"Fetch Error: %@",tagFetchError.localizedDescription);
    }

}

-(void)refreshTags {
    [self fetchTags];
    
    if (self.tags.count == 0) {
        [self createTags];
    }
    
    [self.tableView reloadData];
}


#pragma mark - Actions
- (IBAction)addButtonPressed:(id)sender {
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tags.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags[section].receipt.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    Tag* tag              = self.tags[indexPath.section];
    NSArray* allTags      = [tag.receipt allObjects];
    Receipt* receipt      = allTags[indexPath.row];

    cell.textLabel.text  = receipt.note;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    header.textLabel.text               = self.tags[section].tagName;
    return header;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:addReceiptSegue]) {
        AddReceiptViewController* addVC = (AddReceiptViewController*)segue.destinationViewController;
        addVC.delegate                  = self;
        addVC.persistentContainer       = self.persistentContainer;
        addVC.tags                      = self.tags;
    }
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

#pragma mark - AddReceiptViewControllerDelegate

-(void)reloadData {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
    
}

@end
