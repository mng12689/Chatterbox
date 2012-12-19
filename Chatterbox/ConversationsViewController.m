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
#import "Conversation.h"
#import "ChatterboxDataStore.h"
#import "Message.h"
#import "TestViewController.h"

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
        if ([PFUser currentUser]){
            [[NSNotificationCenter defaultCenter] addObserverForName:@"NewConvo" object:nil queue:nil usingBlock:^(NSNotification *note) {
                [self loadUserConversations];
                [self.table reloadData];
            }];
            [self loadUserConversations];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.table.dataSource = self;
    self.table.delegate = self;
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
            [conversationsInTopic sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            [dictionary setObject:conversationsInTopic forKey:topic];
        }
        self.conversationsByTopic = [NSDictionary dictionaryWithDictionary:dictionary];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ConversationCell"];
    }
    
    NSString *topic = [self.topics objectAtIndex:indexPath.section];
    Conversation *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = conversation.status;
    if ([conversation lastMessage])
        cell.detailTextLabel.text = [[conversation lastMessage]text];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *topic = [self.topics objectAtIndex:indexPath.section];
    Conversation *conversation = [[self.conversationsByTopic valueForKey:topic] objectAtIndex:indexPath.row];
    
    TestViewController *dialogueViewController = [[TestViewController alloc]initWithConversation:conversation];
    [self.navigationController pushViewController:dialogueViewController animated:YES];
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

@end
