//
//  UIButton+Rounded.m
//  InputPhoneNumber
//
//  Created by Zelic on 7/19/14.
//  Copyright (c) 2014 Zelic. All rights reserved.
//

#import "UIButton+Rounded.h"

@implementation UIButton (Rounded)

- (void)applyRoundedCorner:(NSInteger)radius
{
    self.layer.cornerRadius = radius;
    [self clipsToBounds];
}

@end
