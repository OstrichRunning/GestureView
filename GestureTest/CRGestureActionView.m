//
//  CRGestureActionView.m
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "CRGestureActionView.h"
#import "UIView+CRGestureView.h"

@interface CRGestureActionView ()

@property (nonatomic, strong) UIView *childView;

@end

@implementation CRGestureActionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.layer.borderColor = UIColor.blackColor.CGColor;
    _childView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width - 20.0, self.frame.size.height - 20.0)];
    _childView.backgroundColor = UIColor.yellowColor;
    [self addSubview:_childView];
}

- (CGFloat)maxScale {
    return 5.0;
}
- (CGFloat)minScale {
    return 0.5;
}

#pragma mark - CRGestureActionViewProtocol
- (BOOL)canBeAction {
    return self.userInteractionEnabled;
}
- (void)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(borderHidden) object:nil];
            CRGestureActionView *lastView = self.superview.subviews.lastObject;
            /// 还原旧视图状态
            if (lastView != self) lastView.layer.borderWidth = 0.0;
            [self.superview bringSubviewToFront:self];
            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) return; /// 点击手势 修改borderWidth在后面执行 为了得到点击第二次才变大的效果
            self.layer.borderWidth = 3.0;
        }
            break;
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gestureRecognizer;
                CGFloat xScale = [self xScale];
                CGFloat yScale = [self yScale];
                CGFloat scale = pinch.scale;
                /// x
                if (xScale * scale < [self minScale]) scale = [self minScale] / xScale;
                if (xScale * scale > [self maxScale]) scale = [self maxScale] / xScale;
                /// y
                if (yScale * scale < [self minScale]) scale = [self minScale] / yScale;
                if (yScale * scale > [self maxScale]) scale = [self maxScale] / yScale;
                /// 设置新缩放
                pinch.scale = scale;
            }
        }
            break;
        default: {
            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) { /// UITapGestureRecognizer UIGestureRecognizerStateEnded
                if (self.layer.borderWidth) { /// 以 borderWidth 为标记， 在激活状态下 再次点击 则变化大小
                    CGFloat tmp = _childView.frame.origin.x + 5.0;
                    CGSize realSize = [self realSize]; /// realSize 可以在当前视图 增加属性来 记忆 减少计算
                    /// 设置 修改 建议使用 布局 不使用约束 测试iOS10版本可能会出现布局问题
                    /// 子类frame可以直接修改 也可以放在 设置 CGAffineTransformIdentity 之后
                    _childView.frame = CGRectMake(tmp, tmp, realSize.width - tmp * 2.0, realSize.height - tmp * 2.0); /// 子视图的改变 可以 理解为 是在父视图没有任何形变前 修改
                    /// 修改自身frame 需要先还原形变
                    CGAffineTransform transform = self.transform;
                    self.transform = CGAffineTransformIdentity;
                    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, realSize.width + tmp, realSize.height + tmp);
                    self.transform = transform;
                }
                self.layer.borderWidth = 3.0;
            }
            [self performSelector:@selector(borderHidden) withObject:nil afterDelay:1.5];
        }
            break;
    }
}

- (void)borderHidden {
    self.layer.borderWidth = 0.0;
}

- (UIView *)copyView {
    CRGestureActionView *actionView = [[CRGestureActionView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 60.0)];
    
    /// 可以将变换值存本地 还原状态
    NSValue *transformValue = [NSValue valueWithCGAffineTransform:self.transform];
    actionView.transform = transformValue.CGAffineTransformValue;
    actionView.center = CGPointMake(self.frame.origin.x + self.frame.size.width / 2.0, self.frame.origin.y + self.frame.size.height / 2.0);
    
    actionView.backgroundColor = UIColor.blackColor;
    return actionView;
}

@end
