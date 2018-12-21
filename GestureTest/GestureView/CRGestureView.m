//
//  CRGestureView.m
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "CRGestureView.h"

@interface CRGestureView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView<CRGestureActionViewProtocol> *actionView;

@end

@implementation CRGestureView

/// 获取缩放大小
+ (CGFloat)xscaleWith:(UIView *)actionView {
    CGAffineTransform t = actionView.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

+ (CGFloat)yscaleWith:(UIView *)actionView {
    CGAffineTransform t = actionView.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}
/// x == y
+ (CGFloat)scaleWith:(UIView *)actionView {
    return ([self yscaleWith:actionView] + [self xscaleWith:actionView]) / 2.0;
}
/// 设置anchorPoint
+ (void)anchorPoint:(CGPoint)anchorPoint with:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    CGPoint position = view.layer.position;
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}
/// 判断点 是否在视图上
+ (BOOL)containsPoint:(CGPoint)point with:(UIView<CRGestureActionViewProtocol> *)actionView {
    CGFloat rotation = [[actionView.layer valueForKeyPath:@"transform.rotation"] floatValue];
    CGFloat tanRotation = fabs(tan(rotation));
    CGFloat tmp = (actionView.frame.size.height - actionView.frame.size.width * tanRotation) / (1 - tanRotation * tanRotation);
    /// 真实宽高
    CGFloat realW = sqrt(pow(actionView.frame.size.width - tmp * tanRotation, 2.0) + pow(actionView.frame.size.height - tmp, 2.0));
    CGFloat realH = sqrt(pow(tmp, 2.0) + pow(tmp * tanRotation, 2.0));
    /// 中心距离
    CGPoint centerPoint = CGPointMake(actionView.frame.origin.x + actionView.frame.size.width / 2.0, actionView.frame.origin.y + actionView.frame.size.height / 2.0);
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
    rotationPointToCenter -= rotation;
    /// 距离
    CGFloat distanceW = distancePointToCenter * cos(rotationPointToCenter);
    CGFloat distanceH = distancePointToCenter * sin(rotationPointToCenter);
    if ((fabs(distanceW) <= realW / 2.0 && fabs(distanceH) <= realH / 2.0)) {
        [self anchorPoint:CGPointMake((realW / 2.0 + distanceW) / realW, (realH / 2.0 + distanceH) / realH) with:actionView];
        return YES;
    }
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configGestures];
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if ([view conformsToProtocol:@protocol(CRGestureActionViewProtocol)]) {
        [super addSubview:view];
    }
}

#pragma mark - GestureRecognizers
/// 缩放
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (![_actionView actionWith:gestureRecognizer]) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        /// 使用layer transform.sacle不准确
        CGFloat scale = [CRGestureView scaleWith:_actionView];
        CGFloat changeScale = 1.0 + gestureRecognizer.scale - scale;
        if (scale * changeScale < [_actionView minScale]) changeScale = [_actionView minScale] / scale;
        if (scale * changeScale > [_actionView maxScale]) changeScale = [_actionView maxScale] / scale;
        _actionView.transform = CGAffineTransformScale(_actionView.transform, changeScale, changeScale);
    } else {
        _actionView = nil;
    }
    gestureRecognizer.scale = [CRGestureView scaleWith:_actionView];
}
/// 旋转
- (void)rotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer {
    if (![_actionView actionWith:gestureRecognizer]) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gestureRecognizer.rotation = [[_actionView.layer valueForKeyPath:@"transform.rotation"] floatValue];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat rotation = [[_actionView.layer valueForKeyPath:@"transform.rotation"] floatValue];
        _actionView.transform = CGAffineTransformRotate(_actionView.transform, gestureRecognizer.rotation - rotation);
    } else {
        _actionView = nil;
    }
}
/// 点击
- (void)tapWith:(UITapGestureRecognizer *)gestureRecognizer {
    if (![_actionView actionWith:gestureRecognizer]) return;
    _actionView = nil;
}
/// 移动
- (void)panWith:(UIPanGestureRecognizer *)gestureRecognizer {
    if (![_actionView actionWith:gestureRecognizer]) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint changePoint = [gestureRecognizer translationInView:gestureRecognizer.view];
        _actionView.center = CGPointMake(_actionView.center.x + changePoint.x, _actionView.center.y + changePoint.y);
    } else {
        _actionView = nil;
    }
    [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view]; /// 调整偏移量
}
/// 手势
- (void)configGestures {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    rotation.delegate = self;
    [self addGestureRecognizer:rotation];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWith:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWith:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![self.gestureRecognizers containsObject:gestureRecognizer]) {
        return YES;
    }
    CGPoint actionPoint = [gestureRecognizer locationOfTouch:0 inView:self];
    if (gestureRecognizer.numberOfTouches >= 2) {
        CGPoint pointOne = [gestureRecognizer locationOfTouch:0 inView:self];
        CGPoint pointTow = [gestureRecognizer locationOfTouch:1 inView:self];
        actionPoint = CGPointMake((pointOne.x + pointTow.x) / 2.0, (pointOne.y + pointTow.y) / 2.0);
    }
    if (_actionView) return YES;
    NSArray *subviews = self.subviews;
    for (NSInteger index = subviews.count - 1; index >= 0; --index) {
        UIView<CRGestureActionViewProtocol> *actionView = [subviews objectAtIndex:index];
        if (![actionView actionWith:gestureRecognizer]) continue; /// 手势状态 UIGestureRecognizerStatePossible 不工作 则跳过
        if ([CRGestureView containsPoint:actionPoint with:actionView]) {
            _actionView = actionView;
            UIView<CRGestureActionViewProtocol> *lastActionView = subviews.lastObject;
            if (lastActionView != actionView) {
                [lastActionView actionWith:nil];
                [self bringSubviewToFront:actionView];
            }
            break;
        }
    }
    return _actionView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.gestureRecognizers containsObject:gestureRecognizer] && [self.gestureRecognizers containsObject:otherGestureRecognizer]) {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) return NO; /// 避免点击手势响应
        return  YES;
    }
    return NO;
}

@end
