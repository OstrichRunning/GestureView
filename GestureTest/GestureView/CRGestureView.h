//
//  CRGestureView.h
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CRGestureActionViewProtocol <NSObject>

- (BOOL)actionWith:(UIGestureRecognizer * _Nullable)gestureRecognizer; /// gestureRecognizer nil 说明不是手势导致的动作

@end


@interface CRGestureView : UIView

@end

NS_ASSUME_NONNULL_END
