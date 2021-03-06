//
//  LastMessageCell.m
//  Chatterbox
//
//  Created by Michael Ng on 12/18/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "LastMessageCell.h"
#import <QuartzCore/QuartzCore.h>

#define kLeftMarginPadding 20
#define kTopMarginPadding 5

@implementation LastMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLeftMarginPadding,
                                                                   kTopMarginPadding,
                                                                   self.contentView.frame.size.width-(2*kLeftMarginPadding),
                                                                   [@"FNSJ" sizeWithFont:[UIFont boldSystemFontOfSize:16]].height)];
        self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.statusLabel.font = [UIFont fontWithName:@"Cochin" size:17];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [UIColor darkTextColor];
        self.statusLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.statusLabel.layer.shadowRadius = 1.0;
        self.statusLabel.layer.shadowOpacity = 1;
        self.statusLabel.layer.masksToBounds = NO;
        
        float yOrigin = self.statusLabel.frame.origin.y+self.statusLabel.frame.size.height;
        self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLeftMarginPadding,
                                                                    yOrigin,
                                                                    self.contentView.frame.size.width-(2*kLeftMarginPadding),
                                                                     self.contentView.frame.size.height-yOrigin)];
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.messageLabel.numberOfLines = 2;
        self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.messageLabel.font = [UIFont systemFontOfSize:13];
        self.messageLabel.textColor = [UIColor darkTextColor];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    /*UIView *selectedView = [[UIView alloc]initWithFrame:self.frame];
    selectedView.backgroundColor = [UIColor colorWithRed:1 green:150.0/255.0 blue:0 alpha:.3];
    
    self.selectedBackgroundView = selectedView;*/
}

- (void)setMessageText:(NSString*)text
{
    self.messageLabel.text = text;
    float yOrigin = self.statusLabel.frame.origin.y+self.statusLabel.frame.size.height;
    CGSize labelSize = [self.messageLabel sizeThatFits:CGSizeMake(self.contentView.frame.size.width-(2*kLeftMarginPadding),
                                               self.contentView.frame.size.height-yOrigin)];
    self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, labelSize.width, labelSize.height);
}

@end
