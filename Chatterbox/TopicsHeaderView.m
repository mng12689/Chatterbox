//
//  TopicsHeaderView.m
//  Chatterbox
//
//  Created by Michael Ng on 2/4/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import "TopicsHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#define kLeftMarginPadding 20

@implementation TopicsHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(kLeftMarginPadding, 0, self.frame.size.width, self.frame.size.height);
        label.font = [UIFont fontWithName:@"Cochin" size:18];
        label.textColor = [UIColor lightGrayColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.backgroundColor = [UIColor clearColor];
        self.label = label;
        [self addSubview:label];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.frame = self.frame;
    //layer.colors = @[
}

@end
