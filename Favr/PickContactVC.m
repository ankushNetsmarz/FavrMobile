//
//  PickContactVC.m
//  Favr
//
//  Created by Ankush on 01/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "PickContactVC.h"

@interface PickContactVC ()

//@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;

@end

@implementation PickContactVC


static NSString const *kContact = @"Contact";
static NSString const *kGroup = @"Group";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    
    /*
     This option is also selected in the storyboard. Usually it is better to configure a table view in a xib/storyboard, but we're redundantly configuring this in code to demonstrate how to do that.
     */
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    // populate the data array with some example objects
    self.dataArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"contactDetails"]];
//    NSString *itemFormatString = NSLocalizedString(@"Item %d", @"Format string for item");
//    for (unsigned int itemNumber = 1; itemNumber <= 8; itemNumber++)
//    {
//        NSString *itemName = [NSString stringWithFormat:itemFormatString, itemNumber];
//        [self.dataArray addObject:itemName];
//    }
    
    // make our view consistent
    [self updateButtonsToMatchTableState];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    addedFavrListArray = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView setEditing:YES animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView.frame = CGRectMake(5.0, 5.0, 5.0, 5.0);
//    cell.accessoryType
    cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectAtIndex:0];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[self.dataArray objectAtIndex:indexPath.row] objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"profileImage.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        cell.imageView.layer.cornerRadius = 27.0f;
        cell.imageView.layer.masksToBounds=YES;
//	cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectAtIndex:0];
    
	return cell;
}


- (void)reloadVisibleCells
{
    [self.tableView beginUpdates];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [indexPaths addObject:indexPath];
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}


#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// The user tapped one of the OK/Cancel buttons.
	if (buttonIndex == 0)
	{
		// Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            
            // Delete the objects from our data model.
            
            [addedFavrListArray addObject:[self.dataArray objectsAtIndexes:indicesOfItemsToDelete]];
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            NSLog(@"addFavrListArray %@", addedFavrListArray);
            
            
            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            // Delete everything, delete the objects from our data model.
            [self.dataArray removeAllObjects];
            
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
	}
}

- (IBAction)deleteAction:(id)sender
{
    // Open a dialog with just an OK button.
	NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
	[actionSheet showInView:self.view];
}

- (IBAction)addAction:(id)sender
{
    // Tell the tableView we're going to add (or remove) items.
    [self.tableView beginUpdates];
    
    // Add an item to the array.
    [self.dataArray addObject:@"New Item"];
    
    // Tell the tableView about the item that was added.
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Tell the tableView we have finished adding or removing items.
    [self.tableView endUpdates];
    
    // Scroll the tableView so the new item is visible
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    // Update the buttons if we need to.
    [self updateButtonsToMatchTableState];
}


#pragma mark - Other Methods

- (IBAction)backBtnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtnAct:(UIBarButtonItem *)sender
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        
        // Delete the objects from our data model.
        
        [addedFavrListArray addObject:[self.dataArray objectsAtIndexes:indicesOfItemsToDelete]];
