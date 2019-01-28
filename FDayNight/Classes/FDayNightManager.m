//
//  ELDayNightManager.m
//  DayNightDemo
//
//  Created by evol on 2018/9/10.
//  Copyright © 2018年 evol. All rights reserved.
//

#import "FDayNightManager.h"
#import "ELDayNight.h"

@implementation FDayNightManager

- (void)toggle {
    self.isNight = !self.isNight;
}

- (void)setIsNight:(BOOL)isNight {
    _isNight = isNight;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"f_notification_n" object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:isNight forKey:@"isNight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (instancetype)defaultManager {
    static FDayNightManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isNight = [[NSUserDefaults standardUserDefaults] boolForKey:@"isNight"];
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self defaultManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] defaultManager];
}

@end
