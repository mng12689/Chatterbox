//
//  TestViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "TestViewController.h"
#import <Parse/Parse.h>
#import "HPGrowingTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "MessageCell.h"
#import "AppDelegate.h"
#import "CBCommons.h"
#import "ParseCenter.h"
#import "BlocksKit.h"
#import "SVProgressHUD.h"
#import "NSError+ParseErrorCodes.h"

#define kElementPadding 3

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) UIImageView *containerView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) HPGrowingTextView *growingTextView;

@property (strong, nonatomic) PFObject *conversation;
@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableArray *observers;
@property (strong, nonatomic) PFQuery *activeQuery;

@end

@implementation TestViewController

-(id)initWithConversation:(PFObject*)conversation
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.title = [conversation valueForKey:ParseConversationTopicKey];
        self.conversation = conversation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.containerView = [[UIImageView alloc]initWithFrame:CGRectMake(0,
                                                                 self.view.frame.size.height-38,
                                                                 self.view.frame.size.width,
                                                                 38)];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.containerView.image = [[UIImage imageNamed:@"send_message_bar"]stretchableImageWithLeftCapWidth:0 topCapHeight:6];
    self.containerView.layer.zPosition = 100;
    self.containerView.userInteractionEnabled = YES;
    
    self.growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(kElementPadding,
                                                                              kElementPadding,
                                                                              240,
                                                                              self.containerView.frame.size.height-2*kElementPadding)];
    self.growingTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
    self.growingTextView.userInteractionEnabled = YES;
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 5;
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.growingTextView.delegate = self;
    self.growingTextView.clipsToBounds = YES;
    self.growingTextView.layer.cornerRadius = 3;
    self.growingTextView.layer.shadowRadius = 2;
    self.growingTextView.layer.borderColor = [[UIColor grayColor]CGColor];
    self.growingTextView.layer.borderWidth = 1.0;
    self.growingTextView.userInteractionEnabled = YES;
    [self.containerView addSubview:self.growingTextView];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [self.sendButton setTitleShadowColor:[UIColor colorWithWhite:.5 alpha:.6] forState:UIControlStateNormal];
    [self.sendButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Cochin" size:16];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"glass_button_orange"] forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.growingTextView.frame.origin.x+self.growingTextView.frame.size.width+kElementPadding,
                                       self.growingTextView.frame.origin.y,
                                       self.view.frame.size.width-self.growingTextView.frame.size.width-3*kElementPadding,
                                       self.growingTextView.frame.size.height);
    self.sendButton.userInteractionEnabled = YES;
    [self.sendButton setEnabled:NO];
    [self.sendButton addTarget:self action:@selector(createMessageAndSend) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.sendButton];
    
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.containerView.frame.size.height)];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    self.table.showsVerticalScrollIndicator = NO;
    self.table.tableFooterView = [self tableFooterView];
    
    UIView *clearView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
    clearView.backgroundColor = [UIColor clearColor];
    [clearView.layer setShadowOffset:CGSizeMake(0, 1)];
    [clearView.layer setShadowColor:[[UIColor blackColor]CGColor]];
    [clearView.layer setShadowOpacity:.5];
    self.table.tableHeaderView = clearView;

    [self.view addSubview:self.table];
    [self.view addSubview:self.containerView];
    
    UILabel *navBarLabel = [CBCommons standardNavBarLabel];
    navBarLabel.text = NSLocalizedString(self.title, @"title for nav bar");
    [navBarLabel sizeToFit];
    self.navigationItem.titleView = navBarLabel;
    
    if ([[self.conversation valueForKey:ParseConversationStatusKey]isEqualToString:ParseConversationStatusActive]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"End" style:UIBarButtonItemStylePlain target:self action:@selector(endConversation)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setContainerView:nil];
    [self setGrowingTextView:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    __weak TestViewController *currentVC = self;
    self.activeQuery = [ParseCenter loadMessagesFromConversation:self.conversation afterDate:nil cachePolicy:kPFCachePolicyCacheThenNetwork handler:^(NSArray *objects, NSError *error) {
        currentVC.activeQuery = nil;
        if (!error) {
            currentVC.messages = [NSMutableArray arrayWithArray:objects];
            [currentVC.table reloadData];
            if (objects.count) {
                [currentVC.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:objects.count-1 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:NO];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNNewMessage object:[[UIApplication sharedApplication]delegate] queue:nil usingBlock:^(NSNotification *note) {
        if (!self.activeQuery) {
            NSDate *lastMessageDate = [[currentVC.messages lastObject] valueForKey:ParseObjectUpdatedAtKey];
            [ParseCenter loadMessagesFromConversation:currentVC.conversation afterDate:lastMessageDate cachePolicy:kPFCachePolicyNetworkElseCache handler:^(NSArray *objects, NSError *error) {
                [currentVC.messages addObjectsFromArray:objects];
                [currentVC.table reloadData];
                if (currentVC.messages.count) {
                    [currentVC.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentVC.messages.count-1 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
                }
            }];
        }
    }]];
    [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNActiveConvo object:[[UIApplication sharedApplication]delegate] queue:nil usingBlock:^(NSNotification *note) {
        if ([[note.userInfo valueForKey:CBNotificationKeyConvoId]isEqualToString:currentVC.conversation.objectId]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Conversation Started", @"alert title") message:@"This conversation has become active" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            currentVC.table.tableFooterView = [currentVC tableFooterView];
            [currentVC.conversation refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                currentVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"End" style:UIBarButtonItemStylePlain target:currentVC action:@selector(endConversation)];
            }];
        }
    }]];
    [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNEndedConvo object:[[UIApplication sharedApplication]delegate] queue:nil usingBlock:^(NSNotification *note) {
        if ([[note.userInfo valueForKey:CBNotificationKeyConvoId]isEqualToString:currentVC.conversation.objectId]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Conversation Ended", @"alert title") message:@"The person you were talking to has ended this conversation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            currentVC.table.tableFooterView = [currentVC tableFooterView];
            [currentVC.conversation refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                currentVC.navigationItem.rightBarButtonItem = nil;
            }];
        }
    }]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter]removeObserver:observer];
    }
}

