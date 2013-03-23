//
//  CBCommons.m
//  Chatterbox
//
//  Created by Michael Ng on 1/21/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import "CBCommons.h"

// APNs
NSString* const CBAPNTypeKey = @"CBAPNTypeKey";
NSString* const CBAPNConvoIDKey = @"convoID";
NSString* const CBAPNAlertKey = @"alert";
NSString* const CBAPNBadgeKey = @"badge";

// NotificationCenter 
NSString* const CBNotificationTypeAPNActiveConvo = @"APNActiveConvo";
NSString* const CBNotificationTypeAPNEndedConvo = @"APNEndedConvo";
NSString* const CBNotificationTypeAPNNewMessage = @"APNNewMessage";
NSString* const CBNotificationTypeNewMessage = @"NewMessage";
NSString* const CBNotificationTypeNewConversation = @"NewConvo";
NSString* const CBNotificationTypeUserLoaded = @"UserLoaded";
NSString* const CBNotificationTypeLogout = @"Logout";
NSString* const CBNotificationTypeEndedConvo = @"ConvoEnded";

NSString* const CBNotificationKeyConvoObj = @"convoObj";
NSString* const CBNotificationKeyConvoId = @"convoId";

// Parse 
NSString* const ParseObjectIDKey = @"objectId";
NSString* const ParseObjectCreatedAtKey = @"createdAt";
NSString* const ParseObjectUpdatedAtKey = @"updatedAt";

NSString* const ParseConversationClassKey = @"Conversation";
NSString* const ParseConversationStatusKey = @"status";
NSString* const ParseConversationTopicKey = @"topic";
NSString* const ParseConversationUser1Key = @"user1";
NSString* const ParseConversationUser2Key = @"user2";
NSString* const ParseConversationMessagesKey = @"messages";
NSString* const ParseConversationLastMessageKey = @"lastMessage";

NSString* const ParseConversationStatusPending = @"pending";
NSString* const ParseConversationStatusActive = @"active";
NSString* const ParseConversationStatusEnded = @"ended";

NSString* const ParseMessageClassKey = @"Message";
NSString* const ParseMessageSenderKey = @"sender";
NSString* const ParseMessageTextKey = @"text";
NSString* const ParseMessageConversationKey = @"conversation";

NSString* const ParseUserClassKey = @"User";
NSString* const ParseUserConversationsKey = @"conversations";

@implementation CBCommons

+ (UIColor*)chatterboxOrange
{
    return [UIColor colorWithRed:1 green:90.0/255.0 blue:0 alpha:1];
}

+ (UILabel*)standardNavBarLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Cochin" size:24.0];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    return label;
}

@end
