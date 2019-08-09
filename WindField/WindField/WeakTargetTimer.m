//
//  WeakTargetTimer.m
//  GowalkProject
//
//  Created by lexingdao on 2017/9/21.
//  Copyright © 2017年 lexingdao. All rights reserved.
//

#import "WeakTargetTimer.h"

@interface WeakTargetTimer()
// @param 对象
@property (weak   , nonatomic) id  aTarget;
// @param 方法
@property (assign , nonatomic) SEL aSelector;
@end

@implementation WeakTargetTimer
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    WeakTargetTimer * object = [[WeakTargetTimer alloc] init];
    
    object.aTarget = aTarget;
    
    object.aSelector = aSelector;
    
    return [NSTimer scheduledTimerWithTimeInterval:ti target:object selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
}

- (void)fire:(id)object {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.aTarget performSelector:self.aSelector withObject:object];
#pragma clang diagnostic pop
}

@end
