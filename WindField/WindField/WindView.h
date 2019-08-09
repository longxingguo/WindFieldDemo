//
//  WindView.h
//  hwweather
//
//  Created by 龙兴国 on 2019/6/14.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYWindDetailModel.h"
#import <MAMapKit/MAMapKit.h>
#import "WindMotionStreakView.h"
NS_ASSUME_NONNULL_BEGIN
@interface WindView : UIView
//初始化
- (instancetype)initWithFrame:(CGRect)frame andMapView:(MAMapView *)mapView andWindMotionStreakView:(WindMotionStreakView *)windMotionStreakView andTYWindDetailModel:(TYWindDetailModel *)tyWindDetailModel;
//暂停
-(void)windStop;
//开始
-(void)windRestart;
//销毁定时器
-(void)windRemoveTime;
@end
NS_ASSUME_NONNULL_END
