//
//  ParseCenter.h
//  Chatterbox
//
//  Created by Michael Ng on 12/10/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBConversation;
@class PFObject;

@interface ParseCenter : NSObject

- (PFObject*)parseObjectFromConversation:(CBConversation*)conversation;

@end
