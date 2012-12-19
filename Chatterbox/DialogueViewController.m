//
//  DialogueViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 11/23/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "DialogueViewController.h"
#import <Parse/Parse.h>
#import "Conversation.h"
#import "ChatterboxDataStore.h"
//#import "HPGrowingTextView.h"

@interface DialogueViewController () //<HPGrowingTextViewDelegate>

@property (weak, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) UIView *containerView;
//@property (weak, nonatomic) HPGrowingTextView *growingTextView;

@property (strong) Conversation *conversation;
@property (strong) NSArray *messages;

-(void)sendMessage;

@end

@implementation DialogueViewController

-(id)initWithConversation:(Conversation*)conversation
{
    self = [super init];
    if (self)
    {
        self.title = conversation.topic;
        self.conversation = conversation;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
        self.messages = [[conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    return self;
}

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
     self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 0);
     
     self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
;
     [self.view addSubview:self.containerView];
     
     self.growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(6, 3, 240, 40)];
     self.growingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
     self.growingTextView.minNumberOfLines = 1;
     self.growingTextView.maxNumberOfLines = 5;
     self.growingTextView.returnKeyType = UIReturnKeySend;
     self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 5);
     self.growingTextView.delegate = self;
     [self.containerView addSubview:self.growingTextView];
     
    /*
     CGPoint nextLabelOrigin = ;
     
     for (Message *message in self.messages)
     {
     UILabel *label = [UILabel new];
     label.text = message.text;
     
     [self.scrollView addSubview:label];
     nextLabelOrigin = CGPointMakelabel.frame.origin.y + label.frame.size.height
     
     self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, label.frame.origin.y + label.frame.size.height + 5);
     }*/
/*}
     
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setContainerView:nil];
    [self setGrowingTextView:nil];
    [super viewDidUnload];
}

- (IBAction)sendMessage:(id)sender
{
    UILabel *label = [UILabel new];
    label.text = self.growingTextView.text;
    [self.scrollView addSubview:label];
    
    PFObject *PFMessage = [PFObject objectWithClassName:@"Message"];
    [PFMessage setValue:self.growingTextView.text forKey:@"text"];
    [PFMessage setValue:[PFUser currentUser] forKey:@"sender"];
    [PFMessage setValue:self.conversation forKey:@"conversation"];
    
    [PFMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             [ChatterboxDataStore createMessageFromParseObject:PFMessage];
             NSError *error = nil;
             [ChatterboxDataStore saveContext:&error];
         }
         else{
             //error handling
         }
     }];
    
}

#pragma mark - growingTextView delegate methods

/*-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    [UIView animateWithDuration:1 animations:^{
        self.containerView.bounds = CGRectMake(self.containerView.bounds.origin.x, self.containerView.bounds.origin.y, self.containerView.bounds.size.width, self.containerView.bounds.size.height + height);
    }];
}*/

@end
