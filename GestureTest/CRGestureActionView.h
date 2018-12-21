//
//  CRGestureActionView.h
//  GestureTest
//
//  Created by Craig on 2018/12/21.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "CRGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRGestureActionView : UIView <CRGestureActionViewProtocol>

- (UIView *)copyView;

@end

NS_ASSUME_NONNULL_END
