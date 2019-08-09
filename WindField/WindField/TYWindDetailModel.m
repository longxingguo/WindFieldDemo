//
//  TYWindDetailModel.m
//  WindField
//
//  Created by 龙兴国 on 2019/8/9.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import "TYWindDetailModel.h"

@implementation TYWindDetailModel
-(CLLocationCoordinate2D)windMin2D{
    return CLLocationCoordinate2DMake(self.startlat, self.startlon);
}
-(CLLocationCoordinate2D)windMax2D{
    return CLLocationCoordinate2DMake(self.endlat, self.endlon);
}
@end
