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
    [_actionView actionWith:gestureRecognizer];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        /// 使用layer transform.sacle不准确
        CGFloat xScale = [_actionView xScale];
        CGFloat yScale = [_actionView yScale];
        CGFloat changeXScale = gestureRecognizer.scale;
        CGFloat changeYScale = gestureRecognizer.scale;
        /// x
        if (xScale * changeXScale < [_actionView minScale]) changeXScale = [_actionView minScale] / xScale;
        if (xScale * changeXScale > [_actionView maxScale]) changeXScale = [_actionView maxScale] / xScale;
        /// y
        if (yScale * changeYScale < [_actionView minScale]) changeYScale = [_actionView minScale] / yScale;
        if (yScale * changeYScale > [_actionView maxScale]) changeYScale = [_actionView maxScale] / yScale;
        _actionView.transform = CGAffineTransformScale(_actionView.transform, changeXScale, changeYScale);
    } else {
        _actionView = nil;
    }
    gestureRecognizer.scale = 1.0; /// 恢复scale初始值
}
/// 旋转
- (void)rotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer {
    [_actionView actionWith:gestureRecognizer];
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
    [_actionView actionWith:gestureRecognizer];
    _actionView = nil;
}
/// 移动
- (void)panWith:(UIPanGestureRecognizer *)gestureRecognizer {
    [_actionView actionWith:gestureRecognizer];
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
    if (![self.gestureRecognizers containsObject:gestureRecognizer]) return YES;
    if (_actionView) return YES; /// 已找到有效视图 直接返回手势有效
    CGPoint actionPoint = [gestureRecognizer locationOfTouch:0 inView:self];
    if (gestureRecognizer.numberOfTouches >= 2) {
        CGPoint pointOne = [gestureRecognizer locationOfTouch:0 inView:self];
        CGPoint pointTow = [gestureRecognizer locationOfTouch:1 inView:self];
        actionPoint = CGPointMake((pointOne.x + pointTow.x) / 2.0, (pointOne.y + pointTow.y) / 2.0);
    }
    NSArray *subviews = self.subviews;
    for (NSInteger index = subviews.count - 1; index >= 0; --index) {
        UIView<CRGestureActionViewProtocol> *actionView = [subviews objectAtIndex:index];
        if (![actionView canAction]) continue; /// 视图不响应事件 跳过
        if (![actionView containsPoint:actionPoint]) continue; /// 视图不适合响应
        self.actionView = actionView;
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (![self.gestureRecognizers containsObject:gestureRecognizer] || ![self.gestureRecognizers containsObject:otherGestureRecognizer]) return NO;
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) return NO; /// 避免点击手势响应 (其它不需要同时响应e的手势 需要 主动添加)
    return  YES;
}

#pragma - mark Sets
- (void)setActionView:(UIView<CRGestureActionViewProtocol> *)actionView {
    _actionView = actionView;
    UIView<CRGestureActionViewProtocol> *lastActionView = self.subviews.lastObject;
    if (lastActionView == _actionView) return;
    [lastActionView actionWith:nil];
    if (actionView) [self bringSubviewToFront:actionView];
}

@end
