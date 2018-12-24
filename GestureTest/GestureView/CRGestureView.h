//
//  CRGestureView.h
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "UIView+CRGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRGestureActionViewProtocol <NSObject>

- (BOOL)canAction; /// NO 则不会激活手势 事件将延父视图传递
- (void)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer; /// gestureRecognizer nil 说明不是手势导致的动作
- (CGFloat)maxScale;
- (CGFloat)minScale;

@end


@interface CRGestureView : UIView

@end

NS_ASSUME_NONNULL_END
