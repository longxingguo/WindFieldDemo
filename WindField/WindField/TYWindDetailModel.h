//
//  TYWindDetailModel.h
//  WindField
//
//  Created by 龙兴国 on 2019/8/9.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TYWindDetailModel : NSObject
//标题
@property (nonatomic ,copy  )NSString * title;
//
@property (nonatomic ,assign)CGFloat     year;
//
@property (nonatomic ,assign)CGFloat     month;
//
@property (nonatomic ,assign)CGFloat     day;
//
@property (nonatomic ,assign)CGFloat     hour;
//
@property (nonatomic ,assign)CGFloat timesession;
//
@property (nonatomic ,assign)CGFloat layer;
//
@property (nonatomic ,assign)CGFloat startlon;
//
@property (nonatomic ,assign)CGFloat startlat;
//
@property (nonatomic ,assign)CGFloat endlon;
//
@property (nonatomic ,assign)CGFloat endlat;
//
@property (nonatomic ,assign)CGFloat nlon;
//
@property (nonatomic ,assign)CGFloat nlat;
//
@property (nonatomic ,assign)CGFloat lonsize;
//
@property (nonatomic ,assign)CGFloat latsize;
//
@property (nonatomic ,strong)NSArray * data;
//
@property (nonatomic ,assign)CLLocationCoordinate2D windMin2D;
//
@property (nonatomic ,assign)CLLocationCoordinate2D windMax2D;
@end

NS_ASSUME_NONNULL_END