-(NSMutableArray *)observers
{
    if (!_observers) {
        _observers = [NSMutableArray new];
    }
    return _observers;
}

-(NSMutableArray *)messages
{
    if (!_messages) {
        _messages = [NSMutableArray new];
    }
    return _messages;
}

- (void)createMessageAndSend
{
    if ([[self.conversation valueForKey:ParseConversationStatusKey] isEqualToString:ParseConversationStatusActive]) {
        PFObject *PFMessage = [PFObject objectWithClassName:ParseMessageClassKey];
        [PFMessage setObject:self.growingTextView.text forKey:ParseMessageTextKey];
        [PFMessage setObject:[PFUser currentUser] forKey:ParseMessageSenderKey];
        [PFMessage setObject:[PFObject objectWithoutDataWithClassName:ParseConversationClassKey objectId:self.conversation.objectId]forKey:ParseMessageConversationKey];
        
        [self.messages addObject:PFMessage];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
        [self.table beginUpdates];
        [self.table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.table endUpdates];
        
        [self sendMessage:PFMessage];
        
        self.growingTextView.text = @"";
        [self.growingTextView resignFirstResponder];
    }else{
        NSString *message;
        if([[self.conversation valueForKey:ParseConversationStatusKey]isEqualToString:ParseConversationStatusPending]){
            message = @"Sorry, but you cannot send a message until this conversation becomes active. You will be notified once someone has joined this conversation.";
        }else{
            message = @"Sorry, but this conversation has been discontinued.";
        }
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Cannot Send" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }    
}

- (void)sendMessage:(PFObject*)PFMessage
{
    if ([[self.conversation valueForKey:ParseConversationStatusKey] isEqualToString:ParseConversationStatusActive]) {
        __weak TestViewController *currentVC = self;
        [PFMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
             if (succeeded){
                 PFRelation *relation = [self.conversation relationforKey:ParseConversationMessagesKey];
                 [relation addObject:PFMessage];
                 [currentVC.conversation setObject:PFMessage forKey:ParseConversationLastMessageKey];
                 [currentVC.conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (succeeded) {
                         NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:@[@(CBAPNTypeNewMessage),currentVC.conversation.objectId,@"Increment"]
                                                                                    forKeys:@[CBAPNTypeKey,CBAPNConvoIDKey,CBAPNBadgeKey]];
                         PFUser *user1 = [currentVC.conversation valueForKey:ParseConversationUser1Key];
                         NSString *channelObjID = [user1.objectId isEqualToString:[PFUser currentUser].objectId] ? [[currentVC.conversation valueForKey:ParseConversationUser2Key]objectId] : user1.objectId;
                         NSString *channelName = [NSString stringWithFormat:@"U%@",channelObjID];
                         [PFPush sendPushDataToChannelInBackground:channelName withData:dataDictionary];
                         [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeNewMessage object:currentVC userInfo:[NSDictionary dictionaryWithObject:self.conversation forKey:CBNotificationKeyConvoObj]];
                     }else{
                         [self handleFailedSendOfMessage:PFMessage];
                     }
                 }];
             }else{
                 [self handleFailedSendOfMessage:PFMessage];
             }
         }];
    }else{
        NSString *message;
        if([[self.conversation valueForKey:ParseConversationStatusKey]isEqualToString:ParseConversationStatusPending]){
            message = @"Sorry, but you cannot send a message until this conversation becomes active. You will be notified once someone has joined this conversation.";
        }else{
            message = @"Sorry, but this conversation has been discontinued.";
        }
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Cannot Send" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)handleFailedSendOfMessage:(PFObject*)PFMessage
{
    NSInteger row = [self.messages indexOfObject:PFMessage];
    MessageCell *cell = (MessageCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    __weak TestViewController *weakSelf = self;
    __weak MessageCell *weakCell = cell;
    [cell addFailureAlertWithBlock:^(id sender) {
        UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@"Resend Message"];
        [actionSheet addButtonWithTitle:@"Resend" handler:^{
            [weakCell removeFailureAlert];
            [weakSelf sendMessage:PFMessage];
        }];
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [actionSheet showInView:weakSelf.table];
    }];
}

- (void)endConversation
{
    __weak TestViewController *weakSelf = self;
    
    UIAlertView *alert = [UIAlertView alertViewWithTitle:@"End Conversation" message:@"Are you sure you would you like to end this conversation? You cannot undo this action."];
    [alert addButtonWithTitle:@"Yes" handler:^{
        [SVProgressHUD showWithStatus:@"Ending conversation"];
        [ParseCenter endConversation:weakSelf.conversation handler:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"Conversation ended"];
                weakSelf.table.tableFooterView = [self tableFooterView];
                weakSelf.navigationItem.rightBarButtonItem = nil;
                [weakSelf.table reloadData];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeEndedConvo object:weakSelf userInfo:[NSDictionary dictionaryWithObject:weakSelf.conversation forKey:CBNotificationKeyConvoObj]];
                NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:@[@(CBAPNTypeConversationEnded),weakSelf.conversation.objectId,@"Increment"]
                                                                           forKeys:@[CBAPNTypeKey,CBAPNConvoIDKey,CBAPNBadgeKey]];
                NSString *otherUserId;
                if (![[PFUser currentUser].objectId isEqualToString:[[weakSelf.conversation objectForKey:ParseConversationUser1Key]objectId]]) {
                    otherUserId = [[weakSelf.conversation objectForKey:ParseConversationUser1Key]objectId];
                }else{
                    otherUserId = [[weakSelf.conversation objectForKey:ParseConversationUser2Key]objectId];
                }
                NSString *channelName = [NSString stringWithFormat:@"U%@",otherUserId];
                [PFPush sendPushDataToChannelInBackground:channelName withData:dataDictionary];
            }else{
                [SVProgressHUD dismiss];
                [error handleErrorWithAlert:NO];
            }
        }];
    }];
    [alert setCancelButtonWithTitle:@"Cancel" handler:^{}];
    [alert show];
}

