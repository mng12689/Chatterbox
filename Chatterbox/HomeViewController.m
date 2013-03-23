//
//  HomeViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 10/22/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import <Parse/Parse.h>
#import "AuthenticationViewController.h"
#import "CBCommons.h"
#import "ParseCenter.h"
#import "BlocksKit.h"
#import "NSError+ParseErrorCodes.h"

#define kAlertTag 89043
#define kTopics @[@{@"News":@"news_icon"},@{@"Sports":@"sports_icon"},@{@"Politics":@"politics_icon"},@{@"Finance":@"finance_icon"},@{@"Celebrities":@"celebrities_icon"},@{@"Health":@"fitness_icon"},@{@"Fashion":@"fashion_icon"},@{@"Technology":@"technology_icon"},@{@"Music":@"music_icon"},@{@"Movies":@"movies_icon"},@{@"Travel":@"travel_icon"},@{@"Random":@"random_icon"}]
@interface HomeViewController () <UIAlertViewDelegate>

-(void)startConversation:(UIButton*)sender;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Chattegories",@"title for view controller");
        UILabel *navBarLabel = [CBCommons standardNavBarLabel];
        navBarLabel.text = NSLocalizedString(self.title, @"title for nav bar");
        [navBarLabel sizeToFit];
        self.navigationItem.titleView = navBarLabel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    self.view = scrollView;
    
    NSString *title = [PFUser currentUser] ? @"Log Out" : @"Log In";
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked:)];
    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
    
    // layout topics
    int padding = 20;
    int squareButtonDimensions = 130;//([UIScreen mainScreen].bounds.size.width/2)-padding-(padding/2);
    
    int row = 0;
    int column = 0;
    for (NSDictionary *topic in kTopics)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(padding + column*(padding+squareButtonDimensions), padding + row*(padding+squareButtonDimensions), squareButtonDimensions, squareButtonDimensions);
        [button setTitle:[[topic allKeys]lastObject] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[CBCommons chatterboxOrange] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Cochin" size:22.0];
        [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [button setBackgroundImage:[UIImage imageNamed:@"category_glass_button"] forState:UIControlStateNormal];
        [button setShowsTouchWhenHighlighted:YES];
        
        UIImage *icon = [UIImage imageNamed:[topic valueForKey:[[topic allKeys]lastObject]]];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(-40, -icon.size.width, 0, 0)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(40, 0, 0, -button.titleLabel.bounds.size.width)];
        [button setImage:icon forState:UIControlStateNormal];
        
        button.layer.backgroundColor = [[UIColor clearColor] CGColor];
        button.layer.cornerRadius = 10.0f;
        button.layer.masksToBounds = YES;
        [button.layer setShadowOffset:CGSizeMake(0, 5)];
        [button addTarget:self action:@selector(startConversation:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        
        if (column)
            row++;
        column = !column;
        
        scrollView.contentSize = CGSizeMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y + button.frame.size.height + padding);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([PFUser currentUser]) {
        self.navigationItem.rightBarButtonItem.title = @"Log Out";
    }else{
        self.navigationItem.rightBarButtonItem.title = @"Log In";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startConversation:(UIButton *)sender
{
    // login user if not logged in
    if (![PFUser currentUser]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No User Detected" message:@"We're sorry, but you can not use this feature without an account. What would you like to do?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Up",@"Login", nil];
        alert.tag = kAlertTag;
        [alert show];
        return;
    }

    [SVProgressHUD showWithStatus:@"Finding match..."];
    
    NSString *topic = [sender.titleLabel.text isEqualToString:@"Random"] ? [self randomTopic] : sender.titleLabel.text;

    PFQuery *query = [PFQuery queryWithClassName:ParseConversationClassKey];
    [query whereKey:ParseConversationStatusKey equalTo:ParseConversationStatusPending];
    [query whereKey:ParseConversationTopicKey equalTo:topic];
    [query whereKey:ParseConversationUser1Key notEqualTo:[PFUser currentUser]];
    [query orderByAscending:ParseObjectCreatedAtKey];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *conversation, NSError *error){
        BOOL isNoResultsError = [[[error userInfo] valueForKey:@"code"] intValue] == 101;
        if (!error || isNoResultsError){
            NSString *alertTitle;
            NSString *alertMessage;
            // join conversation
            if (conversation){
                [conversation setValue:ParseConversationStatusActive forKey:ParseConversationStatusKey];
                [conversation setValue:[PFUser currentUser] forKey:ParseConversationUser2Key];
                
                alertTitle = @"Conversation Started"; 
                alertMessage = [NSString stringWithFormat:@"You have entered into a conversation on the subject of %@", topic];
            }
            //create conversation
            else{
                conversation = [PFObject objectWithClassName:ParseConversationClassKey];
                [conversation setValue:topic forKey:ParseConversationTopicKey];
                [conversation setValue:[PFUser currentUser] forKey:ParseConversationUser1Key];
                [conversation setValue:ParseConversationStatusPending forKey:ParseConversationStatusKey];
                
                alertTitle = @"Conversation Pending";
                alertMessage = [NSString stringWithFormat:@"There is no immediate match for you on the subject of %@. We will notify you once a suitable match has been found.",topic];
            }
            [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                 if (succeeded){
                     PFUser *user = [PFUser currentUser];
                     PFRelation *relation = [user relationforKey:@"conversations"];
                     [relation addObject:conversation];
                     [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                         if (succeeded){
                             [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeNewConversation object:self userInfo:[NSDictionary dictionaryWithObject:conversation forKey:CBNotificationKeyConvoObj]];
                                 if ([[conversation valueForKey:ParseConversationStatusKey] isEqualToString:ParseConversationStatusActive]) {
                                     NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:@[@(CBAPNTypeConversationStarted),conversation.objectId,@"Increment"]
                                                                                                forKeys:@[CBAPNTypeKey,CBAPNConvoIDKey,CBAPNBadgeKey]];
                                     NSString *channelName = [NSString stringWithFormat:@"U%@",(PFObject*)[[conversation valueForKey:ParseConversationUser1Key] objectId]];
                                     [PFPush sendPushDataToChannelInBackground:channelName withData:dataDictionary];
                                 }
                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alert show];
                             self.tabBarController.selectedIndex = 1;
                         }else{
                             [error handleErrorWithAlert:NO];                         }
                     }];
                 }else{
                     [error handleErrorWithAlert:NO];
                 }
             }];
        }else{
            [error handleErrorWithAlert:NO];
        }
        [SVProgressHUD dismiss];
    }];
}

- (NSString*)randomTopic
{
    return [[kTopics[arc4random()%(kTopics.count-1)]allKeys]lastObject];
}

- (void)settingsClicked:(id)sender
{
    if ([PFUser currentUser]) {
        [ParseCenter logout];
        self.navigationItem.rightBarButtonItem.title = @"Log In";
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No User Detected" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Up",@"Login", nil];
        alert.tag = kAlertTag;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTag) {
        if (buttonIndex != 0) {
            BOOL login = YES;
            if (buttonIndex == 1) {
                login = NO;
            }
            AuthenticationViewController *authVC = [[AuthenticationViewController alloc]initForLogin:login];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:authVC];
            [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self presentModalViewController:navController animated:YES];
        }
    }
}

@end
