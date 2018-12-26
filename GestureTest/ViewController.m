//
//  ViewController.m
//  GestureTest
//
//  Created by Craig on 2018/12/18.
//  Copyright © 2018 Craig. All rights reserved.
//

#import "ViewController.h"
#import "CRGestureActionView.h"

@interface ViewController ()

@property (nonatomic, strong) CRGestureView *gestureView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutSubview];
}

- (void)layoutSubview {
    _gestureView = [[CRGestureView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _gestureView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_gestureView];
    
    CRGestureActionView *actionView = [[CRGestureActionView alloc] initWithFrame:CGRectMake(0.0, 60.0, 100.0, 60.0)];
    actionView.backgroundColor = UIColor.redColor;
    [_gestureView addSubview:actionView];
    
    /// 初始化 增加 旋转 缩放 view (所有形变会叠加)
    CRGestureActionView *transformView = [[CRGestureActionView alloc] initWithFrame:CGRectMake(0.0, 60.0, 100.0, 60.0)];
    transformView.transform = CGAffineTransformRotate(transformView.transform, M_PI_2 * 0.6);
    transformView.transform = CGAffineTransformScale(transformView.transform, 1.5, 1.5);
    transformView.backgroundColor = UIColor.grayColor;
    [_gestureView addSubview:transformView];

    /// copy视图按钮 添加在gestureView
    UIButton *copyBtn = [[UIButton alloc] initWithFrame:CGRectMake(_gestureView.frame.size.width - 80.0, _gestureView.frame.size.height - 60.0, 60.0, 40.0)];
    [copyBtn setTitle:@"copy" forState:UIControlStateNormal];
    copyBtn.backgroundColor = UIColor.blackColor;
    [copyBtn addTarget:self action:@selector(copyBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_gestureView addSubview:copyBtn];
}

- (void)copyBtnTapped {
    CRGestureActionView *actionView = _gestureView.subviews.lastObject;
    CRGestureActionView *copyView = (CRGestureActionView *)[actionView copyView];
    [_gestureView addSubview:copyView];
}

@end
