//
//  Message.h
//  Chatterbox
//
//  Created by Michael Ng on 2/8/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBConversation;

@interface CBMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * parseObjectID;
@property (nonatomic, retain) NSString * senderID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) CBConversation *conversation;

@end
