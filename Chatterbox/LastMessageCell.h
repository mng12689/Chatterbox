//
//  LastMessageCell.h
//  Chatterbox
//
//  Created by Michael Ng on 12/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastMessageCell : UITableViewCell

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *messageLabel;
- (void)setMessageText:(NSString*)text;

@end
