//
//  ChatterboxDataStore.m
//  Chatterbox
//
//  Created by Michael Ng on 11/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "ChatterboxDataStore.h"
#import "Conversation.h"
#import "Message.h"
#import <Parse/Parse.h>

NSManagedObjectContext *_context;
NSManagedObjectModel *_model;
NSPersistentStoreCoordinator *_psc;

@interface ChatterboxDataStore ()
+(NSManagedObjectContext*)context;
+(NSManagedObjectModel*)model;
+(NSPersistentStoreCoordinator*)psc;
@end

@implementation ChatterboxDataStore

/*+ (NSArray*)fetchEntity:(NSString*)entity sortBy:(NSString*)sortBy withPredicate:(NSPredicate *)predicate propertiesToFetch:(NSArray*)propertiesToFetch
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [[ChatterboxDataStore model].entitiesByName objectForKey:entity];
    
    BOOL ascending = YES;
    if ([sortBy isEqualToString:@"date"] || [sortBy isEqualToString:@"weightOZ"])
        ascending = NO;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortBy ascending:ascending selector:nil];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    if (propertiesToFetch)
        fetchRequest.propertiesToFetch = propertiesToFetch;
    
    if (predicate)
        fetchRequest.predicate = predicate;
    
    NSError *error;
    NSArray *results = [[ProAnglerDataStore context] executeFetchRequest:fetchRequest error:&error];
    if (!results) {
        NSLog(@"error");
    }
    return results;
}*/

+ (Conversation*)createConversationFromParseObject:(PFObject*)object error:(NSError*)error
{
    Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:[self context]];
    conversation.parseObjectID = object.objectId;
    conversation.createdAt = object.createdAt;
    conversation.updatedAt = object.updatedAt;
    conversation.status = [object valueForKey:@"status"];
    conversation.topic = [object valueForKey:@"topic"];
    conversation.user1ID = [[object valueForKey:@"user1"]objectId];
    conversation.user2ID = [[object valueForKey:@"user2"]objectId];
    conversation.messages = [object valueForKey:@"messages"];
    
    [ChatterboxDataStore saveContext:&error];
    
    return conversation;
}

+ (void)updateConversationWithParseObject:(PFObject*)object error:(NSError*)error
{
    Conversation *conversation = [ChatterboxDataStore conversationWithParseID:object.objectId];
    conversation.updatedAt = object.updatedAt;
    conversation.status = [object valueForKey:@"status"];
    conversation.messages = [object valueForKey:@"messages"];
    conversation.user2ID = [object valueForKey:@"user2.id"];
    
    [ChatterboxDataStore saveContext:&error];
}

+ (Message*)createMessageFromParseObject:(PFObject *)object andConversation:(Conversation*)conversation error:(NSError*)error
{
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:[self context]];
    message.parseObjectID = object.objectId;
    message.createdAt = object.createdAt;
    message.updatedAt = object.updatedAt;
    message.senderID = [[object valueForKey:@"sender"]objectId];
    message.text = [object valueForKey:@"text"];
    message.conversation = conversation;
    
    [ChatterboxDataStore saveContext:&error];
    
    return message;
}

+ (NSArray*) allConversations
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [[ChatterboxDataStore model].entitiesByName objectForKey:@"Conversation"];
    NSError *error;
    return [[self context] executeFetchRequest:fetchRequest error:&error];
}

+ (Conversation*)conversationWithParseID:(NSString*)parseID;
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [[ChatterboxDataStore model].entitiesByName objectForKey:@"Conversation"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parseObjectID like %@",parseID];
    NSError *error;
    return [[[self context] executeFetchRequest:fetchRequest error:&error]lastObject];
}

+ (Message*)messageWithParseID:(NSString*)parseID;
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [[ChatterboxDataStore model].entitiesByName objectForKey:@"Message"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parseObjectID like %@",parseID];
    NSError *error;
    return [[[self context] executeFetchRequest:fetchRequest error:&error]lastObject];
}

+ (void)updateMessage:(Message*)message withParseObjectDataAfterSave:(PFObject*)parseObject error:(NSError*)error
{
    message.createdAt = parseObject.createdAt;
    message.updatedAt = parseObject.updatedAt;
    message.parseObjectID = parseObject.objectId;
    
    [ChatterboxDataStore saveContext:&error];
}
+ (void) deleteObject:(NSManagedObject*)object
{
    [[self context] deleteObject:object];
    [self saveContext:nil];
}

+ (void)refreshObject:(id)object mergeChanges:(BOOL)merge
{
    [[self context]refreshObject:object mergeChanges:merge];
}

+ (void)saveContext:(NSError**)error
{
    NSManagedObjectContext *context = [self context];
    if (context != nil) {
        if ([context hasChanges] && ![context save:error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
+ (NSManagedObjectContext *)context
{
    if (_context != nil) {
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
+ (NSManagedObjectModel *)model
{
    if (_model != nil) {
        return _model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Chatterbox" withExtension:@"momd"];
    _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _model;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
+ (NSPersistentStoreCoordinator *)psc
{
    if (_psc != nil) {
        return _psc;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Chatterbox.sqlite"];
    
    NSError *error = nil;
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _psc;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
