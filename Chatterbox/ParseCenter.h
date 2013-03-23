//
//  ParseCenter.h
//  Chatterbox
//
//  Created by Michael Ng on 12/10/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseCenter : NSObject

//authentication methods
+ (void)signUpWithUsernameInBackground:(NSString*)username password:(NSString*)password block:(void(^)(PFUser *user, NSError *error))block;
+ (void)logInWithUsernameInBackground:(NSString*)username password:(NSString*)password block:(void(^)(PFUser *user, NSError *error))block;
+ (void)logout;

//manage conversations methods
+ (void)loadAllUserConversationsWithCachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(NSArray *objects, NSError *error))handler;
+ (void)loadConversationWithObjectId:(NSString *)objectId cachePolicy:(PFCachePolicy)cachePolicy handler:(void (^)(PFObject *, NSError *))handler;
+ (void)endConversation:(PFObject*)conversation handler:(void(^)(BOOL succeeded, NSError *error))handler;

//manage messages methods
+ (void)loadMessageWithObjectId:(NSString*)objectId cachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(PFObject *object, NSError *error))handler;
+ (void)loadMessagesFromConversation:(PFObject*)conversation afterDate:(NSDate*)date cachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(NSArray *objects, NSError *error))handler;
+ (void)sendMessage:(PFObject*)message conversation:(PFObject*)conversation block:(void(^)(BOOL succeeded, NSError *error))block;

@end
