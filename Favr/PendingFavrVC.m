//
//  PendingFavrVC.m
//  Favr
//
//  Created by Taranjit Singh on 14/06/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//
@import QuartzCore;
#import "PendingFavrVC.h"
#import "FavrCell.h"
#import "SWTableViewCell.h"
#import "UMTableViewCell.h"

@interface PendingFavrVC ()
{
    NSString* incomming_Outgoing;
    NSMutableArray *arrData;
    NSArray *_sections;
    NSArray *selectedRows;
//    NSMutableArray *_testArray;
}
//@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@end

static NSString const *kMsgIncomming = @"INCOMMING";
static NSString const *kMsgOutgoing = @"OUTGOING";
static NSString *kDeleteAllTitle = @"Delete All";
static NSString *kDeletePartialTitle = @"Delete (%d)";


@implementation PendingFavrVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    UIButton *someButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [someButton setBackgroundImage:[UIImage ] forState:UIControlStateNormal];
//    [someButton addTarget:self action:@selector(sendmail)
//         forControlEvents:UIControlEventTouchUpInside];
//    [someButton setShowsTouchWhenHighlighted:YES];
//    
//    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
//    self.navigationItem.rightBarButtonItem=mailbutton;

    
    tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(get_vrns) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refresh;
    pullToRefreshBool = NO;
    
    [self get_vrns1];
    
//    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:173.0/255.0 alpha:1.0]];
//    [self.deleteBarBtnObj setTintColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 70;
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.dataArray = [[NSMutableArray alloc] initWithObjects:@"Favour 1",@"Favour 2",@"Favour 3",@"Favour 4",@"Favour 5",@"Favour 6",@"Favour 7",@"Favour 8",@"Favour 9",@"Favour 10", nil];
    
    editingModeOn = NO;
    
    incomming_Outgoing =[NSString stringWithFormat:@"%@",kMsgIncomming];
    
    self.navigationItem.title = @"Pull to Toggle Cell Type";
    
    // Setup refresh control for example app
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
//    refreshControl.tintColor = [UIColor blueColor];
//    
//    [self.tableView addSubview:refreshControl];
//    self.refreshControl = refreshControl;
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    
    _sections = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    [self get_vrns];
}

-(void) get_vrns
{
    pullToRefreshBool = YES;
    NSLog(@"pull to refresh");
    if ([incomming_Outgoing isEqualToString:(NSString *)kMsgIncomming])
    {
        [incomingFavrListArray removeAllObjects];
        [incomingFavrUserArray removeAllObjects];
    }
    else if ([incomming_Outgoing isEqualToString:(NSString *) kMsgOutgoing])
    {
        [outgoingFavrListArray removeAllObjects];
        [outgoingFavrListArray removeAllObjects];
    }
    
    [self listIncomingOutgoing:self.segmentControl];
    
}


-(void) get_vrns1
{
    pullToRefreshBool = NO;
    if ([incomming_Outgoing isEqualToString:(NSString *)kMsgIncomming])
    {
        [incomingFavrListArray removeAllObjects];
        [incomingFavrUserArray removeAllObjects];
    }
    else if ([incomming_Outgoing isEqualToString:(NSString *) kMsgOutgoing])
    {
        [outgoingFavrListArray removeAllObjects];
        [outgoingFavrListArray removeAllObjects];
    }
    
    [self listIncomingOutgoing:self.segmentControl];
}



#pragma mark UITableViewDataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return _testArray.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([incomming_Outgoing isEqualToString:(NSString *)kMsgIncomming])
    {
        if (incomingFavrListArray.count == incomingFavrUserArray.count)
        {
            return [incomingFavrUserArray count];
        }
    }
    else if ([incomming_Outgoing isEqualToString:(NSString *)kMsgOutgoing])
    {
        if (outgoingFavrListArray.count == outgoingFavrUserInfo.count)
        {
            return [outgoingFavrUserInfo count];
        }
    }
    return 0;
