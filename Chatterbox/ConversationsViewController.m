//
//  ConversationsViewController.m
//  Chatterbox
//
//  Created by Michael Ng on 10/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "ConversationsViewController.h"
#import <Parse/Parse.h>
#import "DialogueViewController.h"
#import "TestViewController.h"
#import "LastMessageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CBCommons.h"
#import "BlocksKit.h"
#import "ParseCenter.h"
#import "AuthenticationViewController.h"
#import "NSError+ParseErrorCodes.h"

#define kAlertTag 89043

@interface ConversationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *observers;

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) NSDictionary *conversationsByTopic;
@property (strong, nonatomic) NSMutableArray *lastMessages;
@property (strong, nonatomic) NSArray *topics;

@end

@implementation ConversationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.title = NSLocalizedString(@"Conversations",@"title for view controller");
        __weak ConversationsViewController *currentVC = self;
        
        // user actions
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeNewConversation object:nil queue:nil usingBlock:^(NSNotification *note) {
            PFObject *conversation = [[note userInfo]objectForKey:CBNotificationKeyConvoObj];
            [currentVC updateConversationsArrayWithConversation:conversation];
            [currentVC loadDataSourceWithConversations:currentVC.conversations];
            [currentVC.table reloadData];
        }]];
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeNewMessage object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([note.object isKindOfClass:[TestViewController class]]) {
                PFObject *conversation = [[note userInfo]objectForKey:CBNotificationKeyConvoObj];
                [currentVC.table beginUpdates];
                [currentVC.table reloadRowsAtIndexPaths:@[[currentVC indexPathForConversation:conversation]] withRowAnimation:UITableViewRowAnimationNone];
                [currentVC.table endUpdates];
            }
        }]];
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeEndedConvo object:nil queue:nil usingBlock:^(NSNotification *note) {
            PFObject *conversation = [[note userInfo]objectForKey:CBNotificationKeyConvoObj];
            [currentVC.table beginUpdates];
            [currentVC.table reloadRowsAtIndexPaths:@[[currentVC indexPathForConversation:conversation]] withRowAnimation:UITableViewRowAnimationNone];
            [currentVC.table endUpdates];
        }]];
        
        //other user actions (APN notifications)
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNActiveConvo object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSString *conversationID = [[note userInfo]objectForKey:CBNotificationKeyConvoId];
            [ParseCenter loadConversationWithObjectId:conversationID cachePolicy:kPFCachePolicyNetworkOnly handler:^(PFObject *object, NSError *error) {
                if (!error) {
                    [self updateConversationsArrayWithConversation:object];
                    [self loadDataSourceWithConversations:self.conversations];
                    [currentVC.table beginUpdates];
                    [currentVC.table reloadRowsAtIndexPaths:@[[currentVC indexPathForConversationWithObjectId:conversationID]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [currentVC.table endUpdates];
                }
            }];
        }]];
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNNewMessage object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSString *conversationID = [[note userInfo]objectForKey:CBNotificationKeyConvoId];
            [ParseCenter loadConversationWithObjectId:conversationID cachePolicy:kPFCachePolicyNetworkOnly handler:^(PFObject *object, NSError *error) {
                if (!error) {
                    [self updateConversationsArrayWithConversation:object];
                    [self loadDataSourceWithConversations:self.conversations];
                    [currentVC.table beginUpdates];
                    [currentVC.table reloadRowsAtIndexPaths:@[[currentVC indexPathForConversationWithObjectId:conversationID]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [currentVC.table endUpdates];
                }
            }];
        }]];
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNEndedConvo object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSString *conversationID = [[note userInfo]objectForKey:CBNotificationKeyConvoId];
            [ParseCenter loadConversationWithObjectId:conversationID cachePolicy:kPFCachePolicyNetworkOnly handler:^(PFObject *object, NSError *error) {
                if (!error) {
                    [self updateConversationsArrayWithConversation:object];
                    [self loadDataSourceWithConversations:self.conversations];
                    [currentVC.table beginUpdates];
                    [currentVC.table reloadRowsAtIndexPaths:@[[currentVC indexPathForConversationWithObjectId:conversationID]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [currentVC.table endUpdates];
                }
            }];
        }]];
        
        // auth notifications
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeUserLoaded object:nil queue:nil usingBlock:^(NSNotification *note) {
            [ParseCenter loadAllUserConversationsWithCachePolicy:kPFCachePolicyNetworkElseCache handler:^(NSArray *objects, NSError *error) {
                currentVC.conversations = [NSMutableArray arrayWithArray:objects];
                [currentVC loadDataSourceWithConversations:currentVC.conversations];
                [currentVC.table reloadData];
            }];
        }]];
        [self.observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeLogout object:nil queue:nil usingBlock:^(NSNotification *note) {
            currentVC.topics = nil;
            currentVC.conversationsByTopic = nil;
            [currentVC.table reloadData];
        }]];
        if ([PFUser currentUser]) {
            [ParseCenter loadAllUserConversationsWithCachePolicy:kPFCachePolicyCacheThenNetwork handler:^(NSArray *objects, NSError *error) {
                currentVC.conversations = [NSMutableArray arrayWithArray:objects];
                // batch query here to get messages?
                [currentVC loadDataSourceWithConversations:currentVC.conversations];
                [currentVC.table reloadData];
            }];
        }
    }
    return self;
}

