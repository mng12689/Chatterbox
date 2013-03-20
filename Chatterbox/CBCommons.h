//
//  CBCommons.h
//  Chatterbox
//
//  Created by Michael Ng on 1/21/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CBAPNTypeConversationStarted,
    CBAPNTypeNewMessage,
    CBAPNTypeConversationEnded
}CBAPNType;

extern NSString* const CBAPNTypeKey;
extern NSString* const CBAPNConvoIDKey;
extern NSString* const CBAPNAlertKey;
extern NSString* const CBAPNBadgeKey;

extern NSString* const CBNotificationTypeAPNActiveConvo;
extern NSString* const CBNotificationTypeAPNEndedConvo;
extern NSString* const CBNotificationTypeAPNNewMessage;
extern NSString* const CBNotificationTypeNewMessage;
extern NSString* const CBNotificationTypeNewConversation;
extern NSString* const CBNotificationTypeUserLoaded;
extern NSString* const CBNotificationTypeLogout;
extern NSString* const CBNotificationTypeEndedConvo;

extern NSString* const CBNotificationKeyConvoObj;
extern NSString* const CBNotificationKeyConvoId;

extern NSString* const ParseObjectIDKey;
extern NSString* const ParseObjectCreatedAtKey;
extern NSString* const ParseObjectUpdatedAtKey;

extern NSString* const ParseConversationClassKey;
extern NSString* const ParseConversationStatusKey;
extern NSString* const ParseConversationTopicKey;
extern NSString* const ParseConversationUser1Key;
extern NSString* const ParseConversationUser2Key;
extern NSString* const ParseConversationMessagesKey;

extern NSString* const ParseConversationStatusPending;
extern NSString* const ParseConversationStatusActive;
extern NSString* const ParseConversationStatusEnded;

extern NSString* const ParseMessageClassKey;
extern NSString* const ParseMessageSenderKey;
extern NSString* const ParseMessageTextKey;
extern NSString* const ParseMessageConversationKey;

extern NSString* const ParseUserClassKey;
extern NSString* const ParseUserConversationsKey;

@interface CBCommons : NSObject

+ (UIColor*)chatterboxOrange;

@end
