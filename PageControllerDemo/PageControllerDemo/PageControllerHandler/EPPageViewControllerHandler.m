//
//  EPPageViewControllerHandler.m
//  KM
//
//  Created by visager on 2018/12/11.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import "EPPageViewControllerHandler.h"
#import "UIScrollView+Offset.h"
#import "UIViewController+Scroll.h"
#import "UIView+Quick.h"
#define UIScreenWidth    [UIScreen mainScreen].bounds.size.width
@interface EPPageViewControllerHandler ()<UIScrollViewDelegate,EPScrollHandlerDelegate>
{
    UIView * headerView;
    UIView * toolbarView;
    UIView * navigationView;
    CGFloat floatHeight;
    CGFloat headerHeight;
    CGFloat toolBarHeight;
    
    CGPoint  currentVerticalContentOffset;
    UIViewController * _currentViewController;
    UIScrollView  * _currentScrollView;
    NSInteger currentIndex;
}
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, weak) UIScrollView *mainScrollView;
@property(nonatomic,weak)id<EPPageViewControllerHandlerDataSource>  dataSource;
@property(nonatomic,weak)id<EPPageViewControllerHandlerDelegate>  delegate;
@end
@implementation EPPageViewControllerHandler
-(void)dealloc{
    [self.parentController.view removeGestureRecognizer:_currentScrollView.panGestureRecognizer];
    NSLog(@"%@ 释放",NSStringFromClass([self class]));
}
- (instancetype)initWithParentController:(UIViewController<EPPageViewControllerHandlerDataSource>*)viewController
                              scrollView:(UIScrollView *)scrollView
                             controllers:(NSArray *)controllers{
    self = [super init];
    if (self) {
        _parentController = viewController;
        _mainScrollView = scrollView;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _controllers = controllers;
        _dataSource = viewController;
        _delegate = (id<EPPageViewControllerHandlerDelegate>)viewController;
        [self installSubViewController];
        [self installMainScrollView];
        [self installHeaderAndToobarView];
        [self layoutControllerViewAtIndex:0];
        [self installConfig];
        [_currentScrollView setContentOffset:CGPointMake(0, -headerHeight-toolBarHeight)];
        currentVerticalContentOffset=CGPointMake(0, -headerHeight-toolBarHeight);
        [self syncVerticalContentOffset];
        [self deployPanGestureRecognizer];
    }
    return self;
}

-(void)deployPanGestureRecognizer{
    [_parentController.view addGestureRecognizer:_currentScrollView.panGestureRecognizer];
}

-(void)undeploylPanGestureRecognizer{
    [_parentController.view removeGestureRecognizer:_currentScrollView.panGestureRecognizer];
}
-(void)installConfig{
    _currentViewController = _controllers.firstObject;
    _currentScrollView = _currentViewController.scrollView;
}

-(void)installSubViewController{
    for (UIViewController * subvc in _controllers) {
        subvc.scrollDelegate  = self;
    }
}
-(void)installHeaderAndToobarView{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(headerViewForPageController)]) {
        headerView =  [self.dataSource headerViewForPageController];
        headerHeight = headerView.height;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolBarViewForPageController)]) {
        toolbarView =  [self.dataSource toolBarViewForPageController];
        toolBarHeight = toolbarView.height;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(navigationViewForPageController)]) {
        navigationView =   [self.dataSource navigationViewForPageController];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(floatHeightForPageController)]) {
        floatHeight =   [self.dataSource floatHeightForPageController];
    }
}
-(void)installMainScrollView{
    [_mainScrollView setContentSize:CGSizeMake(UIScreenWidth*_controllers.count, 0)];
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator= NO;
}
-(void)installViewControllerScrollView:(UIViewController*)viewcontroller{
    UIScrollView * scrollview = viewcontroller.scrollView;
    if (@available(iOS 11.0, *)) {
        scrollview.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;
    } else {
        viewcontroller.automaticallyAdjustsScrollViewInsets = NO;
    }
    scrollview.showsVerticalScrollIndicator= NO;
    scrollview.showsHorizontalScrollIndicator = NO;
    UIEdgeInsets insets = scrollview.contentInset;
    insets.top = (headerHeight +toolBarHeight);
    scrollview.contentInset = insets;
}
#pragma mark -------- FYX：verticalScrollView Observer
-(void)epScrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _currentScrollView) {
//        NSLog(@"当前中滚动视图滑动");
        if (scrollView.needSyncOffset) {
            [self syncVerticalOffsetWithScrollView:scrollView];
            if (scrollView.contentSize.height<scrollView.bounds.size.height) {
                //为了防止insertRowsAtIndexPaths导致的空白滑动到原来位置
//                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncVerticalOffsetWithScrollView:scrollView];
                });
            }
            return;
        }
        [self setCurrentVerticalContentOffset:_currentScrollView.contentOffset];
        [self verticalScrollViewDidiScroll:_currentScrollView.contentOffset];
        if (self.delegate && [self.delegate respondsToSelector:@selector(verticalScrollViewDidScroll:)]) {
            [self.delegate verticalScrollViewDidScroll:_currentScrollView];
        }
    }else{
//                NSLog(@"非当前滚动视图滑动");
        if (scrollView.needSyncOffset) {
            //            NSLog(@"非当前滚动视图滑动 需要滚动到同步位置");
            [self syncVerticalOffsetWithScrollView:scrollView];
        }
    }
}
-(void)epScrollViewDidEndScroll:(UIScrollView *)scrollView{
    if (scrollView == _currentScrollView) {
        [self autoMoveVerticalScrollView];
    }
}

