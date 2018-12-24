//
//  CRGestureActionView.m
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "CRGestureActionView.h"

@implementation CRGestureActionView

#pragma mark - CRGestureActionViewProtocol
- (BOOL)canAction {
    return self.userInteractionEnabled;
}
- (void)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        NSLog(@"tap action");
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
