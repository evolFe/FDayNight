//
//  WZPrivateView.m
//  gb_ios
//
//  Created by evol on 2018/9/3.
//  Copyright © 2018年 mingbai.fe All rights reserved.
//

#import "ELDayNight.h"
#import <objc/runtime.h>

static const int kColortContainerKey;

@implementation NSString (dayNight)

- (NSString *)nightValue
{
    if ([FDayNightManager defaultManager].isNight) {
        return [self stringByAppendingString:@"_night"];
    }
    return self;
}

@end

/** 私有类 - color 容器 */
@interface WZColorContainer : NSObject

@property (nonatomic ,weak) id target;// 这里一定要用weak, 避免循环引用造成内存泄漏
@property (nonatomic ,strong) NSMutableArray * values;

- (instancetype)initWithTarget:(id)target;
- (void)addSelector:(SEL)sel object:(id)object, ... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation WZColorContainer

- (instancetype)initWithTarget:(id)target
{
    self = [super init];
    if (self) {
        /** 弱引用target */
        self.target = target;
        _values = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSceneChange:) name:@"f_notification_n" object:nil];
    }
    return self;
}

- (void)onSceneChange:(NSNotification *)note {
    for (NSDictionary * dict in self.values) {
        NSString * selector = dict[@"sel"];
        id obj = dict[@"obj"];
        SEL _sel = NSSelectorFromString(selector);
        NSMethodSignature * methodSignature = [[self.target class] instanceMethodSignatureForSelector:_sel];
        if(methodSignature == nil)
        {
            @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self.target];
        [invocation setSelector:_sel];
        NSInteger argsCount = methodSignature.numberOfArguments - 2; // 参数里有 self, _cmd  所以-2
        NSInteger paramsCount = [obj count];
        if (paramsCount >= argsCount) {
            for (int i = 0; i < argsCount; i++) {
                id param = obj[i];
                [invocation setArgument:&param atIndex:i+2];
            }
            [invocation invoke];
        }
    }
}


- (void)addSelector:(SEL)sel object:(id)object, ... NS_REQUIRES_NIL_TERMINATION
{
    if (sel ==nil || object == nil) {
        return;
    }
    va_list args;
    id item;
    va_start(args, object);
    NSMutableArray * params = [NSMutableArray arrayWithObjects:object, nil];
    while ((item = va_arg(args, id))) {
        [params addObject:item];
    }
    va_end(args);
    [_values addObject:@{@"sel":NSStringFromSelector(sel), @"obj":params}];
}

@end

@implementation UIView (DNTool)

- (DNTuple)backgroundDNTuple{return nil;}
- (void)setBackgroundDNTuple:(DNTuple)backgroundDNTuple {
    self.backgroundColor = fValueFromTuple(backgroundDNTuple);
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setBackgroundDNTuple:) object:backgroundDNTuple, nil];
}

- (void)_setBackgroundDNTuple:(DNTuple)tuple {
    self.backgroundColor = fValueFromTuple(tuple);
}

- (WZColorContainer *)colorContainer
{
    WZColorContainer * container = objc_getAssociatedObject(self, &kColortContainerKey);
    if (container == nil) {
        container = [[WZColorContainer alloc] initWithTarget:self];
        objc_setAssociatedObject(self, &kColortContainerKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return container;
}

@end

@implementation UILabel (DNTool)
- (DNTuple)textDNTuple{return nil;}
- (void)setTextDNTuple:(DNTuple)textDNTuple {
    self.textColor = fValueFromTuple(textDNTuple);
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setTextDNTuple:) object:textDNTuple, nil];
}
- (void)_setTextDNTuple:(DNTuple)tuple{
    self.textColor = fValueFromTuple(tuple);
}

@end

@implementation UIButton (DNTool)
- (void)setTitleDNTuple:(DNTuple)tuple forState:(UIControlState)state {
    [self setTitleColor:fValueFromTuple(tuple) forState:state];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setTitleDNTuple:state:) object:tuple, @(state), nil];
}

- (void)_setTitleDNTuple:(DNTuple)tuple state:(id)state {
    [self setTitleColor:fValueFromTuple(tuple) forState:(UIControlState)[state integerValue]];
}

- (void)setImageTuple:(DNTuple)tuple forState:(UIControlState)state {
    [self setImage:[UIImage imageNamed:fValueFromTuple(tuple)] forState:UIControlStateNormal];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setImageTuple:forState:) object:tuple, @(state), nil];
}
- (void)_setImageTuple:(DNTuple)tuple forState:(UIControlState)state {
    [self setImage:[UIImage imageNamed:fValueFromTuple(tuple)] forState:UIControlStateNormal];
}
/** 按钮 设置图片 */
- (void)setImageKey:(NSString *)key forState:(UIControlState)state
{
    [self setImage:[UIImage imageNamed:key.nightValue] forState:UIControlStateNormal];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setImageKey:forState:) object:key, @(state), nil];
}
- (void)_setImageKey:(NSString *)key forState:(id)state
{
    [self setImage:[UIImage imageNamed:key.nightValue] forState:(UIControlState)[state integerValue]];
}

@end

@implementation UIImageView (DNTool)
- (DNTuple)imageTuple {return nil;}
- (void)setImageTuple:(DNTuple)imageTuple {
    self.image = [UIImage imageNamed:fValueFromTuple(imageTuple)];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setImageTuple:) object:imageTuple, nil];
}
- (void)_setImageTuple:(DNTuple)imageTuple {
    self.image = [UIImage imageNamed:fValueFromTuple(imageTuple)];
}

- (NSString *)imageKey{return nil;}
- (void)setImageKey:(NSString *)imageKey{
    self.image = [UIImage imageNamed:imageKey.nightValue];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setImageKey:) object:imageKey, nil];
}
- (void)_setImageKey:(NSString *)imageKey{
    self.image = [UIImage imageNamed:imageKey.nightValue];
}

- (void)setImageKey:(NSString *)imageKey stretchPoint:(CGPoint)strechPoint{
    self.image = [[UIImage imageNamed:imageKey.nightValue] stretchableImageWithLeftCapWidth:strechPoint.x topCapHeight:strechPoint.y];
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setImageKey:stretchPoint:) object:imageKey,[NSValue valueWithCGPoint:strechPoint],nil];
}
- (void)_setImageKey:(NSString *)imageKey stretchPoint:(NSValue *)strechPoint{
    CGPoint offset = strechPoint.CGPointValue;
    self.image = [[UIImage imageNamed:imageKey.nightValue] stretchableImageWithLeftCapWidth:offset.x topCapHeight:offset.y];
}

@end

@implementation UITextField (DNTool)
- (DNTuple)textDNTuple{return nil;}
- (void)setTextDNTuple:(DNTuple)textDNTuple {
    self.textColor = fValueFromTuple(textDNTuple);
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setTextDNTuple:) object:textDNTuple, nil];
}
- (void)_setTextDNTuple:(DNTuple)tuple{
    self.textColor = fValueFromTuple(tuple);
}
@end

@implementation UITextView (DNTool)
- (DNTuple)textDNTuple{return nil;}
- (void)setTextDNTuple:(DNTuple)textDNTuple {
    self.textColor = fValueFromTuple(textDNTuple);
    WZColorContainer * container = self.colorContainer;
    [container addSelector:@selector(_setTextDNTuple:) object:textDNTuple, nil];
}
- (void)_setTextDNTuple:(DNTuple)tuple{
    self.textColor = fValueFromTuple(tuple);
}
@end