//        [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        NSLog(@"addFavrListArray %@", addedFavrListArray );
        NSLog(@"[addedFavrListArray objectAtIndex:0] %@", [addedFavrListArray objectAtIndex:0]);
        NSLog(@"[[addedFavrListArray objectAtIndex:0] objectAtIndex:0] %@", [[addedFavrListArray objectAtIndex:0] objectAtIndex:0]);
        NSLog(@"userId %@", [[[addedFavrListArray objectAtIndex:0] objectAtIndex:0] objectAtIndex:3]);
        
        NSDate *date = [NSDate date];
        NSString *dateString = [[NSString alloc] initWithFormat:@"%@", date];
        NSLog(@"date string %@", dateString);
        
        NSString *helperId = [[[addedFavrListArray objectAtIndex:0] objectAtIndex:0] objectAtIndex:3];
        NSString *helpeeId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        
        
        NSLog(@"helperId = %@, favrTitleString = %@, favrDescriptionString = %@, helpeeId = %@", helperId, self.favrTitleString, self.favrDescriptionString, helpeeId);
        [PFCloud callFunctionInBackground:@"createFavr"
                           withParameters:@{
                                            @"helpeeId": helpeeId,
                                            @"favrTitle": self.favrTitleString,
                                            @"favrDescription":self.favrDescriptionString,
                                            @"helper": helperId
                                            }
                                    block:^(NSString *results, NSError *error) {
                                        
                                        [hud hide:YES];
                                        [self showStatus:@"Favr Created Successfully" timeout:5];
//                                        if (!error) {
//                                            NSLog(@"result: %@",results);
//                                            
//                                            if([results isEqualToString:@"You are not registered with us, try SignUp!"])
//                                            {
//                                                [hud hide:YES];
////                                                [self showAlertWithText:@"Favr" :results];
//                                            }
//                                            else if([results isEqualToString:@"Username/Password doesnt match !"])
//                                            {
//                                                [hud hide:YES];
////                                                [self showAlertWithText:@"Favr" :results];
//                                            }
//                                            else{
////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtPassword.text forKey:@"loggedInUserPassword"];
////                                                [[NSUserDefaults standardUserDefaults] setObject:self.txtEmailId.text forKey:@"loggedInUserEmail"];
////                                                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"userId"];
////                                                [[NSUserDefaults standardUserDefaults]synchronize];
////                                                [self performSegueWithIdentifier:@"loginToLandingSague"  sender:nil];
//                                                
//                                            }
//                                        }
                                    }];

        
        // Tell the tableView that we deleted the objects
//        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        // Delete everything, delete the objects from our data model.
//        [self.dataArray removeAllObjects];
//        
//        // Tell the tableView that we deleted the objects.
//        // Because we are deleting all the rows, just reload the current table section
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Exit editing mode after the deletion.
//    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];

//    NSString *actionTitle;
//    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
//        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
//    }
//    else
//    {
//        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
//    }
//    
//    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
//    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
//                                                             delegate:self
//                                                    cancelButtonTitle:cancelTitle
//                                               destructiveButtonTitle:okTitle
//                                                    otherButtonTitles:nil];
//    
//	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//    
//    // Show from our table view (pops up in the middle of the table).
//	[actionSheet showInView:self.view];
}


- (void)showStatus:(NSString *)message timeout:(double)timeout {
    statusAlert = [[UIAlertView alloc] initWithTitle:nil
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
    [statusAlert show];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerExpired:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)timerExpired:(NSTimer *)timer {
    [statusAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:array.count-4] animated:YES];
    
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//        //Do not forget to import AnOldViewController.h
//        if ([controller isKindOfClass:[PendingFavrVC class]]) {
//            
//            [self.navigationController popToViewController:controller
//                                                  animated:YES];
//            break;
//        }
//    }
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)contactGroupSegmentControl:(UISegmentedControl *)sender {
    
    if(sender.selectedSegmentIndex==0){
        contact_Group =[NSString stringWithFormat:@"%@",kContact];
    }
    else{
        contact_Group =[NSString stringWithFormat:@"%@",kGroup];
    }
    [self.tableView reloadData];
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
//    if (self.tableView.editing)
//    {
//        // Show the option to cancel the edit.
//        self.navigationItem.rightBarButtonItem = self.cancelButton;
//        
//        [self updateDeleteButtonTitle];
//        
//        // Show the delete button.
//        self.navigationItem.leftBarButtonItem = self.deleteButton;
//    }
//    else
//    {
//        // Not in editing mode.
//        self.navigationItem.leftBarButtonItem = self.addButton;
//        
//        // Show the edit button, but disable the edit button if there's nothing to edit.
//        if (self.dataArray.count > 0)
//        {
//            self.editButton.enabled = YES;
//        }
//        else
//        {
//            self.editButton.enabled = NO;
//        }
//        self.navigationItem.rightBarButtonItem = self.editButton;
//    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
//        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
//        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    contactListArray = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"contactDetails"]];
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
//    
//}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:YES];
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [contactListArray count];
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *cellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    cell.textLabel.text = [[contactListArray objectAtIndex:indexPath.row] objectAtIndex:0];
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[contactListArray objectAtIndex:indexPath.row] objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"profileImage.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
//    cell.imageView.layer.cornerRadius = 27.0f;
//    cell.imageView.layer.masksToBounds=YES;
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (IBAction)backBtnAct:(UIBarButtonItem *)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

@end