//    return [self.dataArray count];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cell selected at index path %ld:%ld", (long)indexPath.section, (long)indexPath.row);
//    NSLog(@"selected cell index path is %@", [self.tableView indexPathForSelectedRow]);
//    
//    
//    
//    if (!tableView.isEditing) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.useCustomCells)
    {
        UMTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UMCell" forIndexPath:indexPath];
        if ([incomming_Outgoing isEqualToString:(NSString*)kMsgIncomming])
        {
            cell.rightUtilityButtons = [self rightButtonsForIncoming];
        }
        else
        {
            cell.rightUtilityButtons = [self rightButtonsForOutgoing];
        }
        cell.delegate = self;
        cell.label.text = [NSString stringWithFormat:@"Section: %ld, Seat: %ld", (long)indexPath.section, (long)indexPath.row];
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"Cell";
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        if ([incomming_Outgoing isEqualToString:(NSString*)kMsgIncomming])
        {
            cell.rightUtilityButtons = [self rightButtonsForIncoming];
        }
        else
        {
            cell.rightUtilityButtons = [self rightButtonsForOutgoing];
        }
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
        profileImageView.tag = indexPath.row;
        [cell.contentView addSubview:profileImageView];
        profileImageView.layer.cornerRadius = 20.f;
        profileImageView.layer.masksToBounds = YES;
        
        UIButton *favrInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        favrInfo.frame = CGRectMake(285, 20, 30, 30);
        [favrInfo setImage:[UIImage imageNamed:@"info_icon"] forState:UIControlStateNormal];
        [favrInfo addTarget:self action:@selector(favrInfoBtnAct:) forControlEvents:UIControlEventTouchUpInside];
//        checkBox.tag = indexPath.row;
        [cell.contentView addSubview:favrInfo];
        
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:190.0/255 blue:202.0/255 alpha:1] ;
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.text = @"Some detail text";
        
        cell.imageView.hidden = YES;
        cell.imageView.layer.cornerRadius = 32.0f;
        cell.imageView.layer.masksToBounds=YES;
        
        if ([incomming_Outgoing isEqualToString:(NSString *)kMsgIncomming])
        {
            favrInfo.tag = indexPath.row;
            cell.textLabel.text = [[incomingFavrListArray  objectAtIndex:indexPath.row] objectAtIndex:0];
            [profileImageView sd_setImageWithURL:[NSURL URLWithString:[[incomingFavrUserArray objectAtIndex:indexPath.row] objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
            cell.imageView.image = [UIImage imageNamed:@"userImg"];
            cell.detailTextLabel.text = [[incomingFavrUserArray objectAtIndex:indexPath.row] objectAtIndex:0];
        }
        else
        {
            favrInfo.tag = 1000+indexPath.row;
            cell.textLabel.text = [[outgoingFavrListArray objectAtIndex:indexPath.row] objectAtIndex:0];
            [profileImageView sd_setImageWithURL:[NSURL URLWithString:[[outgoingFavrUserInfo objectAtIndex:indexPath.row] objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"profileImage.png"]];
            cell.imageView.image = [UIImage imageNamed:@"userImage2.jpg"];
            cell.detailTextLabel.text = [[outgoingFavrUserInfo objectAtIndex:indexPath.row] objectAtIndex:0];
        }
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        selectedRows = [self.tableView indexPathsForSelectedRows];
//        self.deleteButton.title = (selectedRows.count == 0) ?
//        kDeleteAllTitle : [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowNumber = indexPath.row;
    if (self.tableView.isEditing)
    {
        selectedRows = [self.tableView indexPathsForSelectedRows];
//        NSString *deleteButtonTitle = [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
        if (selectedRows.count == self.dataArray.count)
        {
//            deleteButtonTitle = kDeleteAllTitle;
        }
//        self.deleteButton.title = deleteButtonTitle;
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// The user tapped one of the OK/Cancel buttons.
	if (buttonIndex == 0)
	{
		// Delete what the user selected.
//        selectedRows = [self.tableView indexPathsForSelectedRows];
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
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            selectedRows = nil;
            
        }
        else
        {
            // Delete everything, delete the objects from our data model.
//            [self.dataArray removeAllObjects];
            
            [self.dataArray removeObjectAtIndex:rowNumber];
            NSLog(@"seld.dataArray %@", self.dataArray);
            
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        
        
        
        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
//        [self updateButtonsToMatchTableState];
	}
}



- (void)deleteButton:(id)sender
{
    NSString *actionTitle = ([[self.tableView indexPathsForSelectedRows] count] == 1) ?
    @"Are you sure you want to remove this item?" : @"Are you sure you want to remove these items?";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}


- (void)addButton:(id)sender
{
    [self.tableView beginUpdates];
    [self.dataArray addObject:@"New Item"];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0]];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:NO];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:YES];
//    self.editButton.enabled = (self.dataArray.count > 0) ? YES : NO;
}




