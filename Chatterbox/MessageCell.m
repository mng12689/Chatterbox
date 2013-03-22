//
//  MessageCell.m
//  Chatterbox
//
//  Created by Michael Ng on 12/16/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MessageCell.h"
#import <Parse/Parse.h>
#import "CBCommons.h"
#import "BlocksKit.h"
#import "ParseCenter.h"

#define kSpeechBubbleLeftPadding 10
#define kSpeechBubbleTopPadding 10
#define kSpeechBubbleMargin 3
#define kLabelFont [UIFont systemFontOfSize:13]
#define kImageViewSize 20

@interface MessageCell ()

@property (nonatomic,strong) UIImageView *speechBubble;
@property (nonatomic,strong) UIButton *failureButton;

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

-(void)setMessage:(PFObject*)message
{
    CGSize labelSize = [[message valueForKey:@"text"] sizeWithFont:kLabelFont constrainedToSize:CGSizeMake((self.frame.size.width-20)-2*kSpeechBubbleLeftPadding, CGFLOAT_MAX)];
    self.messageLabel.frame = CGRectMake(kSpeechBubbleLeftPadding, kSpeechBubbleTopPadding, labelSize.width, labelSize.height);
    self.messageLabel.text = [message valueForKey:@"text"];
    
    BOOL messageSentByUser = ([[[message objectForKey:ParseMessageSenderKey]objectId] isEqualToString:[PFUser currentUser].objectId]);
    float xOrigin = messageSentByUser ? (self.contentView.frame.origin.x+self.contentView.frame.size.width)-(self.messageLabel.frame.size.width+2*kSpeechBubbleLeftPadding)-kSpeechBubbleMargin : kSpeechBubbleMargin;
    UIImageView *speechBubble = [[UIImageView alloc]initWithFrame:CGRectMake(xOrigin,
                                                                            kSpeechBubbleMargin,
                                                                            self.messageLabel.frame.size.width+2*kSpeechBubbleLeftPadding,
                                                                            self.messageLabel.frame.size.height+2*kSpeechBubbleTopPadding)];
    NSString *imageName = messageSentByUser ? @"speech_bubble_gray_with_glow" : @"speech_bubble_gray";
    speechBubble.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:12];
    [speechBubble addSubview:self.messageLabel];
    [self.contentView addSubview:speechBubble];
    self.speechBubble = speechBubble;
}

+ (float)heightForCellWithText:(NSString*)text
{
    CGSize labelSize = [text sizeWithFont:kLabelFont constrainedToSize:CGSizeMake((320-20)-2*kSpeechBubbleLeftPadding, CGFLOAT_MAX)];
    float speechBubbleHeight = labelSize.height+2*kSpeechBubbleTopPadding;
    return speechBubbleHeight + 2*kSpeechBubbleMargin;
}

-(void)addFailureAlertWithBlock:(void(^)(id sender))block
{
    UIButton *failureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width-kImageViewSize-5, self.contentView.frame.size.height-kImageViewSize-kSpeechBubbleTopPadding, kImageViewSize, kImageViewSize)];
    failureButton.backgroundColor = [UIColor clearColor];
    [failureButton setBackgroundImage:[UIImage imageNamed:@"exclamation"] forState:UIControlStateNormal];
    failureButton.alpha = 0;
    [failureButton addEventHandler:^(id sender) {
        block(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    self.failureButton = failureButton;
    [self.contentView addSubview:self.failureButton];
    [UIView animateWithDuration:.3 animations:^{
        self.speechBubble.center = CGPointMake(self.speechBubble.center.x-kImageViewSize-kSpeechBubbleMargin, self.speechBubble.center.y);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.failureButton.alpha = 1;
        }];
    }];
}

-(void)removeFailureAlert
{
    [UIView animateWithDuration:.3 animations:^{
        self.failureButton.alpha = 0;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            [self.failureButton removeFromSuperview];
            self.failureButton = nil;
            self.speechBubble.center = CGPointMake(self.speechBubble.center.x+kImageViewSize+kSpeechBubbleMargin, self.speechBubble.center.y);
        }];
    }];
}

@end