-(void)verticalScrollViewDidiScroll:(CGPoint)contentOffset{
    [self layoutHeaderViewWithScroll:contentOffset];
    [self layoutToolBarViewWithScroll:contentOffset];
    [self layoutNavigationViewWithScroll:contentOffset];
}
-(BOOL)needSynVerticalContentOffset{
    if (currentVerticalContentOffset.y >= - toolBarHeight-headerHeight && currentVerticalContentOffset.y <= -floatHeight - toolBarHeight) {
        return YES;
    }
    return NO;
}
-(void)syncVerticalContentOffset{
    for (int i = 0; i<self.controllers.count; i++) {
        UIViewController * subcontroller  = [self.controllers objectAtIndex:i];
        if (subcontroller != _currentViewController && subcontroller.parentViewController) {
            UIScrollView * scrollview = subcontroller.scrollView;
            scrollview.needSyncOffset = YES;
            [self syncVerticalOffsetWithScrollView:scrollview];
                        NSLog(@"同步某个滚动视图");
        }
    }
}
-(void)syncVerticalOffsetWithScrollView:(UIScrollView*)scrollView{
        NSLog(@"syncVerticalOffset 同步前偏移量====%@",NSStringFromCGPoint(scrollView.contentOffset));
    if (CGPointEqualToPoint(scrollView.contentOffset, currentVerticalContentOffset)) {
        return;
    }
    if ([self needSynVerticalContentOffset]) {
        CGPoint point =currentVerticalContentOffset;
        [scrollView setContentOffset:point animated:NO];
    }else if (currentVerticalContentOffset.y > -floatHeight - toolBarHeight){
        if (scrollView.contentOffset.y<=-floatHeight - toolBarHeight) {
            CGFloat height =-floatHeight - toolBarHeight;
            [scrollView setContentOffset:CGPointMake(0, height)];
        }
    }
    NSLog(@"syncVerticalOffset 同步后偏移量====%@",NSStringFromCGPoint(scrollView.contentOffset));
}
-(void)autoMoveVerticalScrollView{
    CGFloat currentOffsetY = _currentScrollView.contentOffset.y;
    //    NSLog(@"竖直滚动的偏移量====%f",currentOffsetY);
    if ( headerHeight + toolBarHeight + currentOffsetY> 0 &&  headerHeight + toolBarHeight + currentOffsetY < 60) {
        [_currentScrollView setContentOffset:CGPointMake(0,- headerHeight-toolBarHeight) animated:YES];
    }else if (headerHeight + toolBarHeight + currentOffsetY > 60 && headerHeight + toolBarHeight + currentOffsetY <120){
        if (_currentScrollView.contentSize .height > _currentScrollView.height + floatHeight) {
            [_currentScrollView setContentOffset:CGPointMake(0,- headerHeight-toolBarHeight+120) animated:YES];
        }else{
            [_currentScrollView setContentOffset:CGPointMake(0,- headerHeight-toolBarHeight) animated:YES];
        }
    }
}
#pragma mark -------- horizontal   UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self undeploylPanGestureRecognizer];
    NSInteger currentIndex = scrollView.contentOffset.x/UIScreenWidth;
    _currentViewController = [_controllers objectAtIndex:currentIndex];
    _currentScrollView = _currentViewController.scrollView;
    [self layoutControllerView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _mainScrollView) {
        if (scrollView.decelerating || scrollView.dragging) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(horizontalScrollViewDidScroll:)]) {
                [self.delegate horizontalScrollViewDidScroll:_mainScrollView];
            }
        }
    }else{
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentIndex = scrollView.contentOffset.x/UIScreenWidth;
    _currentViewController = [_controllers objectAtIndex:currentIndex];
    _currentScrollView = _currentViewController.scrollView;
    [self deployPanGestureRecognizer];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self undeploylPanGestureRecognizer];
    NSInteger currentIndex = scrollView.contentOffset.x/UIScreenWidth;
    _currentViewController = [_controllers objectAtIndex:currentIndex];
    _currentScrollView = _currentViewController.scrollView;
    NSInteger index = [_controllers indexOfObject:_currentViewController];
    [self layoutControllerViewAtIndex:index];
    [self syncVerticalContentOffset];
    [self deployPanGestureRecognizer];
}
#pragma mark -------- FYX：private
-(void)layoutControllerView{
    NSInteger index = [_controllers indexOfObject:_currentViewController];
    [self layoutControllerViewAtIndex:index-1];
    [self layoutControllerViewAtIndex:index+1];
    [self syncVerticalContentOffset];
}

