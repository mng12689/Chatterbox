//
//  MessageCell.m
//  Chatterbox
//
//  Created by Michael Ng on 12/16/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MessageCell.h"
#import "Message.h"

#define kSpeechBubblePadding 5
#define kSpeechBubbleMargin 5
#define kLabelFont [UIFont systemFontOfSize:12]

@interface MessageCell ()

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.messageLabel = [UILabel new];
        self.messageLabel.font = kLabelFont;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(Message*)message
{
    CGSize labelSize = [message.text sizeWithFont:kLabelFont constrainedToSize:CGSizeMake((self.frame.size.width/2)-2*kSpeechBubblePadding, CGFLOAT_MAX)];
    self.messageLabel.frame = CGRectMake(kSpeechBubblePadding, kSpeechBubblePadding, labelSize.width, labelSize.height);
    self.messageLabel.text = message.text;
    
    UIImageView *speechBubble = [[UIImageView alloc]initWithFrame:CGRectMake(kSpeechBubbleMargin,
                                                                            0,
                                                                            self.messageLabel.frame.size.width+2*kSpeechBubblePadding,
                                                                            self.messageLabel.frame.size.height+2*kSpeechBubblePadding)];
    speechBubble.image = [[UIImage imageNamed:@""] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [speechBubble addSubview:self.messageLabel];
    [self.contentView addSubview:speechBubble];
}

@end
