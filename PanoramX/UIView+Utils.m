//
//  UIView+Utils.m
//  PanoramX
//
//  Created by Adrien on 4/23/15.
//  Copyright (c) 2015 Adrien Casagrande. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (void)setX:(float)x {
    CGRect tmp = self.frame;
    tmp.origin.x = x;
    self.frame = tmp;
}

- (void)setY:(float)y {
    CGRect tmp = self.frame;
    tmp.origin.y = y;
    self.frame = tmp;
}

- (void)setWidth:(float)width {
    CGRect tmp = self.frame;
    tmp.size.width = width;
    self.frame = tmp;
}

- (void)setHeight:(float)height {
    CGRect tmp = self.frame;
    tmp.size.height = height;
    self.frame = tmp;
}

- (void)setPosition:(CGPoint)point {
    [self setX:point.x];
    [self setY:point.y];
}

@end
