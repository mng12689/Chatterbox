//
//  Conversation.m
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "CBConversation.h"
#import "CBMessage.h"

@implementation CBConversation

@dynamic parseObjectID;
@dynamic status;
@dynamic topic;
@dynamic user1ID;
@dynamic user2ID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic messages;

- (CBMessage*)lastMessage
{
    if (self.messages.count) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"createdAt" ascending:YES];
        return [[self.messages sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
    }
    return nil;
}

@end
