//
//  Conversation.m
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "Conversation.h"
#import "Message.h"

@implementation Conversation

@dynamic parseObjectID;
@dynamic status;
@dynamic topic;
@dynamic user1ID;
@dynamic user2ID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic messages;

- (Message*)lastMessage
{
    if (self.messages.count) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"createdAt" ascending:YES];
        return [[self.messages sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
    }
    return nil;
}

@end
