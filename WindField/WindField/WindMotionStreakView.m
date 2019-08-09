//
//  WindMotionStreakView.m
//  hwweather
//
//  Created by 龙兴国 on 2019/6/14.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import "WindMotionStreakView.h"
#define LIMIT 20 //层次  越多 尾巴越长 
@interface WindMotionStreakView ()
@property (nonatomic,strong) NSMutableArray *imgLayers;
@end
@implementation WindMotionStreakView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor        = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.imgLayers              = [NSMutableArray arrayWithCapacity:LIMIT];
    }
    return self;
}
//添加
-(void)addLayer:(CALayer *)layer1{
    if(self.imgLayers.count == LIMIT){
        CALayer * layer = self.imgLayers.lastObject;
        [layer removeFromSuperlayer];
        [self.imgLayers removeLastObject];
    }
    CALayer *  newlayer = [CALayer layer];
    newlayer.frame      = self.bounds;
    newlayer.contents   = layer1.contents;
    newlayer.actions    = @{@"opacity": [NSNull null]};// 取消动画
    [self.layer addSublayer:newlayer];
    [self.imgLayers insertObject:newlayer atIndex:0];
    for (NSInteger i = self.imgLayers.count-1; i>=0; i--){//
        CALayer * layer = [self.imgLayers objectAtIndex:i];
        layer.opacity   = layer.opacity - 1.0/LIMIT;
    }
}
//移除
-(void)removelayer1{
    for (CALayer *layer in self.imgLayers){
        [layer removeFromSuperlayer];
    }
    [self.imgLayers removeAllObjects];
}
@end
