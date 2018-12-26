//
//  UIView+CRGestureView.h
//  GestureTest
//
//  Created by Craig on 2018/12/24.
//  Copyright © 2018 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CRGestureView)

/// 获取缩放大小 (使用layer transform.sacle不准确)
- (CGFloat)xScale;
- (CGFloat)yScale;
/// 设置anchorPoint
- (void)anchorWith:(CGPoint)anchorPoint;
/// 缩放旋转前真实size
- (CGSize)realSize;
/// 判断是否包含点
- (BOOL)containsPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
