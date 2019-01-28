//
//  ELDayNightManager.h
//  DayNightDemo
//
//  Created by evol on 2018/9/10.
//  Copyright © 2018年 evol. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FDayNightManager : NSObject<NSCopying>

+ (instancetype)defaultManager;

@property (nonatomic ,assign) BOOL isNight;

/** 切换 半天 - 黑夜 */
- (void)toggle;

@end
