//
//  UIScrollView+Offset.m
//  KM
//
//  Created by visager on 2018/12/25.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import "UIScrollView+Offset.h"
#import <objc/runtime.h>
char * KneedSyncOffset;
char *kCommonOffset;

@implementation UIScrollView (Offset)

-(void)setNeedSyncOffset:(BOOL)needSyncOffset{
    objc_setAssociatedObject(self, &KneedSyncOffset, @(needSyncOffset), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL )needSyncOffset {
    return [objc_getAssociatedObject(self, &KneedSyncOffset) boolValue];
}

-(void)setCommonOffset:(CGPoint)commonOffset{
    objc_setAssociatedObject(self, &kCommonOffset, [NSValue valueWithCGPoint:commonOffset], OBJC_ASSOCIATION_RETAIN);
}
-(CGPoint)commonOffset{
    return [objc_getAssociatedObject(self, &kCommonOffset) CGPointValue];
}


@end
