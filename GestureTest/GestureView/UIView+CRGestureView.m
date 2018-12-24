//
//  UIView+CRGestureView.m
//  GestureTest
//
//  Created by Craig on 2018/12/24.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "UIView+CRGestureView.h"

@implementation UIView (CRGestureView)

- (CGFloat)xScale {
    CGAffineTransform t = self.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}
- (CGFloat)yScale {
    CGAffineTransform t = self.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}

- (void)anchorWith:(CGPoint)anchorPoint {
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x,
                                   self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x,
                                   self.bounds.size.height * self.layer.anchorPoint.y);
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    CGPoint position = self.layer.position;
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

/// 获取旋转后的真实大小
- (CGSize)rotationSize {
    CGFloat tanRotation = fabs(tan([[self.layer valueForKeyPath:@"transform.rotation"] floatValue]));
    CGFloat tmp = (self.frame.size.height - self.frame.size.width * tanRotation) / (1 - tanRotation * tanRotation);
    /// 旋转后宽高 旋转时 视觉大小不变 但frame在改变
    CGFloat rotationW = sqrt(pow(self.frame.size.width - tmp * tanRotation, 2.0) + pow(self.frame.size.height - tmp, 2.0));
    CGFloat rotationH = sqrt(pow(tmp, 2.0) + pow(tmp * tanRotation, 2.0));
    return CGSizeMake(rotationW, rotationH);
}
- (CGSize)realSize {
    CGSize rotationSize = [self rotationSize];
    CGSize realSize = CGSizeMake(rotationSize.width / [self xScale], rotationSize.height / [self yScale]);
    return realSize;
}
- (BOOL)containsPoint:(CGPoint)point {
    CGSize rotationSize = [self rotationSize];
    /// 中心距离
    CGPoint centerPoint = CGPointMake(self.frame.origin.x + self.frame.size.width / 2.0, self.frame.origin.y + self.frame.size.height / 2.0);
    CGFloat distancePointToCenter = sqrt(pow(point.x - centerPoint.x, 2.0) + pow(point.y - centerPoint.y, 2.0));
    /// 相对角度  所有角度为顺时针
    CGFloat rotationPointToCenter = M_PI_2;
    if (point.x == centerPoint.x) {
        if (point.y >= centerPoint.y) rotationPointToCenter = M_PI_2 * 3;
    } else {
        /// 象限为逆时针
        if (point.y >= centerPoint.y && point.x >= centerPoint.x) { /// 第一逆象限
            rotationPointToCenter = atan((point.y - centerPoint.y) / (point.x - centerPoint.x));
        } else if (point.y >= centerPoint.y && point.x < centerPoint.x) { /// 第二逆象限
            rotationPointToCenter = M_PI + atan((point.y - centerPoint.y) / (point.x - centerPoint.x));
        } else if (point.y < centerPoint.y && point.x < centerPoint.x) { /// 第三逆象限
            rotationPointToCenter = M_PI + atan((point.y - centerPoint.y) / (point.x - centerPoint.x));
        } else {
            rotationPointToCenter = 2 * M_PI + atan((point.y - centerPoint.y) / (point.x - centerPoint.x));
        }
    }
    rotationPointToCenter -= [[self.layer valueForKeyPath:@"transform.rotation"] floatValue];
    /// 距离
    CGFloat distanceW = distancePointToCenter * cos(rotationPointToCenter);
    CGFloat distanceH = distancePointToCenter * sin(rotationPointToCenter);
    if ((fabs(distanceW) > rotationSize.width / 2.0 || fabs(distanceH) > rotationSize.height / 2.0)) return NO;
    [self anchorWith:CGPointMake((rotationSize.width / 2.0 + distanceW) / rotationSize.width, (rotationSize.height / 2.0 + distanceH) / rotationSize.height)];
    return YES;
}

@end
