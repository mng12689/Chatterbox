//
//  ChatterboxDataStore.h
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;
@class Conversation;
@class Message;

@interface ChatterboxDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (readonly, strong, nonatomic) NSManagedObjectModel *model;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (void)saveContext:(NSError**)error;
+ (void)refreshObject:(id)object mergeChanges:(BOOL)merge;
+ (NSURL*)applicationDocumentsDirectory;

+ (NSArray*)allTopics;

+ (NSArray*)allConversations;
+ (Conversation*)conversationWithParseID:(NSString*)parseID;
+ (Conversation*)createConversationFromParseObject:(PFObject*)object;

+ (Message*)messageWithParseID:(NSString*)parseID;
+ (Message*)createMessageFromParseObject:(PFObject*)object andConversation:(Conversation*)conversation;
+ (void)updateMessage:(Message*)message withParseObjectDataAfterSave:(PFObject*)parseObject;

//+ (id) createNewAttribute:(NSString*)attributeType;
//+ (void) deleteObject:(NSManagedObject*)object;

@end