//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return _sections[section];
//}

// Show index titles

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//}

#pragma mark - UIRefreshControl Selector

- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    [refreshControl beginRefreshing];
    self.useCustomCells = !self.useCustomCells;
    if (self.useCustomCells)
    {
        self.refreshControl.tintColor = [UIColor yellowColor];
    }
    else
    {
        self.refreshControl.tintColor = [UIColor blueColor];
    }
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}


#pragma mark - UIScrollViewDelegate



-(IBAction)favrInfoBtnAct:(UIButton *)sender
{
    if ([incomming_Outgoing isEqualToString:(NSString *)kMsgIncomming])
    {
        FavrInfoVC *favrInfoVC = [[FavrInfoVC alloc] init];
        favrInfoVC.favrId = [[incomingFavrListArray objectAtIndex:sender.tag] objectAtIndex:2];
        favrInfoVC.navigationTitle = [[incomingFavrUserArray objectAtIndex:sender.tag] objectAtIndex:0];
        favrInfoVC.incoming_outgoingString = (NSString *)kMsgIncomming;
        favrInfoVC.pendingFavrStatus = 1;
        [self.navigationController pushViewController:favrInfoVC animated:YES];
    }
    else if ([incomming_Outgoing isEqualToString:(NSString *)kMsgOutgoing])
    {
        FavrInfoVC *favrInfoVC = [[FavrInfoVC alloc] init];
        favrInfoVC.favrId = [[outgoingFavrListArray objectAtIndex:sender.tag - 1000] objectAtIndex:2];
        favrInfoVC.navigationTitle = [[outgoingFavrUserInfo objectAtIndex:sender.tag - 1000] objectAtIndex:0];
        favrInfoVC.incoming_outgoingString = (NSString *)kMsgOutgoing;
        favrInfoVC.pendingFavrStatus = 1;
        [self.navigationController pushViewController:favrInfoVC animated:YES];
    }

}


- (NSArray *)rightButtonsForIncoming
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"cellChat"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"cross"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"check"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"trashBtn"]];
    return rightUtilityButtons;
}

- (NSArray *)rightButtonsForOutgoing
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"cellEdit"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"cellChat"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:61.0f/255.0f green:165.0f/255.0f blue:181.0f/255.0f alpha:1.0] icon:[UIImage imageNamed:@"trashBtn"]];
    
    return rightUtilityButtons;
}



- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    return leftUtilityButtons;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}


- (IBAction)deleteButtonAction:(UIBarButtonItem *)sender
{

    
    
    NSLog(@"_testArray%@", self.dataArray);
    NSLog(@"tableView Editing %i", self.tableView.editing);
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (!self.tableView.editing)
    {
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            NSString *actionTitle = ([[self.tableView indexPathsForSelectedRows] count] == 1) ?
            @"Are you sure you want to remove this item?" : @"Are you sure you want to remove these items?";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle delegate:self cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"OK" otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:self.view];
        }
        else
        {
            editingModeOn = NO;
            [self.tableView reloadData];
        }
    }
    else
    {
        editingModeOn = YES;
        [self.tableView reloadData];
    }
}