#pragma mark - tableView data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    if (!cell) {
        cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setMessage:[self.messages objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    return [MessageCell heightForCellWithText:[message valueForKey:ParseMessageTextKey]];
}

- (UILabel*)tableFooterView
{
    NSString *status = [self.conversation objectForKey:ParseConversationStatusKey];
    if ([status isEqualToString:ParseConversationStatusEnded]) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.text = @"Conversation Ended";
        return label;
    }
    return nil;
}

#pragma mark - tableView delegate methods
/*-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewRowAnimationTop animated:NO];
    }
}*/

#pragma mark - HPGrowingTextView delegate methods

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
 {
     float diff = (growingTextView.frame.size.height - height);
     
     CGRect r = self.containerView.frame;
     r.size.height -= diff;
     r.origin.y += diff;
     self.containerView.frame = r;
}
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if (growingTextView.text.length) {
        [self.sendButton setEnabled:YES];
    }else{
        [self.sendButton setEnabled:NO];
    }
}

#pragma mark - UIKeyboardNotifications
-(void) keyboardWillShow:(NSNotification *)note{
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
    CGRect tableFrame = self.table.frame;
    tableFrame.size.height = self.table.bounds.size.height - keyboardBounds.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.containerView.frame = containerFrame;
    self.table.frame = tableFrame;
    if (self.messages.count) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    CGRect tableFrame = self.table.frame;
    tableFrame.size.height = self.view.bounds.size.height-containerFrame.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.containerView.frame = containerFrame;
    self.table.frame = tableFrame;
    if (self.messages.count) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }
	// commit animations
	[UIView commitAnimations];
}

@end
