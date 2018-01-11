
#import "ShowStationViewController.h"

@interface ShowStationViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;//百度地图
@property(nonatomic, strong) AMapLocationManager *locationManager;//定位服务
@property (nonatomic, assign) float zoomValue;//移动或缩放前的比例尺
@property (nonatomic, assign) CLLocationCoordinate2D oldCoor;//地图移动前中心经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) RectangleAnnotationView *messageA;//记录点击过的大头针。便于点击空白时。把这个大头针缩小为原始大小

@end

@implementation ShowStationViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = setWhiteColor;
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
//    [self.mapView viewWillAppear];
    self.mapView.delegate = self; //
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
}

- (void)viewWillDisappear:(BOOL)animated {
//    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locationManager.delegate = nil;
    [self.locationManager startUpdatingHeading];
  
}
- (void)dealloc {
    if (self.mapView) {
        self.mapView = nil;
    }
    if (self.locationManager) {
        self.locationManager.delegate = nil;
    }
}

#pragma mark -- UI

- (void)setupUI {

    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.mapView];
    
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
  
    
 
//    self.mapView.mapScaleBarPosition = CGPointMake(10, 75);//比例尺位置
    self.mapView.minZoomLevel = 8;
    self.mapView.maxZoomLevel = 14;
//    self.mapView.isSelectedAnnotationViewFront = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    [self.locationManager startUpdatingHeading];
    //开启持续定位
//    [self.locationManager startUpdatingLocation];
    
    //创建编码对象
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"杭州" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil || placemarks.count == 0) {
            return;
        }
        //创建placemark对象
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"%f,%f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
        //赋值详细地址
        NSLog(@"详细地址 %@",placemark.name);
        CLLocationCoordinate2D coor;
        coor.latitude = placemark.location.coordinate.latitude;
        coor.longitude = placemark.location.coordinate.longitude;
        [self.mapView setCenterCoordinate:coor];
        [self.mapView setZoomLevel:12];
        self.zoomValue = 12;
    }];

    
    
    //请求   3000代表大区  1000小区
    [self loadCityAreaHouseWithScale:@"3000"
                         andLatitude:@""
                        andLongitude:@""
                            andBlock:^{
        
    }];
    
}

