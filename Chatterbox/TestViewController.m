//
//  TestViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "TestViewController.h"
#import <Parse/Parse.h>
#import "CBConversation.h"
#import "ChatterboxDataStore.h"
#import "HPGrowingTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "CBMessage.h"
#import "MessageCell.h"
#import "AppDelegate.h"
#import "CBCommons.h"

#define kElementPadding 3

//constants for MessageCell
#define kSpeechBubbleLeftPadding 10
#define kSpeechBubbleTopPadding 10
#define kSpeechBubbleMargin 3
#define kCellWidth 320
#define kLabelFont [UIFont systemFontOfSize:13]

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) UIImageView *containerView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) HPGrowingTextView *growingTextView;

@property (strong, nonatomic) CBConversation *conversation;
@property (strong) NSMutableArray *messages;

@end

@implementation TestViewController

-(id)initWithConversation:(CBConversation*)conversation
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
        
        [[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeNewMessage object:[[UIApplication sharedApplication]delegate] queue:nil usingBlock:^(NSNotification *note) {
            [self loadMessages];
            [self.table reloadData];
        }];
        
        self.hidesBottomBarWhenPushed = YES;
        self.title = conversation.topic;
        self.conversation = conversation;
        [self loadMessages];
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
    self.containerView.image = [[UIImage imageNamed:@"send_message_bar"]stretchableImageWithLeftCapWidth:0 topCapHeight:0];
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
    self.growingTextView.returnKeyType = UIReturnKeySend;
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.growingTextView.delegate = self;
    self.growingTextView.clipsToBounds = YES;
    self.growingTextView.layer.cornerRadius = 3;
    self.growingTextView.layer.shadowRadius = 2;
    self.growingTextView.layer.borderColor = [[UIColor grayColor]CGColor];
    self.growingTextView.layer.borderWidth = 1.0;
    self.growingTextView.userInteractionEnabled = YES;
    //self.growingTextView.internalTextView.keyboardType = UIKeyboardt
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
    [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.sendButton];
    
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    self.table.showsVerticalScrollIndicator = NO;
    
    UIView *clearView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
    clearView.backgroundColor = [UIColor clearColor];
    [clearView.layer setShadowOffset:CGSizeMake(0, 1)];
    [clearView.layer setShadowColor:[[UIColor blackColor]CGColor]];
    [clearView.layer setShadowOpacity:.5];
    self.table.tableHeaderView = clearView;
    
    UIView *clearViewFooter = [[UIView alloc]initWithFrame:self.containerView.frame];
    clearViewFooter.backgroundColor = [UIColor clearColor];
    self.table.tableFooterView = clearViewFooter;

    [self.view addSubview:self.table];
    [self.view addSubview:self.containerView];

    if (self.messages.count) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Cochin" size:24.0];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor]; 
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(self.title, @"title for nav bar");
    [label sizeToFit];

    /*UILabel *backButtonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    backButtonLabel.backgroundColor = [UIColor clearColor];
    backButtonLabel.shadowColor = [UIColor darkGrayColor];
    backButtonLabel.shadowOffset = CGSizeMake(0, 1);
    backButtonLabel.font = [UIFont fontWithName:@"Cochin" size:22];
    backButtonLabel.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [label sizeToFit];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setContainerView:nil];
    [self setGrowingTextView:nil];
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.growingTextView resignFirstResponder];
}*/

- (void)loadMessages
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    self.messages = [NSMutableArray arrayWithArray:[[self.conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]]];
}

- (void)sendMessage:(id)sender
{
    if ([self.conversation.status isEqualToString:@"active"]) {
        NSString *message = self.growingTextView.text;
        
        PFObject *PFMessage = [PFObject objectWithClassName:ParseMessageClassKey];
        [PFMessage setValue:message forKey:@"text"];
        [PFMessage setValue:[PFUser currentUser] forKey:@"sender"];
        [PFMessage setValue:[PFObject objectWithoutDataWithClassName:ParseConversationClassKey objectId:self.conversation.parseObjectID]forKey:@"conversation"];

        __block CBMessage *newMessage = [ChatterboxDataStore createMessageFromParseObject:PFMessage andConversation:self.conversation error:nil];
        [self.messages addObject:newMessage];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
        [self.table beginUpdates];
        [self.table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.table endUpdates];
        
        [PFMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded){
                 [ChatterboxDataStore updateMessage:newMessage withParseObjectDataAfterSave:PFMessage error:nil];
                 [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"Convo%@",self.conversation.parseObjectID] withData:[NSDictionary dictionaryWithObjects:@[@1,self.conversation.parseObjectID,[PFUser currentUser].objectId] forKeys:@[CBAPNTypeKey,CBAPNConvoIDKey,CBAPNSenderIDKey]]];
                 [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeNewMessage object:self userInfo:[NSDictionary dictionaryWithObject:self.conversation forKey:@"conversation"]];
                 //newMessage.sent = YES;
             }
             else{
                 //newMessage.sent = NO;
             }
         }];
        self.growingTextView.text = @"";
        [self.growingTextView resignFirstResponder];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Cannot Send" message:@"Sorry, but you cannot send a message until this conversation becomes active. You will be notified once someone has joined this conversation." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
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
    CBMessage *message = [self.messages objectAtIndex:indexPath.row];
    CGSize labelSize = [message.text sizeWithFont:kLabelFont constrainedToSize:CGSizeMake((kCellWidth/2+20)-2*kSpeechBubbleLeftPadding, CGFLOAT_MAX)];
    float speechBubbleHeight = labelSize.height+2*kSpeechBubbleTopPadding;
    return speechBubbleHeight + 2*kSpeechBubbleMargin;
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