-(void)layoutControllerViewAtIndex:(NSInteger)index{
    if (index >= 0 && index<_controllers.count) {
        UIViewController * controller=   [_controllers objectAtIndex:index];
        if (controller.parentViewController !=_parentController ) {
            NSLog(@"布局子controller");
            [self installViewControllerScrollView:controller];
            controller.view.frame = CGRectMake(index*_mainScrollView.width, 0, _mainScrollView.width, _mainScrollView.height);
            [controller willMoveToParentViewController:_parentController];
            [_parentController addChildViewController:controller];
            [controller didMoveToParentViewController:_parentController];
            [_mainScrollView addSubview:controller.view];
        }
    }
}

-(void)layoutHeaderViewWithScroll:(CGPoint)contentOffset{
    CGFloat   progress =contentOffset.y;
    if (progress<=-(headerHeight+toolBarHeight)) {
        headerView.transform =CGAffineTransformMakeTranslation(0, 0);
    }else if (progress <=0 && progress>-(headerHeight+toolBarHeight)){
        headerView.transform =CGAffineTransformMakeTranslation(0, -(headerHeight+toolBarHeight)-progress);
    }else{
        headerView.transform =CGAffineTransformMakeTranslation(0, -(headerHeight+toolBarHeight));
    }
}

-(void)layoutToolBarViewWithScroll:(CGPoint)contentOffset{
    CGFloat   progress =contentOffset.y;
    // NSLog(@"布局进度====%lf",progress);
    if (progress<=-(headerHeight+toolBarHeight)) {
        toolbarView.transform =CGAffineTransformMakeTranslation(0, 0);
    }else if (progress <=-floatHeight-toolBarHeight&& progress>-(headerHeight+toolBarHeight)){
        toolbarView.transform =CGAffineTransformMakeTranslation(0, -(headerHeight+toolBarHeight)-progress);
    }else{
        toolbarView.transform =CGAffineTransformMakeTranslation(0, -(headerHeight-floatHeight));
    }
}
-(void)layoutNavigationViewWithScroll:(CGPoint)contentOffset{
    CGFloat   progress =contentOffset.y;
    CGFloat alphaProgess =headerHeight+ progress;
    navigationView.alpha = alphaProgess/floatHeight;
}
-(void)setCurrentVerticalContentOffset:(CGPoint)point{
    if (point.y <  -toolBarHeight-headerHeight) {
        currentVerticalContentOffset = CGPointMake(point.x, -toolBarHeight-headerHeight);
    }else{
        currentVerticalContentOffset =point;
    }
}

#pragma mark -------- FYX：public
- (void)scrollToPageAtIndex:(NSUInteger)index animate:(BOOL)animate{
    [self layoutControllerViewAtIndex:index];
    [self syncVerticalContentOffset];
    [_mainScrollView setContentOffset:CGPointMake(index * UIScreenWidth , 0) animated:YES];
}
@end
