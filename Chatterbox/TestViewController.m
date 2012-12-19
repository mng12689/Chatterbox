//
//  TestViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "TestViewController.h"
#import <Parse/Parse.h>
#import "Conversation.h"
#import "ChatterboxDataStore.h"
#import "HPGrowingTextView.h"
#import "TPKeyboardAvoidingTableView.h"
#import <QuartzCore/QuartzCore.h>

#define kElementPadding 3

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>

@property (strong, nonatomic) TPKeyboardAvoidingTableView *table;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) HPGrowingTextView *growingTextView;

@property (strong) Conversation *conversation;
@property (strong) NSMutableArray *messages;

@end

@implementation TestViewController

-(id)initWithConversation:(Conversation*)conversation
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        self.title = conversation.topic;
        self.conversation = conversation;
        [self loadMessages];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.table = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
    self.table.userInteractionEnabled = NO;
    [self.table setScrollEnabled:YES];
    [self.view addSubview:self.table];
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                 self.view.frame.size.height-38,
                                                                 self.view.frame.size.width,
                                                                 38)];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.containerView.backgroundColor = [UIColor redColor];
    ;
    [self.view addSubview:self.containerView];
    
    self.growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(kElementPadding,
                                                                              kElementPadding,
                                                                              240,
                                                                              self.containerView.frame.size.height-2*kElementPadding)];
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 5;
    self.growingTextView.returnKeyType = UIReturnKeySend;
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.growingTextView.delegate = self;
    self.growingTextView.clipsToBounds = YES;
    self.growingTextView.layer.cornerRadius = 3;
    self.growingTextView.layer.shadowRadius = 2;
    [self.containerView addSubview:self.growingTextView];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.growingTextView.frame.origin.x+self.growingTextView.frame.size.width+kElementPadding,
                                       self.growingTextView.frame.origin.y,
                                       self.view.frame.size.width-self.growingTextView.frame.size.width-3*kElementPadding,
                                       self.growingTextView.frame.size.height);
    self.sendButton.userInteractionEnabled = YES;
    [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.sendButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setContainerView:nil];
    [self setGrowingTextView:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.growingTextView resignFirstResponder];
}

- (void)loadMessages
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    self.messages = [NSMutableArray arrayWithArray:[[self.conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]]];
}

- (void)sendMessage:(id)sender
{
    NSString *message = self.growingTextView.text;
    
    PFObject *PFMessage = [PFObject objectWithClassName:@"Message"];
    [PFMessage setValue:message forKey:@"text"];
    [PFMessage setValue:[PFUser currentUser] forKey:@"sender"];
    [PFMessage setValue:[PFObject objectWithoutDataWithClassName:@"Conversation" objectId:self.conversation.parseObjectID]forKey:@"conversation"];
     
    Message *newMessage = [ChatterboxDataStore createMessageFromParseObject:PFMessage andConversation:self.conversation];
    NSError *error = nil;
    [ChatterboxDataStore saveContext:&error];
    [self.messages addObject:newMessage];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
    [self.table beginUpdates];
    [self.table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.table endUpdates];
     
    [PFMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded){
             [PFPush sendPushMessageToChannelInBackground:[NSString stringWithFormat:@"Convo%@",self.conversation.parseObjectID] withMessage:message];
             //newMessage.sent = YES;
         }
         else{
             //newMessage.sent = NO;
         }
    }];
}

#pragma mark - tableView data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [[self.messages objectAtIndex:indexPath.row] text];
    return cell;
}

#pragma mark - tableView delegate methods


#pragma mark - HPGrowingTextView delegate methods

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
 {
     float diff = (growingTextView.frame.size.height - height);
     
     CGRect r = self.containerView.frame;
     r.size.height -= diff;
     r.origin.y += diff;
     self.containerView.frame = r;
}

-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text) {
        [self.sendButton setEnabled:YES];
    }else{
        [self.sendButton setEnabled:NO];
    }
    return YES;
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
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height - self.tabBarController.tabBar.frame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.containerView.frame = containerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
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
}


@end
