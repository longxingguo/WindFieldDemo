//
//  WindParticle.h
//  hwweather
//
//  Created by 龙兴国 on 2019/6/12.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface WindParticle : NSObject
//速度
@property (nonatomic,assign) CGFloat vScale;
//生命
@property (nonatomic,assign) NSInteger age;
//生命
@property (nonatomic,assign) CGFloat   initAge;
//显示
@property (nonatomic,assign) BOOL      isShow;
//x速度
@property (nonatomic,assign) CGFloat   xv;
//y速度
@property (nonatomic,assign) CGFloat   yv;
//中心点
@property (nonatomic,assign) CGPoint   center;
//中心点
@property (nonatomic,assign) CGPoint   oldCenter;
//最大长度
@property (nonatomic,assign) CGFloat   maxLength;
//渐变色
@property (nonatomic,strong) UIColor  *gradientColor;
//随机颜色
@property (nonatomic,assign) CGFloat   colorHue;
//初始坐标
-(void)resetWithCenter:(CGPoint)center age:(NSInteger)age xv:(CGFloat)xv yv:(CGFloat)yv;
//更新的坐标
-(void)updateWithCenter:(CGPoint)center xv:(CGFloat)xv yv:(CGFloat)yv;
@end

NS_ASSUME_NONNULL_END
