//
//  HomeViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 10/22/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "SignUpOrLoginViewController.h"
#import "Conversation.h"
#import "ChatterboxDataStore.h"

@interface HomeViewController () <UIAlertViewDelegate>

-(void)startConversation:(UIButton*)sender;

@end

@implementation HomeViewController

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
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.view = scrollView;
    
    NSArray *topics = @[@"News",@"Sports",@"Politics",@"Finance",@"Random"];
    
    // layout topics
    int squareButtonDimensions = 120;
    int padding = 30;
    
    int row = 0;
    int column = 0;
    for (NSString *topic in topics)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, squareButtonDimensions, squareButtonDimensions);
        CGPoint buttonCenter = CGPointMake(self.view.frame.size.width/4 + column*self.view.frame.size.width/2, squareButtonDimensions/2 + (padding + squareButtonDimensions) * row);
        button.layer.position = buttonCenter;
        [button setTitle:topic forState:UIControlStateNormal];
        [button addTarget:self action:@selector(startConversation:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        
        if (column)
            row++;
        column = !column;
        
        scrollView.contentSize = CGSizeMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y + button.frame.size.height + padding);
    }
    
    // login user if not logged in
    if (![PFUser currentUser]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No User Detected" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Sign Up",@"Login", nil];
        [alert show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startConversation:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Finding match..."];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"status" equalTo:@"pending"];
    [query whereKey:@"topic" equalTo:sender.titleLabel.text];
    [query orderByAscending:@"createdAt"];
    [query setLimit:1];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *conversation, NSError *error)
     {
        if (!error || [[[error userInfo] valueForKey:@"code"] intValue] == 101)
        {
            NSString *alertTitle;
            NSString *alertMessage;
            // join conversation
            if (conversation)
            {
                [conversation setValue:@"active" forKey:@"status"];
                [conversation setValue:[PFUser currentUser] forKey:@"user2"];
                
                alertTitle = @"Conversation Started"; 
                alertMessage = [NSString stringWithFormat:@"You have entered into a conversation on the subject of %@", sender.titleLabel.text];
            }
            //create conversation
            else
            {
                conversation = [PFObject objectWithClassName:@"Conversation"];
                [conversation setValue:sender.titleLabel.text forKey:@"topic"];
                [conversation setValue:[PFUser currentUser] forKey:@"user1"];
                [conversation setValue:@"pending" forKey:@"status"];
                
                alertTitle = @"Conversation Pending";
                alertMessage = [NSString stringWithFormat:@"There is no immediate match for you on the subject of %@. We will notify you once a suitable match has been found.",sender.titleLabel.text];
            }
            
            [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (succeeded)
                 {
                     PFUser *user = [PFUser currentUser];
                     PFRelation *relation = [user relationforKey:@"conversations"];
                     [relation addObject:conversation];
                     
                     [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                     {
                         if (succeeded)
                         {
                             [ChatterboxDataStore createConversationFromParseObject:conversation];
                             NSError *error = nil;
                             [ChatterboxDataStore saveContext:&error];
                             if (!error) {
                                 [[NSNotificationCenter defaultCenter]postNotificationName:@"NewConvo" object:self];
                                 NSString *name = [NSString stringWithFormat:@"Convo%@",conversation.objectId];
                                 [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"Convo%@",conversation.objectId]];
                                 
                                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                 [alert show];
                                 
                                 self.tabBarController.selectedIndex = 1;

                             }
                         }
                     }];
                 }
             }];
        }
        else
        {
            NSLog(@"Error: %@", [[error userInfo] valueForKey:@"code"]);
            NSLog(@"FUCKKKKK");
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"No User Detected"]) {
        BOOL login = true;
        if (buttonIndex == 0) {
            login = false;
        }
        SignUpOrLoginViewController *x = [[SignUpOrLoginViewController alloc]initForLogin:login];
        [self presentModalViewController:x animated:YES];
    }
}

@end
