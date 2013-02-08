//
//  CBCommons.m
//  Chatterbox
//
//  Created by Michael Ng on 1/21/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import "CBCommons.h"

NSString* const CBAPNTypeKey = @"CBAPNTypeKey";
NSString* const CBAPNConvoIDKey = @"convoID";
NSString* const CBAPNSenderIDKey = @"senderID";
NSString* const CBAPNAlertKey = @"alert";
NSString* const CBAPNBadgeKey = @"badge";

NSString* const CBNotificationTypeAPNActiveConvo = @"APNActiveConvo";
NSString* const CBNotificationTypeAPNNewMessage = @"APNNewMessage";
NSString* const CBNotificationTypeNewMessage = @"NewMessage";
NSString* const CBNotificationTypeNewConversation = @"NewConvo";

NSString* const ParseConversationClassKey = @"Conversation";
NSString* const ParseConversationObjectIDKey = @"objectId";
NSString* const ParseConversationCreatedAtKey = @"createdAt";
NSString* const ParseConversationUpdatedAtKey = @"updatedAt";
NSString* const ParseConversationStatusKey = @"status";
NSString* const ParseConversationTopicKey = @"topic";
NSString* const ParseConversationUser1Key = @"user1";
NSString* const ParseConversationUser2Key = @"user2";
NSString* const ParseConversationMessagesKey = @"messages";

NSString* const ParseMessageClassKey = @"Message";

@implementation CBCommons

+ (UIColor*)chatterboxOrange
{
    return [UIColor colorWithRed:1 green:90.0/255.0 blue:0 alpha:1];
}

@end
