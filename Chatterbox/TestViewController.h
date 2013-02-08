//
//  TestViewController.h
//  Chatterbox
//
//  Created by Michael Ng on 11/24/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CBConversation;

@interface TestViewController : UIViewController

@property (strong,nonatomic,readonly) CBConversation *conversation;
-(id)initWithConversation:(CBConversation*)conversation;

@end