// Set row height on an individual basis

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [self rowHeightForIndexPath:indexPath];
//}
//
//- (CGFloat)rowHeightForIndexPath:(NSIndexPath *)indexPath {
//    return ([indexPath row] * 10) + 60;
//}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Set background color of cell here if you don't want default white
//}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"More button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 3:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [self.dataArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state)
    {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

-(IBAction)listIncomingOutgoing:(UISegmentedControl*)sender
{
//    [outgoingFavrUserInfo removeAllObjects];
//    [outgoingFavrListArray removeAllObjects];
    
    if(sender.selectedSegmentIndex==0)
    {
        incomming_Outgoing =[NSString stringWithFormat:@"%@",kMsgIncomming];
        if (incomingFavrListArray.count>0)
        {
            [self.tableView reloadData];
            [refresh endRefreshing];
        }
        else
        {
            if (pullToRefreshBool == NO)
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.labelText = @"Loading";
            }
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
            [PFCloud callFunctionInBackground:@"getIncomingPendingFavrList"
                               withParameters:@{@"userId": userId}
                                        block:^(NSArray *results, NSError *error)
             {
                 NSLog(@"results %@", results);
                 if (results.count <= 0)
                 {
                     [hud hide:YES];
                     [refresh endRefreshing];
                     NSLog(@"count 0 called");
                     [self showStatus:@"You have not requested any favr" timeout:1];
                     
                 }
                 incomingFavrListArray = [[NSMutableArray alloc] init];
                 if (results.count > 0)
                 {
                     NSLog(@"results %@", [results objectAtIndex:0]);
                     for (int i = 0; i < results.count; i++)
                     {
                         if ([[[results objectAtIndex:i] valueForKey:@"isAcceptedByHelper"] intValue] == 0)
                         {
                             tempIncomingFavrListArray = [[NSMutableArray alloc] init];
                             [tempIncomingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"favrTitle"]];
                             [tempIncomingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"helpeeId"]];
                             [tempIncomingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"objectId"]];
                             [incomingFavrListArray addObject:tempIncomingFavrListArray];
                         }
                         
                     }
                     NSLog(@"outgoing favr list array %@", incomingFavrListArray);
                     
                     if (incomingFavrListArray.count <= 0)
                     {
                         [refresh endRefreshing];
                         
                     }
                     
                     incomingFavrUserArray = [[NSMutableArray alloc] init];
                     for (int i = 0; i < incomingFavrListArray.count; i++)
                     {
                         [PFCloud callFunctionInBackground:@"getDetailUser"
                                            withParameters:@{@"userId": [[incomingFavrListArray objectAtIndex:i] objectAtIndex:1]}
                                                     block:^(NSArray *results, NSError *error)
                          {
                              if (results.count > 0)
                              {
                                  NSLog(@"results %@", results);
                                  for (int i = 0; i<results.count; i++)
                                  {
                                      tempIncomingFavrListArray = [[NSMutableArray alloc] init];
                                      [tempIncomingFavrListArray addObject:[[results objectAtIndex:0] valueForKey:@"fullName"]];
                                      [tempIncomingFavrListArray addObject:[[results objectAtIndex:0] valueForKey:@"profilePicPath"]];
                                      [incomingFavrUserArray addObject:tempIncomingFavrListArray];
                                  }
                                  NSLog(@"outgoing favr user info %@", incomingFavrUserArray);
                              }
                              else
                              {
                                  NSLog(@"Error Occured");
                              }
                              [refresh endRefreshing];
                              [hud hide:YES];
                              [self.tableView reloadData];
                          }
                          ];
                     }
                     [self.tableView reloadData];
                 }
             }
             ];
        }
