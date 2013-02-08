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
#import "CBConversation.h"
#import "ChatterboxDataStore.h"
#import "CBMessage.h"
#import "TestViewController.h"
#import "LastMessageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CBCommons.h"
#import "TopicsHeaderView.h"

@interface ConversationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong) NSDictionary *conversationsByTopic;
@property (strong) NSArray *topics;

-(void)loadUserConversations;

@end

@implementation ConversationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.title = NSLocalizedString(@"Conversations",@"title for view controller");
        [[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeNewConversation object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self loadUserConversations];
            [self.table reloadData];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeNewMessage object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([note.object isKindOfClass:[TestViewController class]]) {
                [self.table reloadRowsAtIndexPaths:@[[self indexPathForConversation:[[note userInfo]objectForKey:@"conversation"]]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNActiveConvo object:nil queue:nil usingBlock:^(NSNotification *note) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Conversation Started", @"alert title") message:@"Conversation has become active" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self loadUserConversations];
            [self.table reloadData];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:CBNotificationTypeAPNNewMessage object:nil queue:nil usingBlock:^(NSNotification *note) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"New Message", @"alert title") message:@"new message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self loadUserConversations];
            [self.table reloadData];
        }];
        [self loadUserConversations];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper_bg"]];
    UIView *clearView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
    clearView.backgroundColor = [UIColor clearColor];
    self.table.tableHeaderView = clearView;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Cochin" size:24.0];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(self.title, @"title for nav bar");
    [label sizeToFit];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.table deselectRowAtIndexPath:[self.table indexPathForSelectedRow] animated:YES];
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

-(void)loadUserConversations
{
    if (![PFUser currentUser]) {
        return;
    }
    NSArray *conversations = [ChatterboxDataStore allConversations];
        
    if (conversations)
    {
        self.topics = [[conversations valueForKeyPath:@"@distinctUnionOfObjects.topic"]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSPredicate *predicate;
        NSArray *conversationsInTopic;
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        
        for (NSString *topic in self.topics)
        {
            predicate = [NSPredicate predicateWithFormat:@"topic like %@",topic];
            conversationsInTopic = [conversations filteredArrayUsingPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
            NSArray *activeConversations = [conversationsInTopic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status like %@",@"active"]];
            activeConversations = [activeConversations sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSArray *pendingConversations = [conversationsInTopic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status like %@",@"pending"]];
            conversationsInTopic = [activeConversations arrayByAddingObjectsFromArray:pendingConversations];
            
            [dictionary setObject:conversationsInTopic forKey:topic];
        }
        self.conversationsByTopic = [NSDictionary dictionaryWithDictionary:dictionary];
    }
}

-(NSIndexPath*)indexPathForConversation:(CBConversation*)conversation
{
    int row = [[self.conversationsByTopic objectForKey:conversation.topic]indexOfObject:conversation];
    int section = [[[self.conversationsByTopic allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]indexOfObject:conversation.topic];
    return [NSIndexPath indexPathForRow:row inSection:section];
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
    CBConversation *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    cell.statusLabel.text = [conversation.status isEqualToString:@"pending"] ? @"Pending" : @"Active";
    cell.statusLabel.layer.shadowColor = [conversation.status isEqualToString:@"pending"] ? [[UIColor clearColor]CGColor] : [[UIColor greenColor]CGColor];
    cell.messageLabel.text = [conversation lastMessage] ? [[conversation lastMessage]text] : @"(No messages yet)";
    
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

/*-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TopicsHeaderView *headerView = [[TopicsHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    headerView.label.text = [self.topics objectAtIndex:section];
    return headerView;
}*/

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
    CBConversation *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    TestViewController *dialogueViewController = [[TestViewController alloc]initWithConversation:conversation];
    [self.navigationController pushViewController:dialogueViewController animated:YES];
}


@end
