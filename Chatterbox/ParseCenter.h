//
//  ParseCenter.h
//  Chatterbox
//
//  Created by Michael Ng on 12/10/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Conversation;
@class PFObject;

@interface ParseCenter : NSObject

- (PFObject*)parseObjectFromConversation:(Conversation*)conversation;

@end
