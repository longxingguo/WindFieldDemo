//
//  WeakTargetTimer.h
//  GowalkProject
//
//  Created by lexingdao on 2017/8/17.
//  Copyright © 2017年 GowalkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakTargetTimer : NSObject
/**
 创建定时器，防止强引用
 
 @param ti 定时器时长
 @param aTarget 对象来引用
 @param aSelector 执行的方法
 @param userInfo 用户信息
 @param yesOrNo 是否要重复
 @return 定时器NSTimer
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
@end
