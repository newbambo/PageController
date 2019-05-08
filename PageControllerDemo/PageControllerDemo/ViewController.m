//
//  ViewController.m
//  PageControllerDemo
//
//  Created by visager on 2019/5/7.
//  Copyright © 2019 Visager. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"
#import "EPPageViewControllerHandler.h"
@interface ViewController ()<EPPageViewControllerHandlerDataSource,EPPageViewControllerHandlerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIStackView *toolBar;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property(nonatomic,strong)EPPageViewControllerHandler * pageHandler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installViews];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)installViews{
    NSMutableArray * controllersArray = @[].mutableCopy;
    for (UIView * buttonView in self.toolBar.arrangedSubviews) {
        SubViewController * subController =  [[SubViewController alloc]init];
        [controllersArray addObject:subController];
    }
    self.pageHandler = [[EPPageViewControllerHandler alloc]initWithParentController:self scrollView:self.contentScrollView controllers:controllersArray.copy];
}

 #pragma mark -------- FYX：EPPageViewControllerHandlerDataSource
-(UIView*)headerViewForPageController{
    return self.headerView;
}
-(UIView*)toolBarViewForPageController{
    return self.toolBar;
}
-(UIView*)navigationViewForPageController{
    return nil;
}
-(CGFloat)floatHeightForPageController{
    return 0;
}
 #pragma mark -------- FYX：EPPageViewControllerHandlerDelegate
-(void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView{
    [ self selectStackViewButton:(NSInteger) scrollView.contentOffset.x /([UIScreen mainScreen].bounds.size.width)];
}
-(void)verticalScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"verticalScrollViewDidScroll");
}
#pragma mark -------- FYX：method
-(void)selectStackViewButton:(NSInteger)tag{
    for (UIButton * buttonView in self.toolBar.arrangedSubviews) {
        [buttonView setTitleColor:buttonView.tag == tag?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

 #pragma mark -------- FYX：action
- (IBAction)stackViewButtonClick:(id)sender {
    UIButton * button = (UIButton*)sender;
    [self selectStackViewButton:button.tag];
    [self.pageHandler scrollToPageAtIndex:button.tag animate:YES];
}


@end