//        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
//        NSLog(@"userid %@", userId);
//        [PFCloud callFunctionInBackground:@"getIncomingPendingFavrList"
//                           withParameters:@{@"userId": userId}
//                                    block:^(NSString *results, NSError *error)
//        {
//                                        NSLog(@"results %@", results);
//                                        [refresh endRefreshing];
//            
//        }
//        ];
        
    }
    else
    {
        incomming_Outgoing =[NSString stringWithFormat:@"%@",kMsgOutgoing];
        if (outgoingFavrListArray.count>0)
        {
            [refresh endRefreshing];
            [self.tableView reloadData];
        }
        else
        {
            if (pullToRefreshBool == NO)
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.labelText = @"Loading";
            }
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
            [PFCloud callFunctionInBackground:@"getOutgoingPendingFavrList"
                               withParameters:@{@"userId": userId}
                                        block:^(NSArray *results, NSError *error)
            {
                NSLog(@"results %@", results);
                if (results.count <= 0)
                {
                    [hud hide:YES];
                    [refresh endRefreshing];
                    NSLog(@"count 0 called");
                    [self showStatus:@"You have not requested any favr" timeout:1];
                    
                }
                outgoingFavrListArray = [[NSMutableArray alloc] init];
                if (results.count > 0)
                {
                    NSLog(@"results %@", [results objectAtIndex:0]);
                    for (int i = 0; i < results.count; i++)
                    {
                        tempOutgoingFavrListArray = [[NSMutableArray alloc] init];
                        [tempOutgoingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"favrTitle"]];
                        [tempOutgoingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"helperId"]];
                        [tempOutgoingFavrListArray addObject:[[results objectAtIndex:i] valueForKey:@"objectId"]];
                        [outgoingFavrListArray addObject:tempOutgoingFavrListArray];
                    }
                    NSLog(@"outgoing favr list array %@", outgoingFavrListArray);
                    
                    outgoingFavrUserInfo = [[NSMutableArray alloc] init];
                    for (int i = 0; i < outgoingFavrListArray.count; i++)
                    {
                        [PFCloud callFunctionInBackground:@"getDetailUser"
                                            withParameters:@{@"userId": [[outgoingFavrListArray objectAtIndex:i] objectAtIndex:1]}
                                                    block:^(NSArray *results, NSError *error)
                        {
                            if (results.count > 0)
                            {
                                NSLog(@"results %@", results);
                                for (int i = 0; i<results.count; i++)
                                {
                                    tempOutgoingFavrListArray = [[NSMutableArray alloc] init];
                                    [tempOutgoingFavrListArray addObject:[[results objectAtIndex:0] valueForKey:@"fullName"]];
                                    [tempOutgoingFavrListArray addObject:[[results objectAtIndex:0] valueForKey:@"profilePicPath"]];
                                    [outgoingFavrUserInfo addObject:tempOutgoingFavrListArray];
                                }
                                    NSLog(@"outgoing favr user info %@", outgoingFavrUserInfo);
                            }
                            else
                            {
                                NSLog(@"Error Occured");
                            }
                                [refresh endRefreshing];
                                [hud hide:YES];
                                [self.tableView reloadData];
                        }
                        ];
                    }
                }
                [self.tableView reloadData];
            }
            ];
            
        }
        
    }
//    [self.tableView reloadData];
}

- (void)showStatus:(NSString *)message timeout:(double)timeout
{
    incomingOutgoingAlert = [[UIAlertView alloc] initWithTitle:nil
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
    [incomingOutgoingAlert show];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerExpired:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)timerExpired:(NSTimer *)timer
{
    [incomingOutgoingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)newFavrAct:(UIBarButtonItem *)sender
{
//    ChatUserListVC *chatUserListVC = [[ChatUserListVC alloc] initWithNibName:@"ChatUserListVC" bundle:nil];
//    [self.navigationController pushViewController:chatUserListVC animated:YES];
    CreateFavrVC *createFavr = [[CreateFavrVC alloc] init];
    [self.navigationController pushViewController:createFavr animated:YES];
}
@end
