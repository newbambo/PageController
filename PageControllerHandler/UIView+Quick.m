//
//  UIView+Quick.m
//
//  Created by  on 13-12-6.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "UIView+Quick.h"
#import <objc/runtime.h>
@implementation UIView (Quick)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hookOriginMenthod:@selector(frame) newMethod:@selector(ep_frame)];
        [self hookOriginMenthod:@selector(setFrame:) newMethod:@selector(ep_setFrame:)];
    });
}

+ (BOOL)hookOriginMenthod:(SEL)origSel newMethod:(SEL)altSel {
    Class class = self;
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method altMethod = class_getInstanceMethod(class, altSel);
    if (!origMethod || !altMethod) {
        return NO;
    }
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(altMethod), method_getTypeEncoding(altMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, altSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, altMethod);
    }
    return YES;
}

- (CGRect)ep_frame {
    if ([[NSThread currentThread] isMainThread]) {
        return self.ep_frame;
    }
    __block CGRect rect;
    dispatch_sync(dispatch_get_main_queue(), ^{
        rect = self.ep_frame;
    });
    return rect;
}

- (void)ep_setFrame:(CGRect)frame {
    if ([[NSThread currentThread] isMainThread]) {
        [self ep_setFrame:frame];
        return ;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self ep_setFrame:frame];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
    return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
    return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
    return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
    return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        if ([child isKindOfClass:[UIImageView class]]) {
            ((UIImageView*)child).image = nil;
        }
        [child removeFromSuperview];
        child = nil;
    }
}

- (void)hideShadow {
	self.layer.shadowColor = [UIColor clearColor].CGColor;
}

- (void)shadowColor:(UIColor*)color shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity {
	self.layer.shadowColor = color.CGColor;
	self.layer.shadowOffset = offset;
	self.layer.shadowRadius = radius;
	self.layer.shadowOpacity = opacity;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
}

- (void)cornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color {
	CALayer *layer = [self layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:radius];
	[layer setBorderWidth:width];
	[layer setBorderColor:color.CGColor];
}

- (void)shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)sradius shadowOpacity:(CGFloat)opacity
	   cornerRadius:(CGFloat)cradius borderWidth:(CGFloat)width borderColor:(UIColor *)borderColor {
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = sradius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
    self.layer.cornerRadius = cradius;
    self.layer.borderWidth = width;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.masksToBounds = YES;
}

- (void)shake {
	CAKeyframeAnimation *keyAn = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	[keyAn setDuration:0.5f];
	NSArray *array = [[NSArray alloc] initWithObjects:
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  nil];
	[keyAn setValues:array];
	NSArray *times = [[NSArray alloc] initWithObjects:
					  [NSNumber numberWithFloat:0.1f],
					  [NSNumber numberWithFloat:0.2f],
					  [NSNumber numberWithFloat:0.3f],
					  [NSNumber numberWithFloat:0.4f],
					  [NSNumber numberWithFloat:0.5f],
					  [NSNumber numberWithFloat:0.6f],
					  [NSNumber numberWithFloat:0.7f],
					  [NSNumber numberWithFloat:0.8f],
					  [NSNumber numberWithFloat:0.9f],
					  [NSNumber numberWithFloat:1.0f],
					  nil];
	[keyAn setKeyTimes:times];
	[self.layer addAnimation:keyAn forKey:@"TextAnim"];
}

-(void)configureBorder:(CGFloat)borderWidth shadowDepth:(CGFloat)shadowDepth controlPointXOffset:(CGFloat)controlPointXOffset controlPointYOffset:(CGFloat)controlPointYOffset
{
    [self.layer setBorderWidth:borderWidth];
    [self setContentMode:UIViewContentModeCenter];
    [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOffset:CGSizeMake(0.0, 2.0)];
    [self.layer setShadowRadius:2.0];
    [self.layer setShadowOpacity:0.3];
    
    UIBezierPath* path = [self curlShadowPathWithShadowDepth:shadowDepth
                                                   controlPointXOffset:controlPointXOffset
                                                   controlPointYOffset:controlPointYOffset
                                                               forView:self];
    [self.layer setShadowPath:path.CGPath];
}

-(UIBezierPath*)curlShadowPathWithShadowDepth:(CGFloat)shadowDepth controlPointXOffset:(CGFloat)controlPointXOffset controlPointYOffset:(CGFloat)controlPointYOffset forView:(UIView*)view
{
    
    CGSize viewSize = [view bounds].size;
    CGPoint polyTopLeft = CGPointMake(0.0, controlPointYOffset);
    CGPoint polyTopRight = CGPointMake(viewSize.width, controlPointYOffset);
    CGPoint polyBottomLeft = CGPointMake(0.0, viewSize.height -3);
    CGPoint polyBottomRight = CGPointMake(viewSize.width, viewSize.height - 3);
    
    CGPoint controlPointLeftUp = CGPointMake(controlPointXOffset , viewSize.height - 3);
    CGPoint controlPointRightUp = CGPointMake(viewSize.width - controlPointXOffset,  viewSize.height - 3);
    
    CGPoint controlPointLeftDown = CGPointMake(controlPointXOffset , viewSize.height + shadowDepth);
    CGPoint controlPointRightDown = CGPointMake(viewSize.width - controlPointXOffset,  viewSize.height + shadowDepth);
    
    CGPoint controlPointCenterLeft = CGPointMake(viewSize.width/3, viewSize.height - 3);
    CGPoint controlPointCenterRight = CGPointMake(2*viewSize.width/3, viewSize.height - 3);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    [path moveToPoint:controlPointLeftUp];
    [path addLineToPoint:polyBottomLeft];
    [path addLineToPoint:polyTopLeft];
    [path addLineToPoint:polyTopRight];
    [path addLineToPoint:polyBottomRight];
    [path addLineToPoint:controlPointRightUp];
    [path addLineToPoint:controlPointRightDown];
    [path addCurveToPoint:controlPointLeftDown
            controlPoint1:controlPointCenterRight
            controlPoint2:controlPointCenterLeft];
    
    [path closePath];
    return path;
}

- (UIImage*)viewToImage{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
   if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
    
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage * viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (UIViewController*)viewController {
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
