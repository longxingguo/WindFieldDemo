//
//  ViewController.m
//  WindField
//
//  Created by 龙兴国 on 2019/8/9.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import "ViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import "WindView.h"
#import "WindMotionStreakView.h"
#import "TYWindDetailModel.h"
#import <YYModel/YYModel.h>
@interface ViewController ()<MAMapViewDelegate>
//地图
@property (nonatomic ,strong)MAMapView          * mapView;
//风场图
@property (nonatomic ,strong)WindView           * windView;
//流星尾巴
@property (nonatomic ,strong)WindMotionStreakView * streakView;
//数据
@property (nonatomic ,strong)TYWindDetailModel  * windModel;
@end

@implementation ViewController

- (void)viewDidLoad {////////////////////////////////////请打开Podfile文件件 打开注释 自己pod install
    [super viewDidLoad];
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey      = @"10dffc4912e47276e4f16351620a7916";
    [self.view addSubview:self.mapView];
    UIButton * button      = [[UIButton alloc]initWithFrame:CGRectMake(10, 200, 50, 50)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)buttonClick:(UIButton *)sender{ /////////////特别建议 生成风场时  地图缩放等级不能同时改变太多 如果你生成风场的同时 self.mapView.zoomLevel  > 5 造成 mapView重绘 windView streakView过大 消耗的内存直线上涨 超过百分之50  结果你懂的;
    sender.selected = !sender.selected;
    if (sender.selected) {
        CGPoint point1  = [self.mapView convertCoordinate:CLLocationCoordinate2DMake(self.windModel.startlat, self.windModel.startlon) toPointToView:self.view];
        CGPoint point2  = [self.mapView convertCoordinate:CLLocationCoordinate2DMake(self.windModel.endlat,self.windModel.endlon) toPointToView:self.view];
        self.streakView = [[WindMotionStreakView alloc]initWithFrame:CGRectMake(point1.x, point2.y, fabs(point2.x - point1.x), fabs(point2.y - point1.y))];
        [self.view insertSubview:self.streakView aboveSubview:self.mapView];
        self.windView   = [[WindView alloc]initWithFrame:self.streakView.frame andMapView:self.mapView andWindMotionStreakView:self.streakView andTYWindDetailModel:self.windModel];
        [self.view insertSubview:self.windView aboveSubview:self.streakView];
    }else{
        [self.streakView removeFromSuperview];
        self.streakView = nil;
        [self.windView windRemoveTime];
        [self.windView removeFromSuperview];
        self.windView   = nil;
    }
}
-(TYWindDetailModel *)windModel{
    if (!_windModel) {
         id jsonObject   = [self getJsonWithResource:@"wind" andType:@"json" andIsCode:NO];
        _windModel       = [TYWindDetailModel yy_modelWithJSON:jsonObject];
    }
    return _windModel;
}
-(id)getJsonWithResource:(NSString *)resource andType:(NSString *)type andIsCode:(BOOL)isCode{
    NSString * path         = [[NSBundle mainBundle]pathForResource:resource ofType:type];
    NSData   * jsonData     = [[NSData alloc] initWithContentsOfFile:path];
    if (isCode){
        NSString * strdata  = [[NSString alloc]initWithData:jsonData encoding:kCFStringEncodingUTF8];
        jsonData            = [strdata dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSError  * error;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    return json;
}
-(MAMapView *)mapView{//地图
    if (!_mapView) {
        _mapView                      = [[MAMapView alloc] initWithFrame:self.view.frame];
        _mapView.delegate             = self;
        _mapView.showsCompass         = NO;
        _mapView.showsScale           = NO;
        _mapView.showsUserLocation    = YES;
        _mapView.rotateEnabled        = NO;
        _mapView.rotateCameraEnabled  = NO;
        _mapView.userTrackingMode     = MAUserTrackingModeFollow;
        _mapView.zoomLevel            = 3;
        _mapView.maxZoomLevel         = 10;
        _mapView.minZoomLevel         = 3;
        _mapView.mapType              = MAMapTypeSatellite;
        _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    }
    return _mapView;
}
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    if (wasUserAction) {//必须放在内 因为高德的这个方法一直在调用 会影响重绘
        if (self.windModel) {
            [self.windView windStop];
        }
    }
}
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if (wasUserAction){//必须放在内 因为高德的这个方法一直在调用 会影响重绘
        if (self.windModel) {
            [self changeFrame];
            [self.windView windRestart];
        }
    }
}
- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction{
    if (wasUserAction) {//必须放在内 因为高德的这个方法一直在调用 会影响重绘
        if (self.windModel) {
            [self.windView windStop];
        }
    }
}
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    if (wasUserAction){//必须放在内 因为高德的这个方法一直在调用 会影响重绘
        if (self.windModel) {
            [self changeFrame];
            [self.windView windRestart];
        }
    }
}
- (void)changeFrame{//调整风场面积 具体情况参考 IMG_1322
    CGPoint point1   = [self.mapView convertCoordinate:CLLocationCoordinate2DMake(self.windModel.startlat, self.windModel.startlon) toPointToView:self.view];
    CGPoint point2   = [self.mapView convertCoordinate:CLLocationCoordinate2DMake(self.windModel.endlat,self.windModel.endlon) toPointToView:self.view];
    CGFloat width    = fabs(point2.x - point1.x);
    CGFloat height   = fabs(point2.x - point1.x);
    //有效宽 有效高
    CGFloat effectwidth  = 0.0;
    CGFloat effectheight = 0.0;
    if (point1.x >= [UIScreen mainScreen].bounds.size.width || point1.x + width <= 0 || point2.y >= [UIScreen mainScreen].bounds.size.height || point2.y + height <= 0) {//超出界面
        effectwidth     = 100.0;
        effectheight    = 100.0;
    }else{
        if (point1.x < 0 && point1.x + width < [UIScreen mainScreen].bounds.size.width){//左边出屏幕 右边未出屏幕
            effectwidth  = point1.x  + width;//
            point1.x     = 0;//x坐标
            if (point2.y < 0 && point2.y + height <[UIScreen mainScreen].bounds.size.height) {//上面出屏幕 下面未出屏幕
                effectheight = point2.y  + height;
                point2.y     = 0;//y坐标
            }else if (point2.y > 0  && point2.y + height >[UIScreen mainScreen].bounds.size.height ){//上面未出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height - point2.y;
            }else if (point2.y > 0  && point2.y + height <[UIScreen mainScreen].bounds.size.height){//上面未出屏幕 下面未出屏幕
                effectheight = height;
            }else if (point2.y < 0 && point2.y + height >[UIScreen mainScreen].bounds.size.height){//上面出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height;
                point2.y     = 0;//y坐标
            }
        }else if (point1.x > 0 && point1.x + width > [UIScreen mainScreen].bounds.size.width){//左边未出屏幕 右边出屏幕
            effectwidth  = [UIScreen mainScreen].bounds.size.width - point1.x;
            if (point2.y < 0 && point2.y + height < [UIScreen mainScreen].bounds.size.height) {//上面出屏幕 下面未出屏幕
                effectheight = point2.y  + height ;
                point2.y     = 0;//y坐标
            }else if (point2.y > 0  && point2.y + height >[UIScreen mainScreen].bounds.size.height ){//上面未出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height - point2.y;
            }else if (point2.y > 0  && point2.y + height < [UIScreen mainScreen].bounds.size.height){//上面未出屏幕 下面未出屏幕
                effectheight = height;
            }else if (point2.y < 0 && point2.y + height >[UIScreen mainScreen].bounds.size.height){//上面出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height;
                point2.y     = 0;//y坐标
            }
        }else if (point1.x > 0 && point1.x + width <[UIScreen mainScreen].bounds.size.width){//左边未出屏幕 右边未出屏幕
            effectwidth  = width;
            if (point2.y < 0 && point2.y + height <[UIScreen mainScreen].bounds.size.height) {//上面出屏幕 下面未出屏幕
                effectheight = point2.y + height;
                point2.y     = 0;//y坐标
            }else if (point2.y > 0  && point2.y + height >[UIScreen mainScreen].bounds.size.height ){//上面未出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height - point2.y;
            }else if (point2.y > 0  && point2.y + height <[UIScreen mainScreen].bounds.size.height){//上面未出屏幕 下面未出屏幕
                effectheight = height;
            }else if (point2.y < 0 && point2.y + height >[UIScreen mainScreen].bounds.size.height){//上面出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height;
                point2.y     = 0;//y坐标
            }
        }else if (point1.x < 0 && point1.x + width >[UIScreen mainScreen].bounds.size.width){//左边出屏幕 右边出屏幕
            effectwidth  = [UIScreen mainScreen].bounds.size.width;
            point1.x     = 0;//x坐标
            if (point2.y < 0 && point2.y + height <[UIScreen mainScreen].bounds.size.height) {//上面出屏幕 下面未出屏幕
                effectheight = point2.y + height;
                point2.y     = 0;//y坐标
            }else if (point2.y > 0  && point2.y + height >[UIScreen mainScreen].bounds.size.height ){//上面未出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height - point2.y;
            }else if (point2.y > 0  && point2.y + height <[UIScreen mainScreen].bounds.size.height){//上面未出屏幕 下面未出屏幕
                effectheight = height;
            } if (point2.y < 0 && point2.y + height >[UIScreen mainScreen].bounds.size.height){//上面出屏幕 下面出屏幕
                effectheight = [UIScreen mainScreen].bounds.size.height;
                point2.y     = 0;//y坐标
            }
        }
    }
    self.streakView.frame = CGRectMake(point1.x, point2.y,effectwidth,effectheight);
    self.windView.frame   = CGRectMake(point1.x, point2.y,effectwidth,effectheight);
}
@end
