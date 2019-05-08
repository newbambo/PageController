//
//  EPPageViewControllerHandler.h
//  KM
//
//  Created by visager on 2018/12/11.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol EPPageViewControllerHandlerDataSource <NSObject>
-(UIView*)headerViewForPageController;
-(UIView*)toolBarViewForPageController;
-(UIView*)navigationViewForPageController;
-(CGFloat)floatHeightForPageController;
@end
@protocol EPPageViewControllerHandlerDelegate <NSObject>
-(void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)verticalScrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface EPPageViewControllerHandler : NSObject
- (instancetype)initWithParentController:(UIViewController<EPPageViewControllerHandlerDataSource>*)viewController
                              scrollView:(UIScrollView *)scrollView
                             controllers:(NSArray *)controllers;
@property (nonatomic, strong, readonly) NSArray *controllers;
- (void)scrollToPageAtIndex:(NSUInteger)index animate:(BOOL)animate;
@end
