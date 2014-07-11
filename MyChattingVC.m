//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "MyChattingVC.h"
#import "ChatMessageTableViewCell.h"
#import "SlideNavigationController.h"
#import "LocalStorageService.h"

#import "ChatService.h"

@interface MyChattingVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;

- (IBAction)sendMessage:(id)sender;

@end

@implementation MyChattingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(self.opponent != nil){
        self.messages = [[LocalStorageService shared] messageHistoryWithUserID:self.opponent.ID];
    }else{
        self.messages = [NSMutableArray array];
    }
    
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initializeTextView];
}
-(IBAction)backBtnFunctionality:(id)sender{

    [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
    
}
-(void)initializeTextView{
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.textView setBackgroundColor:[UIColor darkTextColor]];
    
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	self.textView.returnKeyType = UIReturnKeyGo; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.textView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    // Set title
    if(self.opponent != nil){
        self.title = self.opponent.login;
    }else if(self.chatRoom != nil){
        self.title = self.chatRoom.name;
    }
    
    
    // Join room
    if(self.chatRoom != nil && ![self.chatRoom isJoined]){
        [[ChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
            // add the Admin to room
            [joinedChatRoom addUsers:@[@291]];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.chatRoom leaveRoom];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    if(self.textView.text.length == 0){
        return;
    }
    
    // 1-1 Chat
    if(self.opponent != nil){
        // send message
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.recipientID = self.opponent.ID;
        message.text = self.textView.text;
        [[ChatService instance] sendMessage:message];
        
        // save message to history
        [[LocalStorageService shared] saveMessageToHistory:message withUserID:message.recipientID];
        
        // Group Chat
    }else if(self.chatRoom != nil){
        
        //        // Replace the next line with these lines if you would like to connect to Web XMPP Chat widget
        //        //
        //        NSDictionary *messageAsDictionary = @{@"message": self.messageTextField.text};
        //        NSData *messageAsData = [NSJSONSerialization dataWithJSONObject:messageAsDictionary options:0 error:nil];
        //        NSString *message =[[NSString alloc] initWithData:messageAsData encoding:NSUTF8StringEncoding];
        //        NSString *escapedMessage = [CharactersEscapeService escape:message];
        //        //
        //        [[ChatService instance] sendMessage:escapedMessage toRoom:self.chatRoom];
        
        [[ChatService instance] sendMessage:self.textView.text toRoom:self.chatRoom];
        
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.textView setText:nil];
}


#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomName = notification.userInfo[kRoomName];
    
    if([self.chatRoom.JID rangeOfString:roomName].length <=0 ){
        return;
    }
    
    [self.messages addObject:message];
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatMessage *message = (QBChatMessage *)self.messages[indexPath.row];
    //
    [cell configureCellWithMessage:message is1To1Chat:self.opponent != nil];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatMessage *chatMessage = (QBChatMessage *)[self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage is1To1Chat:self.opponent != nil];
    return cellHeight;
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.containerView.frame = containerFrame;
    
	
	// commit animations
	[UIView commitAnimations];
    
    self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                              self.messagesTableView.frame.origin.y,
                                              self.messagesTableView.frame.size.width,
                                              self.messagesTableView.frame.size.height-219);
    
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
    self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                              self.messagesTableView.frame.origin.y,
                                              self.messagesTableView.frame.size.width,
                                              self.messagesTableView.frame.size.height+219);
    
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.containerView.frame = r;
}
@end
