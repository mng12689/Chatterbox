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
+ (NSURL*)applicationDocumentsDirectory;

+ (NSArray*)allConversations;
+ (NSArray*)allTopics;

+ (Conversation*)createConversationFromParseObject:(PFObject*)object;
+ (Message*)createMessageFromParseObject:(PFObject*)object andConversation:(Conversation*)conversation;

//+ (id) createNewAttribute:(NSString*)attributeType;
//+ (void) deleteObject:(NSManagedObject*)object;

@end
