//
//  ChatterboxDataStore.h
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;
@class CBConversation;
@class CBMessage;

@interface ChatterboxDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (readonly, strong, nonatomic) NSManagedObjectModel *model;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (void)saveContext:(NSError**)error;
+ (void)refreshObject:(id)object mergeChanges:(BOOL)merge;
+ (NSURL*)applicationDocumentsDirectory;

+ (NSArray*)allTopics;
+ (NSArray*)allConversations;

+ (CBConversation*)conversationWithParseID:(NSString*)parseID;
+ (CBMessage*)messageWithParseID:(NSString*)parseID;

+ (CBConversation*)createConversationFromParseObject:(PFObject*)object error:(NSError*)error;
+ (CBMessage*)createMessageFromParseObject:(PFObject*)object andConversation:(CBConversation*)conversation error:(NSError*)error;

+ (void)updateMessage:(CBMessage*)message withParseObjectDataAfterSave:(PFObject*)parseObject error:(NSError*)error;
+ (void)updateConversationWithParseObject:(PFObject*)object error:(NSError*)error;

//+ (id) createNewAttribute:(NSString*)attributeType;
//+ (void) deleteObject:(NSManagedObject*)object;

@end
