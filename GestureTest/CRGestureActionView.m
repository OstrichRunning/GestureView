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
    _childView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width - 20.0, self.frame.size.height - 20.0)];
    _childView.backgroundColor = UIColor.yellowColor;
    [self addSubview:_childView];
}

#pragma mark - CRGestureActionViewProtocol
- (BOOL)canAction {
    return self.userInteractionEnabled;
}
- (void)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
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
    if (gestureRecognizer == nil) {
        NSLog(@"其它兄弟视图 成为 action 视图");
    }
}
- (CGFloat)maxScale {
    return 5.0;
}
- (CGFloat)minScale {
    return 0.5;
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