- (void)loadCityAreaHouseWithScale:(NSString *)scale
                       andLatitude:(NSString *)latitude
                      andLongitude:(NSString *)longitude
                          andBlock:(void(^)(void))block {
    WeakSelf
    [StationDataViewModel loadDataWithLatitude:latitude
                                  andLongitude:longitude
                                      andScale:scale
                                      andBlock:^(id result) {
                                               NSArray *dataArray = result;
                                               
                                               if (dataArray.count > 0) {
                                                   [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
                                                   
                                                   if ([scale isEqualToString:@"3000"]) {//请求大区
                                                       for (NSDictionary *dic in dataArray) {
                                                           GDAnnotation *an = [[GDAnnotation alloc] init];
                                                           CLLocationCoordinate2D coor;
                                                           coor.latitude = [dic[@"latitude"] floatValue];
                                                           coor.longitude = [dic[@"longitude"] floatValue];
                                                           an.type = 1;
                                                           an.coordinate = coor;
                                                           an.title = dic[@"title"];
                                                           an.subtitle = [NSString stringWithFormat:@"%@个",dic[@"count"]];
                                                           an.Id = dic[@"id"];
                                                           [weakSelf.mapView addAnnotation:an];
                                                       }
                                                       
                                                   }else if([scale isEqualToString:@"1000"]) {//请求小区
                                                       
                                                       NSArray *smallArray = @[@{@"latitude" : @"30.2739363924",
                                                                                 @"longitude" : @"120.1444124581",
                                                                                 @"count" : @"5",
                                                                                 @"title" : @"黄龙电站"
                                                                                 },
                                                                               @{@"latitude" : @"30.2784934383",
                                                                                 @"longitude" : @"120.1580622499",
                                                                                 @"count" : @"5",
                                                                                 @"title" : @"宁波大厦电站"
                                                                                 },
                                                                               
                                                                               @{@"latitude" : @"30.1899729029",
                                                                                 @"longitude" : @"120.1743670866",
                                                                                 @"count" : @"11",
                                                                                 @"title" : @"宝龙广场电站"
                                                                                 },
                                                                               @{@"latitude" : @"30.1847000403",
                                                                                 @"longitude" : @"120.1905884848",
                                                                                 @"count" : @"5",
                                                                                 @"title" : @"长江西苑电站"
                                                                                 },
                                                                               @{@"latitude" : @"30.2011656182",
                                                                                 @"longitude" : @"120.1865363843",
                                                                                 @"count" : @"11",
                                                                                 @"title" : @"香溢公寓电站"
                                                                                 }];
                                                       
                                                       for (NSDictionary *dic in smallArray) {
                                                           
                                                           GDAnnotation *an = [[GDAnnotation alloc] init];
                                                           CLLocationCoordinate2D coor;
                                                           coor.latitude = [dic[@"latitude"] floatValue];
                                                           coor.longitude = [dic[@"longitude"] floatValue];
                                                           an.type = 2;
                                                           an.coordinate = coor;
                                                           an.title = dic[@"title"];
                           
                                                           
                                                           [weakSelf.mapView addAnnotation:an];
                                                       }
                                                   }
                                                   block();
                                               }else {
                                                   
                                                   
                                                   NSLog(@"无房源！");
                                               }
                                           }];
}


#pragma mark -- 回到用户的位置。
- (void)backUserLocation {
    //移动到用户的位置
    [self.mapView setCenterCoordinate:self.coordinate animated:YES];
}

#pragma mark -- BMMapViewDelegate
/**
 * @brief 地图区域即将改变时会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.zoomValue = mapView.zoomLevel;
    self.oldCoor = mapView.centerCoordinate;
    NSLog(@"之前的比例尺：%f",mapView.zoomLevel);
}

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSLog(@"更改了区域");
    NSLog(@"当前比例尺%f，过去比例尺：%f",mapView.zoomLevel,self.zoomValue);
    if (mapView.zoomLevel > self.zoomValue) {
        NSLog(@"地图放大了");
    }else if (mapView.zoomLevel < self.zoomValue){
        NSLog(@"地图缩小了");
    }
    
    if (mapView.zoomLevel >12) {
        //请求小区
        //当没有放大缩小 计算平移的距离。当距离小于2千米。不再进行计算  避免过度消耗
        float distance = [self distanceBetweenFromCoor:self.oldCoor toCoor:mapView.centerCoordinate];
        if (distance <= 1000 && mapView.zoomLevel == self.zoomValue) {
            return;
        }
        [self loadCityAreaHouseWithScale:@"1000"
                             andLatitude:[NSString stringWithFormat:@"%f",mapView.centerCoordinate.latitude]
                            andLongitude:[NSString stringWithFormat:@"%f",mapView.centerCoordinate.longitude]
                                andBlock:^{
            
        }];

    }else if(mapView.zoomLevel <= 12) {
        if (mapView.zoomLevel == self.zoomValue) {//当平移地图。大区不再重复请求
            return;
        }
        //请求大区
        [self loadCityAreaHouseWithScale:@"3000"
                             andLatitude:@"30.287459"
                            andLongitude:@"120.153576"
                                andBlock:^{
            
        }];
    }
}

//使用苹果原生库计算两个经纬度直接的距离

- (double)distanceBetweenFromCoor:(CLLocationCoordinate2D)coor1 toCoor:(CLLocationCoordinate2D)coor2 {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:coor1.latitude longitude:coor1.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:coor2.latitude longitude:coor2.longitude];
    double distance  = [curLocation distanceFromLocation:otherLocation];
    return distance;
}
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(AMapLocationManager *)userLocation {
  
    
}

//地图渲染完毕
/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    
    
    //避免屏幕内没有房源-->计算屏幕右上角、左下角经纬度-->获取这个区域内所有的大头针-->判断有没有大头针-->若屏幕内没有，但整个地图中存在大头针-->移动中心点到这个大头针
    MACoordinateBounds coorbBound;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    northEast = [mapView convertPoint:CGPointMake(kScreenWidth, 0) toCoordinateFromView:mapView];
    southWest = [mapView convertPoint:CGPointMake(0, kScreenHeight) toCoordinateFromView:mapView];
    coorbBound.northEast = northEast;
    coorbBound.southWest = southWest;
    
//    NSArray *annotations = [mapView annotationsInCoordinateBounds:coorbBound];
    
    NSArray *annotations = [mapView annotations];
    
    if (annotations.count == 0 && mapView.annotations.count > 0 && mapView.zoomLevel != self.zoomValue) {
        GDAnnotation *firstAnno = mapView.annotations.firstObject;
        
        //如果是个人位置的大头针。那么如果地图中大头针个数又大于1.取最后一个；否则return
        if (firstAnno.coordinate.latitude == self.coordinate.latitude) {
            NSLog(@"这是个个人位置大头针");
            if (mapView.annotations.count > 1) {
                firstAnno = mapView.annotations.lastObject;
            }else {
                return;
            }
        }
        [mapView setCenterCoordinate:firstAnno.coordinate animated:NO];
    }
    
}

/**
 * @brief 根据anntation生成对应的View。
 
 注意：
 1、5.1.0后由于定位蓝点增加了平滑移动功能，如果在开启定位的情况先添加annotation，需要在此回调方法中判断annotation是否为MAUserLocation，从而返回正确的View。
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
 return nil;
 }
 
 2、请不要在此回调中对annotation进行select和deselect操作，此时annotationView还未添加到mapview。
 
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    GDAnnotation *anno = (GDAnnotation *)annotation;

    if (anno.type == 1) {
        NSString *AnnotationViewID = @"RoundAnnotationView";
        // 检查是否有重用的缓存
        RoundAnnotationView *annotationView = (RoundAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        

        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[RoundAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
         
            
        }

        annotationView.title = anno.title;
        annotationView.subTitle = anno.subtitle;

        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        return annotationView;
        
    }else {
        
        NSString *AnnotationViewID = @"RectangleAnnotationView";
        // 检查是否有重用的缓存
        RectangleAnnotationView *annotationView = (RectangleAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[RectangleAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
          
            
        }
        // 设置偏移位置--->向上左偏移
        annotationView.centerOffset = CGPointMake(annotationView.frame.size.width * 0.5, -(annotationView.frame.size.height * 0.5));
        annotationView.title = anno.title;
        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
}
-(void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    //输出的是模拟器的坐标
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    self.coordinate = coordinate2D;
    _mapView.centerCoordinate = coordinate2D;
    
}



//点击了大头针
/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    if (view.annotation.coordinate.latitude == self.coordinate.latitude) {//个人位置特殊处理，否则类型不匹配崩溃
        NSLog(@"点击了个人位置");
        return;
    }
    
    GDAnnotation *annotationView = (GDAnnotation *)view.annotation;

    if (annotationView.type == 2) {
        
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        
        //让点击的大头针放大效果
        [messageAnno didSelectedAnnotation:messageAnno];
        
        self.messageA = messageAnno;
        annotationView.messageAnnoIsBig = @"yes";
        //取消大头针的选中状态，否则下次再点击同一个则无法响应事件
//        [mapView deselectAnnotation:annotationView animated:NO];
        //计算距离 --> 请求列表数据 --> 完成 --> 展示表格
//        self.communityId = annotationView.Id;

    }else {
        //点击了区域--->进入小区
        //拿到大头针经纬度，放大地图。然后重新计算小区
        [mapView setCenterCoordinate:annotationView.coordinate animated:NO];
        [mapView setZoomLevel:16];
    }
}

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    GDAnnotation *annotationView = (GDAnnotation *)view.annotation;
    if (annotationView.type == 2) {
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        annotationView.messageAnnoIsBig = @"no";
        [messageAnno didDeSelectedAnnotation:messageAnno];
        [mapView reloadMap];
    }

}

@end
