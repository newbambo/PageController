//
//  UIViewController+Scroll.m
//  KM
//
//  Created by visager on 2018/12/25.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import "UIViewController+Scroll.h"
#import "UIScrollView+Offset.h"
#import <objc/runtime.h>
char *kScrollDelegate;
char *kScrollView;
@implementation UIViewController (Scroll)
-(void)setScrollDelegate:(id<EPScrollHandlerDelegate>)scrollDelegate{
    objc_setAssociatedObject(self, &kScrollDelegate, scrollDelegate, OBJC_ASSOCIATION_ASSIGN);
}
-(id<EPScrollHandlerDelegate>)scrollDelegate{
    return objc_getAssociatedObject(self, &kScrollDelegate);
}
-(void)setScrollView:(UIScrollView *)scrollView{
    objc_setAssociatedObject(self, &kScrollView, scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIScrollView*)scrollView{
   UIScrollView * view =  objc_getAssociatedObject(self, &kScrollView);
    if (!view) {
        view = [self searchScrollView];
        [self setScrollView:view];
    }
    return view;
}
-(UIScrollView*)searchScrollView{
    for (UIView * view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView*)view;
        }
    }
    return nil;
}
 #pragma mark -------- FYX：UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    scrollView.needSyncOffset  = NO;
}
-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if (scrollView.scrollsToTop) {
        scrollView.needSyncOffset  = NO;
    }
    return scrollView.scrollsToTop;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"滚动视图是否需要强制滚动====%d 当前偏移量===%@",scrollView.needSyncOffset,NSStringFromCGPoint(scrollView.contentOffset));
    if (self.scrollDelegate) {
        [self.scrollDelegate epScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate &&self.scrollDelegate) {
        [self.scrollDelegate epScrollViewDidEndScroll:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.scrollDelegate) {
        [self.scrollDelegate epScrollViewDidEndScroll:scrollView];
    }
}
@end
