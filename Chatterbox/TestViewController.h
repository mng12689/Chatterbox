//
//  TestViewController.h
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Conversation;

@interface TestViewController : UIViewController

-(id)initWithConversation:(Conversation*)conversation;

@end
