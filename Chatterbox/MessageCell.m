//
//  MessageCell.m
//  Chatterbox
//
//  Created by Michael Ng on 12/16/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MessageCell.h"
#import "CBMessage.h"
#import <Parse/Parse.h>

#define kSpeechBubbleLeftPadding 10
#define kSpeechBubbleTopPadding 10
#define kSpeechBubbleMargin 3
#define kLabelFont [UIFont systemFontOfSize:13]

@interface MessageCell ()

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.messageLabel = [UILabel new];
        self.messageLabel.font = kLabelFont;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.shadowColor = [UIColor colorWithWhite:1 alpha:.5];
        self.messageLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(CBMessage*)message
{
    CGSize labelSize = [message.text sizeWithFont:kLabelFont constrainedToSize:CGSizeMake((self.frame.size.width/2+20)-2*kSpeechBubbleLeftPadding, CGFLOAT_MAX)];
    self.messageLabel.frame = CGRectMake(kSpeechBubbleLeftPadding, kSpeechBubbleTopPadding, labelSize.width, labelSize.height);
    self.messageLabel.text = message.text;
    
    BOOL messageSentByUser = [message.senderID isEqualToString:[PFUser currentUser].objectId];
    float xOrigin = messageSentByUser ? (self.contentView.frame.origin.x+self.contentView.frame.size.width)-(self.messageLabel.frame.size.width+2*kSpeechBubbleLeftPadding)-kSpeechBubbleMargin : kSpeechBubbleMargin;
    UIImageView *speechBubble = [[UIImageView alloc]initWithFrame:CGRectMake(xOrigin,
                                                                            kSpeechBubbleMargin,
                                                                            self.messageLabel.frame.size.width+2*kSpeechBubbleLeftPadding,
                                                                            self.messageLabel.frame.size.height+2*kSpeechBubbleTopPadding)];
    NSString *imageName = messageSentByUser ? @"speech_bubble_gray_with_glow" : @"speech_bubble_orange";
    speechBubble.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:12];//resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [speechBubble addSubview:self.messageLabel];
    //speechBubble.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:speechBubble];
}

@end
