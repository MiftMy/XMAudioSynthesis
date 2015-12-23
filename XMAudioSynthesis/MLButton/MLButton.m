//
//  MLButton.m
//  GCDTemp
//
//  Created by molon on 5/21/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLButton.h"
#import "UIView+ColorPointAndMask.h"
@interface MLButton()
@property (nonatomic,assign) CGPoint innerCenter;
@end
@implementation MLButton


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    if (!self.isIgnoreTouchInTransparentPoint) {
        if ([self.delegate respondsToSelector:@selector(buttonDidPress:)]) {
            [self.delegate buttonDidPress:[self directionFromPoint:point]];
        }
        return result;
    }
    
    if (result) {
        BOOL isT = [self isTansparentOfPoint:point];
        if (!isT && [self.delegate respondsToSelector:@selector(buttonDidPress:)]) {
            [self.delegate buttonDidPress:[self directionFromPoint:point]];
        }
        return !isT;
    }
    return NO;
}

- (CGPoint)innerCenter{
    _innerCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height /2);
    return _innerCenter;
}

//检测按钮按下的方向
- (MLButtonDirection)directionFromPoint:(CGPoint)point{
    CGPoint centerTem = self.innerCenter;
    if (point.x < centerTem.x) {
        if ([self valueFormlineA:point.x] < point.y && [self valueFromLineB:point.x] > point.y  ) {
            return MLButtonDirectionLeft;
        }
    }else if (point.x > centerTem.x){
        if ([self valueFormlineA:point.x] > point.y && [self valueFromLineB:point.x] < point.y) {
            return MLButtonDirectionRight;
        }
    }
    if (point.y > centerTem.y) {
        if ([self valueFormlineA:point.x] < point.y && [self valueFromLineB:point.x] < point.y) {
            return MLButtonDirectionBottom;
        }
    }else if (point.y < centerTem.y){
        if ([self valueFormlineA:point.x] > point.y && [self valueFromLineB:point.x] > point.y) {
            return MLButtonDirectionTop;
        }
    }
    return MLButtonDirectionNo;
}

- (NSInteger)valueFormlineA:(NSInteger)value{
    CGPoint tem = self.innerCenter;
    return value - tem.x + tem.y;
}

- (NSInteger)valueFromLineB:(NSInteger)value{
    CGPoint tem = self.innerCenter;
    return -value + tem.x + tem.y;
}
//lineA
// Ya = (x - self.center.x) + self.center.y;

//lineB
// Yb = -(x - self.center.x) + self.center.y;
@end
