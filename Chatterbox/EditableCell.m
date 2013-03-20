//
//  EditableCell.m
//  Chatterbox
//
//  Created by Michael Ng on 2/8/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import "EditableCell.h"

#define kTextInset 10

@implementation EditableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc]initWithFrame:CGRectMake(kTextInset, 0, self.contentView.frame.size.width-kTextInset, self.contentView.frame.size.height)];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
