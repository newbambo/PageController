//
//  UIViewController+Scroll.h
//  KM
//
//  Created by visager on 2018/12/25.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EPScrollHandlerDelegate<NSObject>
-(void)epScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)epScrollViewDidEndScroll:(UIScrollView *)scrollView;
@end
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Scroll)<UIScrollViewDelegate>
@property(nonatomic,weak)id<EPScrollHandlerDelegate>  scrollDelegate;
@property(nonatomic,strong)UIScrollView * scrollView;
@end

NS_ASSUME_NONNULL_END
