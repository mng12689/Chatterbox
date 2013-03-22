//
//  ParseCenter.m
//  Chatterbox
//
//  Created by Michael Ng on 12/10/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "ParseCenter.h"
#import "CBCommons.h"
#import "SVProgressHUD.h"

@implementation ParseCenter

+ (void)loadConversationWithObjectId:(NSString*)objectId cachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(PFObject *object, NSError *error))handler{
    PFQuery *query = [PFQuery queryWithClassName:ParseConversationClassKey];
    query.cachePolicy = cachePolicy;
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        handler(object,error);
    }];
}

+ (void)loadAllUserConversationsWithCachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(NSArray *objects, NSError *error))handler{
    PFQuery *query = [[[PFUser currentUser] relationforKey:ParseUserConversationsKey]query];
    query.cachePolicy = cachePolicy;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        handler(objects,error);
    }];
}

+ (void)endConversation:(PFObject*)conversation handler:(void(^)(BOOL succeeded, NSError *error))handler{
    [conversation setObject:ParseConversationStatusEnded forKey:ParseConversationStatusKey];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        handler(succeeded,error);
    }];
}

+ (void)loadMessageWithObjectId:(NSString*)objectId cachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(PFObject *object, NSError *error))handler{
    PFQuery *query = [PFQuery queryWithClassName:ParseMessageClassKey];
    query.cachePolicy = cachePolicy;
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        handler(object,error);
    }];
}

+ (void)loadMessagesFromConversation:(PFObject*)conversation afterDate:(NSDate*)date cachePolicy:(PFCachePolicy)cachePolicy handler:(void(^)(NSArray *objects, NSError *error))handler{
    PFQuery *query = [[conversation relationforKey:ParseConversationMessagesKey]query];
    query.cachePolicy = cachePolicy;
    if (date) {
        [query whereKey:ParseObjectUpdatedAtKey greaterThan:date];
    }
    [query orderByAscending:ParseObjectUpdatedAtKey];
    [query setLimit:40];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        handler(objects,error);
    }];
}

+ (void)signUpWithUsernameInBackground:(NSString*)username password:(NSString*)password block:(void(^)(PFUser *user, NSError *error))block
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(user,error);
    }];

}

+ (void)logInWithUsernameInBackground:(NSString*)username password:(NSString*)password block:(void(^)(PFUser *user, NSError *error))block
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
        block(user,error);
    }];
}

+ (void)logout
{
    [PFUser logOut];
    [PFQuery clearAllCachedResults];
    [PFPush unsubscribeFromChannelInBackground:[NSString stringWithFormat:@"U%@",[PFUser currentUser].objectId] block:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeLogout object:self];
        [SVProgressHUD showSuccessWithStatus:@"Logged Out"];
    }];
}

+ (void)sendMessage:(PFObject*)message conversation:(PFObject*)conversation block:(void(^)(BOOL succeeded, NSError *error))block
{
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
            PFRelation *relation = [conversation relationforKey:ParseConversationMessagesKey];
            [relation addObject:message];
            [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:@[@(CBAPNTypeNewMessage),conversation.objectId,@"Increment"]
                                                                               forKeys:@[CBAPNTypeKey,CBAPNConvoIDKey,CBAPNBadgeKey]];
                    PFUser *user1 = [conversation valueForKey:ParseConversationUser1Key];
                    NSString *channelObjID = [user1.objectId isEqualToString:[PFUser currentUser].objectId] ? [[conversation valueForKey:ParseConversationUser2Key]objectId] : user1.objectId;
                    NSString *channelName = [NSString stringWithFormat:@"U%@",channelObjID];
                    [PFPush sendPushDataToChannelInBackground:channelName withData:dataDictionary];
                    //[[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeNewMessage object:currentVC userInfo:[NSDictionary dictionaryWithObject:self.conversation forKey:CBNotificationKeyConvoObj]];
                }
            }];
        }
        block(succeeded,error);
    }];
}

@end
