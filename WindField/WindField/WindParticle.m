//
//  WindParticle.m
//  hwweather
//
//  Created by 龙兴国 on 2019/6/12.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import "WindParticle.h"
@implementation WindParticle
-(instancetype)init{
    if (self = [super init]){
        self.vScale    = 4.0;
        self.oldCenter = CGPointMake(-1, -1);
    }
    return self;
}
-(void)resetWithCenter:(CGPoint)center age:(NSInteger)age xv:(CGFloat)xv yv:(CGFloat)yv{
    self.age       = age;
    self.initAge   = age;
    [self updateWithCenter:center xv:xv yv:yv];
    self.oldCenter = CGPointMake(-1, -1);
}
-(void)updateWithCenter:(CGPoint)center xv:(CGFloat)xv yv:(CGFloat)yv{
    self.oldCenter = self.center;
    self.center    = center;
    [self setVelocityWithX:xv y:yv];
}
-(void)setVelocityWithX:(CGFloat)x y:(CGFloat)y{
    self.xv        = x/self.vScale;
    self.yv        = y/self.vScale;
//    CGFloat s      = sqrt(x*x + y*y)/self.maxLength;// s<=0.6 && s>0.4  self.gradientColor = [UIColor yellowColor];
//    CGFloat t      = floor(290*(1 - s)) - 45;
//    self.colorHue  = t;
}
-(BOOL)isShow{
    double t = sqrt(self.xv * self.xv + self.yv * self.yv);
    if (t <= 0.01){//过滤风速太小的点
        return NO;
    }
    return YES;
}
@end
