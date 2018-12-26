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

- (BOOL)canBeAction;
- (void)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer;

@end


@interface CRGestureView : UIView

@end

NS_ASSUME_NONNULL_END