-(void)dealloc
{
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter]removeObserver:observer];
    }}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [PFUser currentUser] ? @"Log Out" : @"Log In";
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked:)];
    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
    
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    UIView *clearView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
    clearView.backgroundColor = [UIColor clearColor];
    self.table.tableHeaderView = clearView;

    UILabel *navBarLabel = [CBCommons standardNavBarLabel];
    navBarLabel.text = NSLocalizedString(self.title, @"title for nav bar");
    [navBarLabel sizeToFit];
    self.navigationItem.titleView = navBarLabel;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.table deselectRowAtIndexPath:[self.table indexPathForSelectedRow] animated:YES];

    if ([PFUser currentUser]) {
        self.navigationItem.rightBarButtonItem.title = @"Log Out";
    }else{
        self.navigationItem.rightBarButtonItem.title = @"Log In";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}

-(NSMutableArray *)conversations
{
    if (!_conversations) {
        _conversations = [NSMutableArray new];
    }
    return _conversations;
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

-(void)loadDataSourceWithConversations:(NSArray*)conversations;
{
    if (conversations){
        self.topics = [[conversations valueForKeyPath:@"@distinctUnionOfObjects.topic"]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSPredicate *predicate;
        NSArray *conversationsInTopic;
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        
        for (NSString *topic in self.topics){
            predicate = [NSPredicate predicateWithFormat:@"topic like %@",topic];
            conversationsInTopic = [conversations filteredArrayUsingPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:ParseObjectUpdatedAtKey ascending:NO];
            
            NSArray *activeConversations = [conversationsInTopic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status like %@",ParseConversationStatusActive]];
            activeConversations = [activeConversations sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSArray *pendingConversations = [conversationsInTopic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status like %@",ParseConversationStatusPending]];
            pendingConversations = [pendingConversations sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSArray *endedConversations = [conversationsInTopic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status like %@",ParseConversationStatusEnded]];
            endedConversations = [endedConversations sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            conversationsInTopic = [[activeConversations arrayByAddingObjectsFromArray:pendingConversations]arrayByAddingObjectsFromArray:endedConversations];
            [dictionary setObject:conversationsInTopic forKey:topic];
        }
        self.conversationsByTopic = [NSDictionary dictionaryWithDictionary:dictionary];
    }    
}

- (void)updateConversationsArrayWithConversation:(PFObject*)conversation
{
    NSUInteger index = [self.conversations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectId]isEqualToString:conversation.objectId]) {
            return YES;
            *stop = YES;
        }
        return NO;
    }];
    if (index == NSNotFound) {
        [self.conversations addObject:conversation];
    }else{
        [self.conversations replaceObjectAtIndex:index withObject:conversation];
    }
}

-(NSIndexPath*)indexPathForConversation:(PFObject*)conversation
{
    NSString *topic = [conversation valueForKey:ParseConversationTopicKey];
    int row = [[self.conversationsByTopic objectForKey:topic] indexOfObject:conversation];
    int section = [[[self.conversationsByTopic allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]indexOfObject:topic];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(NSIndexPath*)indexPathForConversationWithObjectId:(NSString*)objectId
{
    PFObject *conversation;
    for (PFObject *convo in self.conversations) {
        if ([convo.objectId isEqualToString:objectId]) {
            conversation = convo;
            break;
        }
    }
    return [self indexPathForConversation:conversation];
}

#pragma mark - UITableViewDataSource methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LastMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell"];
    
    if (!cell){
        cell = [[LastMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ConversationCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSString *topic = [self.topics objectAtIndex:indexPath.section];
    PFObject *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    cell.statusLabel.text = [[conversation valueForKey:ParseConversationStatusKey]capitalizedString];
    cell.messageLabel.text = [[conversation objectForKey:ParseConversationLastMessageKey] objectForKey:ParseMessageTextKey] ? : @"(No messages yet)";
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.topics.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.topics objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.conversationsByTopic valueForKey:[self.topics objectAtIndex:section]] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *topic = [self.topics objectAtIndex:indexPath.section];
    PFObject *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    TestViewController *dialogueViewController = [[TestViewController alloc]initWithConversation:conversation];
    [self.navigationController pushViewController:dialogueViewController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *convoState = [[[self.conversationsByTopic valueForKey:[self.topics objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]objectForKey:ParseConversationStatusKey];
    if ([convoState isEqualToString:ParseConversationStatusEnded]) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak ConversationsViewController *weakSelf = self;
        
        UIAlertView *alert = [UIAlertView alertViewWithTitle:@"End Conversation" message:@"Are you sure you would you like to remove this conversation from your list? You cannot undo this action."];
        [alert addButtonWithTitle:@"Yes" handler:^{
            PFObject *conversation = [[weakSelf.conversationsByTopic valueForKey:[weakSelf.topics objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row];
            [[[PFUser currentUser]relationforKey:ParseUserConversationsKey]removeObject:conversation];
            [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [weakSelf.conversations removeObject:conversation];
                    [weakSelf loadDataSourceWithConversations:weakSelf.conversations];
                    
                    [weakSelf.table beginUpdates];
                    if ([weakSelf.conversationsByTopic objectForKey:[conversation valueForKey:ParseConversationTopicKey]]) {
                        [weakSelf.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                    }else{
                        [weakSelf.table deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                    }
                    [weakSelf.table endUpdates];
                }
            }];
        }];
        [alert setCancelButtonWithTitle:@"Cancel" handler:^{}];
        [alert show];
    }
}

#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTag) {
        if (buttonIndex != 0) {
            BOOL login = true;
            if (buttonIndex == 1) {
                login = false;
            }
            AuthenticationViewController *authVC = [[AuthenticationViewController alloc]initForLogin:login];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:authVC];
            [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self presentModalViewController:navController animated:YES];
        }
    }
}


@end
