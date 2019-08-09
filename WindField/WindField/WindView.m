//
//  WindView.m
//  windDemo
//
//  Created by 龙兴国 on 2019/6/17.
//  Copyright © 2019 龙兴国. All rights reserved.
//

#import "WindView.h"
#import "WindParticle.h"
#import "WeakTargetTimer.h"
@interface WindView ()
//算经纬度专用
@property (nonatomic ,weak)MAMapView            * mapView;
//尾巴专用
@property (nonatomic ,weak)WindMotionStreakView * streakView;
//起始经度
@property (nonatomic,assign) CGFloat   x0;
//起始纬度
@property (nonatomic,assign) CGFloat   y0;
//结束经度
@property (nonatomic,assign) CGFloat   x1;
//结束纬度
@property (nonatomic,assign) CGFloat   y1;
//精确度
@property (nonatomic ,assign)CGFloat   nlon;
//精确度
@property (nonatomic ,assign)CGFloat   nlat;
//最大显示数量
@property (nonatomic,assign) int       partNum;
//列数
@property (nonatomic,assign) NSInteger gridWidth;
//行数
@property (nonatomic,assign) NSInteger gridHeight;
//初始宽
@property (nonatomic,assign) CGFloat   width;
//初始高
@property (nonatomic,assign) CGFloat   height;
//fields数组
@property (nonatomic,strong) NSArray * windfields;
//粒子数组
@property (nonatomic,strong) NSMutableArray * particles;
//定时器
@property (nonatomic,strong) NSTimer * timer;
//暂停
@property (nonatomic,assign) BOOL      remove;
//最大长度
@property (nonatomic,assign) CGFloat   maxLength;
@end
@implementation WindView
- (instancetype)initWithFrame:(CGRect)frame andMapView:(MAMapView *)mapView andWindMotionStreakView:(WindMotionStreakView *)windMotionStreakView andTYWindDetailModel:(TYWindDetailModel *)tyWindDetailModel{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor        = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.mapView                = mapView;
        self.streakView             = windMotionStreakView;
        self.x0                     = tyWindDetailModel.startlon;
        self.x1                     = tyWindDetailModel.endlon;
        self.y0                     = tyWindDetailModel.startlat;
        self.y1                     = tyWindDetailModel.endlat;
        self.nlon                   = tyWindDetailModel.nlon;
        self.nlat                   = tyWindDetailModel.nlat;
        self.partNum                = 1000;
        self.gridWidth              = tyWindDetailModel.lonsize;
        self.gridHeight             = tyWindDetailModel.latsize;
        self.width                  = self.frame.size.width;
        self.height                 = self.frame.size.height;
        [self getWindfieldsWithfFields:tyWindDetailModel.data];
        [self getParticles];
    }
    return self;
}
- (void)getWindfieldsWithfFields:(NSArray * )fields{
    NSArray * arr1       = fields.firstObject;
    NSArray * arr2       = fields.lastObject;
    NSMutableArray * arr = [NSMutableArray array];
    [arr1 enumerateObjectsUsingBlock:^(NSNumber * obj1, NSUInteger idx, BOOL * _Nonnull stop){
        NSNumber * obj2  = arr2[idx];
        CGVector v       = CGVectorMake([obj1 floatValue], [obj2 floatValue]);
        self.maxLength   = MAX(self.maxLength, [self length:v]);
        [arr addObject:[NSValue valueWithCGVector:v]];
    }];
    NSMutableArray * linecolumnArray = [NSMutableArray array];
    for (int i = 0; i < self.gridHeight; i++) {
        NSMutableArray * columnArray = [NSMutableArray array];
        for (int j = 0; j<self.gridWidth;j++){
            [columnArray addObject:arr[i*self.gridWidth +j]];
        }
        [linecolumnArray addObject:columnArray];
    }
    self.windfields = linecolumnArray;
}
-(CGFloat)length:(CGVector)v{
    return sqrt(v.dx*v.dx + v.dy*v.dy);
}
- (void)getParticles{
    [self.particles removeAllObjects];
    if (self.frame.origin.x >=[UIScreen mainScreen].bounds.size.width ||self.frame.origin.x + self.frame.size.width <=0 ||self.frame.origin.y >=[UIScreen mainScreen].bounds.size.height ||self.frame.origin.y +self.frame.size.height<=0) {
        //上下左右都超出了屏幕
    }else{
        if (self.frame.size.width < self.width) {
            self.partNum = 1000;
        }else{
            self.partNum = (int)(1000 * self.frame.size.width * self.frame.size.height)/(self.width * self.height);
        }
        self.partNum  = MIN(self.partNum, 1500);
        for (int i = 0;i <self.partNum;i++){
            WindParticle * particle = [[WindParticle alloc] init];
            particle.maxLength      = self.maxLength;
            [self.particles addObject:particle];
        }
    }
}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (!self.timer){//时间越短 尾巴越长
        self.timer =[WeakTargetTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timeFired) userInfo:nil repeats:YES];
    }
}
-(void)timeFired{
    if (self.particles.count){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.particles enumerateObjectsUsingBlock:^(WindParticle * obj, NSUInteger idx, BOOL *stop){
                [self updateCenter:obj];
                if (idx == self.particles.count - 1){
                    [self setNeedsDisplay];
                }
            }];
        });
    }
}
//更新
-(void)updateCenter:(WindParticle *)particle{
    particle.age--;
    if (particle.age <= 0){
        CGPoint  startCenter    = [self randomParticleCenter];
        CGPoint  startMapPoint  = [self mapPointFromViewPoint:startCenter];
        CGVector startVect      = [self vecorWithPoint:startMapPoint];
        [particle resetWithCenter:startCenter age:[self randomAge] xv:startVect.dx yv:startVect.dy];
    }else{
        CGPoint updateCenter     = CGPointMake(particle.center.x + particle.xv, particle.center.y + (-particle.yv));
        CGPoint updateMapPoint   = [self mapPointFromViewPoint:updateCenter];
        CGRect  disRect          = self.bounds;
        CGRect  disMapRect       = CGRectMake(self.x0, self.y0, self.x1-self.x0, self.y1-self.y0);
        if (!CGRectContainsPoint(disRect, updateCenter) || !CGRectContainsPoint(disMapRect, updateMapPoint)) {//不在范围内 重置
            CGPoint  startCenter    = [self randomParticleCenter];
            CGPoint  startMapPoint  = [self mapPointFromViewPoint:startCenter];
            CGVector startVect      = [self vecorWithPoint:startMapPoint];
            [particle resetWithCenter:startCenter age:[self randomAge] xv:startVect.dx yv:startVect.dy];
        }else{
            CGVector updateVect     = [self vecorWithPoint:updateMapPoint];
            [particle updateWithCenter:updateCenter xv:updateVect.dx yv:updateVect.dy];
        }
    }
}
//在自身范围内随机生成一个点  要保证他在经纬度内并且在屏幕上
-(CGPoint)randomParticleCenter{
    double  a   = rand()/(double)RAND_MAX;//(0-1之间)
    double  b   = rand()/(double)RAND_MAX;
    CGFloat x   = a * self.bounds.size.width;
    CGFloat y   = b * self.bounds.size.height;
    if (self.frame.origin.x + x < 0 || self.frame.origin.x + x > [UIScreen mainScreen].bounds.size.width || self.frame.origin.y + y < 0 || self.frame.origin.y + y > [UIScreen mainScreen].bounds.size.height) {
        return [self randomParticleCenter];
    }else{
       return CGPointMake(x, y);
    }
}
//获取该点在地图上的经纬度
-(CGPoint)mapPointFromViewPoint:(CGPoint)point{
    //相对地图的坐标
    CGPoint  mappoint           = [self convertPoint:point toView:self.mapView];
    //该点相对地图的经纬度
    CLLocationCoordinate2D coor = [self.mapView convertPoint:mappoint toCoordinateFromView:self.mapView];
    return CGPointMake(coor.longitude, coor.latitude);
}
//线性插值
-(CGVector)vecorWithPoint:(CGPoint)mappoint{
    CGFloat   i  = (mappoint.x - self.x0)/self.nlon;
    CGFloat   j  = (mappoint.y - self.y0)/self.nlat;
    NSInteger fi = (int)floor(i);//上一列
    NSInteger ci = fi +1;//下一列
    NSInteger fj = (int)floor(j);//上一行
    NSInteger cj = fj + 1;//下一行
    if (fi < 0 || ci < 0 || fj < 0 || cj < 0 || fi >= self.gridWidth - 1  || fj >= self.gridHeight - 1 ){
        return CGVectorMake(0, 0);
    }
    NSArray * lineArr1  = self.windfields[fj];
    NSValue * value1    = lineArr1[fi];
    CGVector  vect1     = [value1 CGVectorValue];
    NSValue * value2    = lineArr1[ci];
    CGVector  vect2     = [value2 CGVectorValue];
    NSArray * lineArr2  = self.windfields[cj];
    NSValue * value3    = lineArr2[fi];
    CGVector  vect3     = [value3 CGVectorValue];
    NSValue * value4    = lineArr2[ci];
    CGVector  vect4     = [value4 CGVectorValue];
    CGFloat x           = i - fi;
    CGFloat y           = j - fj;
    double  vx          = vect1.dx * (1 - x) * (1 - y) + vect2.dx * x  * (1 - y) + vect3.dx * (1 - x) * y + vect4.dx * x  * y;
    double  vy          = vect1.dy * (1 - x) * (1 - y) + vect2.dy * x  * (1 - y) + vect3.dy * (1 - x) * y + vect4.dy * x  * y;
    return CGVectorMake(vx, vy);
}
-(NSInteger)randomAge{
    return 50 + arc4random_uniform(150);
}
//绘图
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.remove){
        CGContextClearRect(context, self.bounds);
        self.remove = NO;
    }else{
        @autoreleasepool{
            [self.streakView addLayer:self.layer];
        }
        CGContextClearRect(context, self.bounds);
        NSInteger showCount  = 0;
        for (int i = 0; i < self.partNum ; i++){
            WindParticle * particle = [self.particles objectAtIndex:i];
            if (showCount >= self.partNum){
                break;
            }
            if (!particle.isShow){
                particle.age = 0;
                continue;
            }
            if (particle.age >0){
                showCount ++;
                CGContextSaveGState(context);
                CGFloat temp_alpha   = 10.0;
                CGFloat alpha        = particle.age/temp_alpha;
                if (particle.initAge - particle.age <= temp_alpha) {
                    alpha            = (particle.initAge - particle.age)/temp_alpha;
                }
                CGContextSetAlpha(context, alpha);
                //CGFloat f =  particle.age/particle.initAge;根据生命长度做颜色
                //f <= 1 && f >0.8 CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
                if (particle.oldCenter.x != -1){
                    CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
                    CGContextSetLineWidth(context, 1.5);
                    CGPoint newPoint = CGPointMake(particle.center.x, particle.center.y);
                    CGPoint oldPoint = CGPointMake(particle.oldCenter.x, particle.oldCenter.y);
                    CGContextMoveToPoint(context, newPoint.x, newPoint.y);
                    CGContextAddLineToPoint(context, oldPoint.x, oldPoint.y);
                    CGContextStrokePath(context);
                }
                CGContextRestoreGState(context);
            }
        }
    }
}
//停止
-(void)windStop{
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.streakView removelayer1];
    self.remove            = YES;
    [self setNeedsDisplay];
    [self getParticles];
    self.hidden            = YES;
}
//开始
-(void)windRestart{
    [self.timer setFireDate:[NSDate distantPast]];
    self.hidden            = NO;
}
//释放
-(void)windRemoveTime{
    [self.timer invalidate];
    self.timer = nil;
}
//数据源
-(NSMutableArray *)particles{
    if (!_particles) {
        _particles = [NSMutableArray array];
    }
    return _particles;
}
@end

