//
//  ZRoundedView.m
//  InputPhoneNumber
//
//  Created by Zelic on 7/19/14.
//  Copyright (c) 2014 Zelic. All rights reserved.
//

#import "ZRoundedView.h"

@implementation ZRoundedView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
    }
    return self;
}


@end
