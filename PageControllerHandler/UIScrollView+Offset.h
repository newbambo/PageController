//
//  UIScrollView+Offset.h
//  KM
//
//  Created by visager on 2018/12/25.
//  Copyright © 2018 popo.netease.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Offset)<UIScrollViewDelegate>
@property(nonatomic,assign)BOOL  needSyncOffset;
@property(nonatomic,assign)CGPoint  commonOffset;
@end

NS_ASSUME_NONNULL_END
