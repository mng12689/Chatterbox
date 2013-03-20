//
//  TestViewController.h
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class CBConversation;

@interface TestViewController : UIViewController

@property (strong,nonatomic,readonly) PFObject *conversation;
-(id)initWithConversation:(PFObject*)conversation;

@end
