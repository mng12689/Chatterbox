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
    CBAPNTypeNewMessage
}CBAPNType;

extern NSString* const CBAPNTypeKey;
extern NSString* const CBAPNConvoIDKey;
extern NSString* const CBAPNSenderIDKey;
extern NSString* const CBAPNAlertKey;
extern NSString* const CBAPNBadgeKey;

extern NSString* const CBNotificationTypeAPNReceived;
extern NSString* const CBNotificationTypeNewMessage;
extern NSString* const CBNotificationTypeNewConversation;

extern NSString* const ParseConversationClassKey;
extern NSString* const ParseConversationObjectIDKey;
extern NSString* const ParseConversationCreatedAtKey;
extern NSString* const ParseConversationUpdatedAtKey;
extern NSString* const ParseConversationStatusKey;
extern NSString* const ParseConversationTopicKey;
extern NSString* const ParseConversationUser1Key;
extern NSString* const ParseConversationUser2Key;
extern NSString* const ParseConversationMessagesKey;

@interface CBCommons : NSObject

@end
