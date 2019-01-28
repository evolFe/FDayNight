//
//  WZPrivateView.h
//  gb_ios
//
//  Created by evol on 2018/9/3.
//  Copyright © 2018年 mingbai.fe All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDayNightManager.h"

//#define WS(__wsSelf__) __weak __typeof(&*self)__wsSelf__ = self

typedef NSArray * DNTuple;
CG_INLINE DNTuple fDNTupleMake(id dayValue, id nightValue) {
    return @[dayValue, nightValue];
}
CG_INLINE id fValueFromTuple(DNTuple tuple) {
    if ([FDayNightManager defaultManager].isNight) {
        return tuple[1];
    }
    return tuple[0];
}

#pragma mark - String  扩展 -
@interface NSString (dayNight)

- (NSString *)nightValue;

@end


@class WZColorContainer;
@interface UIView (DNTool)
@property (nonatomic , copy) DNTuple backgroundDNTuple; /** 写成属性只是为了 写代码的有 提示。。。 以下一样 */
- (WZColorContainer *)colorContainer;
@end

@interface UILabel (DNTool)
@property (nonatomic ,strong) DNTuple textDNTuple;
@end

@interface UIButton (DNTool)
- (void)setTitleDNTuple:(DNTuple)tuple forState:(UIControlState)state; /** 设置 button 字体颜色 */
- (void)setImageKey:(NSString *)key forState:(UIControlState)state; /** 设置 图片 */
- (void)setImageTuple:(DNTuple)tuple forState:(UIControlState)state; /** 设置tuple */

@end

@interface UIImageView (DNTool)
@property (nonatomic ,copy) NSString * imageKey;
@property (nonatomic, copy) DNTuple imageTuple;
- (void)setImageKey:(NSString *)imageKey stretchPoint:(CGPoint)strechPoint; // .9图 暂时没做imageTuple
@end

@interface UITextField (DNTool)
@property (nonatomic ,strong) DNTuple textDNTuple;
@end

@interface UITextView (DNTool)
@property (nonatomic ,strong) DNTuple textDNTuple;
@end
