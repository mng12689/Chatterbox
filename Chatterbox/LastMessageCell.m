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
                                                                   self.contentView.frame.size.width-kLeftMarginPadding,
                                                                   [@"FNSJ" sizeWithFont:[UIFont boldSystemFontOfSize:16]].height)];
        self.statusLabel.font = [UIFont fontWithName:@"Cochin" size:17];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [UIColor darkTextColor];
        //[self.statusLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        self.statusLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.statusLabel.layer.shadowRadius = 1.0;
        self.statusLabel.layer.shadowOpacity = 1;
        self.statusLabel.layer.masksToBounds = NO;
        
        float yOrigin = self.statusLabel.frame.origin.y+self.statusLabel.frame.size.height;
        self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLeftMarginPadding,
                                                                    yOrigin,
                                                                    self.contentView.frame.size.width-kLeftMarginPadding,
                                                                     self.contentView.frame.size.height-yOrigin)];
        self.messageLabel.numberOfLines = 2;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

    // Configure the view for the selected state
}

@end
