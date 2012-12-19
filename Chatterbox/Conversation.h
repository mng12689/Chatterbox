//
//  Conversation.h
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Message;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * parseObjectID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSString * user1ID;
@property (nonatomic, retain) NSString * user2ID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *messages;

- (Message*)lastMessage;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
