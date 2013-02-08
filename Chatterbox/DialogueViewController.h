//
//  DialogueViewController.h
//  Chatterbox
//
//  Created by Michael Ng on 11/23/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CBConversation;

@interface DialogueViewController : UIViewController

-(id)initWithConversation:(CBConversation*)conversation;

@end
