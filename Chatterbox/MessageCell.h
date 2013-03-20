//
//  MessageCell.h
//  Chatterbox
//
//  Created by Michael Ng on 12/16/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (strong,nonatomic) UILabel *messageLabel;

-(void)setMessage:(NSString*)message;
+ (float)heightForCellWithText:(NSString*)text;

@end
