
#import "ShowStationViewController.h"

@interface ShowStationViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) MAMapView *gaodeMapview;
@property (nonatomic, strong) MKMapView *appleMapview;

@property (nonatomic, assign) BOOL isSwitching;

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
    [self initMAMapViewUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.gaodeMapview.delegate = self;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.gaodeMapview.delegate = nil; // 不用时，置nil
    self.locationManager.delegate = nil;
    [self.locationManager startUpdatingHeading];
}

- (void)dealloc {
    if (self.gaodeMapview) {
        self.gaodeMapview = nil;
    }
    if (self.locationManager) {
        self.locationManager.delegate = nil;
    }
}

#pragma mark -- UI

- (void)initMAMapViewUI {

    
    self.gaodeMapview = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.gaodeMapview];
    self.gaodeMapview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    ///AMapLocationManager
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.gaodeMapview.delegate = self;
    self.gaodeMapview.showsUserLocation = YES;
  
    
//    self.mapView.mapScaleBarPosition = CGPointMake(10, 75);//比例尺位置
    self.gaodeMapview.minZoomLevel = 3;
    self.gaodeMapview.maxZoomLevel = 14;
//    self.mapView.isSelectedAnnotationViewFront = YES;
    self.gaodeMapview.userTrackingMode = MAUserTrackingModeNone;
    [self.locationManager startUpdatingHeading];
    //开启持续定位
//    [self.locationManager startUpdatingLocation];
    
    ///AppleMap
    self.appleMapview = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.appleMapview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.appleMapview.delegate = self;
    [self.view addSubview:self.appleMapview];
    [self.appleMapview setHidden:YES];
    
    
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
        [self.gaodeMapview setCenterCoordinate:coor];
        self.zoomValue = 3;
        [self.gaodeMapview setZoomLevel:self.zoomValue];
    }];
}

/**
 执行切换
 */
- (void)performSwitching {
    self.isSwitching = YES;
    
    [self.gaodeMapview setHidden:!self.gaodeMapview.isHidden];
    [self.appleMapview setHidden:!self.appleMapview.isHidden];
    
    if(!self.gaodeMapview.isHidden) {
        MACoordinateRegion region = [self MARegionForMKRegion:self.appleMapview.region];
        [self.gaodeMapview setRegion:region];
        
        self.gaodeMapview.centerCoordinate = self.appleMapview.centerCoordinate;
        
        [self.gaodeMapview setRotationDegree:self.appleMapview.camera.heading];
    } else {
        MKCoordinateRegion region = [self MKRegionForMARegion:self.gaodeMapview.region];
        [self.appleMapview setRegion:region];
        
        self.appleMapview.centerCoordinate = self.gaodeMapview.centerCoordinate;
        
        [self.appleMapview.camera setHeading:self.gaodeMapview.rotationDegree];
    }
}

/**
 高德地图转苹果地图
 */
- (MKCoordinateRegion)MKRegionForMARegion:(MACoordinateRegion)maRegion {
    MKCoordinateRegion mkRegion = MKCoordinateRegionMake(maRegion.center, MKCoordinateSpanMake(maRegion.span.latitudeDelta, maRegion.span.longitudeDelta));
    
    return mkRegion;
}

/**
 苹果地图转高德地图
 */
- (MACoordinateRegion)MARegionForMKRegion:(MKCoordinateRegion)mkRegion {
    MACoordinateRegion maRegion = MACoordinateRegionMake(mkRegion.center, MACoordinateSpanMake(mkRegion.span.latitudeDelta, mkRegion.span.longitudeDelta));
    
    
    if(maRegion.center.latitude + maRegion.span.latitudeDelta / 2 > 90) {
        maRegion.span.latitudeDelta = (90.0 - maRegion.center.latitude) / 2;
    }
    if(maRegion.center.longitude + maRegion.span.longitudeDelta / 2 > 180) {
        maRegion.span.longitudeDelta = (180.0 - maRegion.center.longitude) / 2;
    }
    
    return maRegion;
}




#pragma mark -- 回到用户的位置。
- (void)backUserLocation {
    //移动到用户的位置
    [self.gaodeMapview setCenterCoordinate:self.coordinate animated:YES];
}

#pragma mark -- MAMapViewDelegate
/**
 * @brief 地图区域即将改变时会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(UIView *)mapView regionWillChangeAnimated:(BOOL)animated {
        if(mapView.isHidden) {
            return;
        }
    
        if(self.isSwitching) {
            self.isSwitching = NO;
            return;
        }
    
        if([mapView isKindOfClass:[MAMapView class]]) {///高德
            MAMapView *gd_mapView = (MAMapView *)mapView;
            self.zoomValue = gd_mapView.zoomLevel;
            self.oldCoor = gd_mapView.centerCoordinate;
            NSLog(@"之前的比例尺：%f", gd_mapView.zoomLevel);
        } else {

        }

}

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(UIView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if(mapView.isHidden) {
        return;
    }
    
    if(self.isSwitching) {
        self.isSwitching = NO;
        return;
    }
    
    if([mapView isKindOfClass:[MAMapView class]]) {
        
        MAMapView *_mapView = (MAMapView *)mapView;
        NSLog(@"更改了区域");
        NSLog(@"当前比例尺%f，过去比例尺：%f",_mapView.zoomLevel,self.zoomValue);
        if (_mapView.zoomLevel > self.zoomValue) {
            NSLog(@"地图放大了");
        }else if (_mapView.zoomLevel < self.zoomValue){
            NSLog(@"地图缩小了");
        }
        
        if(_mapView.zoomLevel < 4.5) {///中国
            if (_mapView.zoomLevel == self.zoomValue) {//当平移地图。大区不再重复请求
                return;
            }
            //请求大区
            [self loadCityAreaHouseWithScale:@"country"
                                 andLatitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude]
                                andLongitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude]
                                    andBlock:^{
                                        
                                    }];
        } else if(_mapView.zoomLevel > 4.6 && _mapView.zoomLevel <= 6.5) {///浙江
            if (_mapView.zoomLevel == self.zoomValue) {//当平移地图。大区不再重复请求
                return;
            }
            [self loadCityAreaHouseWithScale:@"province"
                                 andLatitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude]
                                andLongitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude]
                                    andBlock:^{
                                        
                                    }];
        } else if(_mapView.zoomLevel > 6.5 && _mapView.zoomLevel <= 7.5) {///杭州
            if (_mapView.zoomLevel == self.zoomValue) {//当平移地图。大区不再重复请求
                return;
            }
            [self loadCityAreaHouseWithScale:@"city"
                                 andLatitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude]
                                andLongitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude]
                                    andBlock:^{
                                        
                                    }];
        } else  if (_mapView.zoomLevel > 7.5) {///具体多个
            
            //当没有放大缩小 计算平移的距离。当距离小于2千米。不再进行计算  避免过度消耗
            float distance = [self distanceBetweenFromCoor:self.oldCoor toCoor:_mapView.centerCoordinate];
            if (distance <= 1000 && _mapView.zoomLevel == self.zoomValue) {
                return;
            }
            [self loadCityAreaHouseWithScale:@"list"
                                 andLatitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude]
                                andLongitude:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude]
                                    andBlock:^{
                                        
                                    }];
            
        }
        
        if(!AMapDataAvailableForCoordinate(self.gaodeMapview.centerCoordinate)) {
            [self performSwitching];
            
        }
    } else {
        if(AMapDataAvailableForCoordinate(self.appleMapview.centerCoordinate)) {
            [self performSwitching];
            
        }
    }
    
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
                                              [weakSelf.gaodeMapview removeAnnotations:weakSelf.gaodeMapview.annotations];
                                              
                                              if ([scale isEqualToString:@"country"]) {///中国
                                                  for (NSDictionary *dic in dataArray) {
                                                      GDAnnotation *an = [[GDAnnotation alloc] init];
                                                      CLLocationCoordinate2D coor;
                                                      coor.latitude = [dic[@"latitude"] floatValue];
                                                      coor.longitude = [dic[@"longitude"] floatValue];
                                                      an.type = 0;
                                                      an.coordinate = coor;
                                                      an.title = dic[@"title"];
                                                      an.subtitle = [NSString stringWithFormat:@"%@个",dic[@"count"]];
                                                      an.Id = dic[@"id"];
                                                      [weakSelf.gaodeMapview addAnnotation:an];
                                                  }
                                                  
                                              } else if([scale isEqualToString:@"province"]) {///浙江省
                                                  ///模拟假数据 实际操作是dataArray 29.3382485990, 120.3734912522
                                                  NSArray *smallArray = @[@{@"latitude" : @"29.3382485990",
                                                                            @"longitude" : @"120.3734912522",
                                                                            @"count" : @"1",
                                                                            @"title" : @"浙江省"
                                                                            }];
                                                  
                                                  for (NSDictionary *dic in smallArray) {
                                                      
                                                      GDAnnotation *an = [[GDAnnotation alloc] init];
                                                      CLLocationCoordinate2D coor;
                                                      coor.latitude = [dic[@"latitude"] floatValue];
                                                      coor.longitude = [dic[@"longitude"] floatValue];
                                                      an.type = 1;
                                                      an.coordinate = coor;
                                                      an.title = dic[@"title"];
                                                      an.subtitle = [NSString stringWithFormat:@"%@个",dic[@"count"]];
                                                      
                                                      [weakSelf.gaodeMapview addAnnotation:an];
                                                  }
                                                  
                                              } else if([scale isEqualToString:@"city"]) {///杭州
                                                  ///模拟假数据 实际操作是dataArray 30.2956048360,  120.2191479035
                                                  NSArray *smallArray = @[@{@"latitude" : @"30.2956048360",
                                                                            @"longitude" : @"120.2191479035",
                                                                            @"count" : @"1",
                                                                            @"title" : @"杭州市"
                                                                            }];
                                                  
                                                  for (NSDictionary *dic in smallArray) {
                                                      
                                                      GDAnnotation *an = [[GDAnnotation alloc] init];
                                                      CLLocationCoordinate2D coor;
                                                      coor.latitude = [dic[@"latitude"] floatValue];
                                                      coor.longitude = [dic[@"longitude"] floatValue];
                                                      an.type = 2;
                                                      an.coordinate = coor;
                                                      an.title = dic[@"title"];
                                                      an.subtitle = [NSString stringWithFormat:@"%@个",dic[@"count"]];
                                                      
                                                      [weakSelf.gaodeMapview addAnnotation:an];
                                                  }
                                                  
                                              } else if ([scale isEqualToString:@"list"]) {///杭州
                                                  
                                                  ///模拟假数据 实际操作是dataArray
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
                                                      an.type = 3;
                                                      an.coordinate = coor;
                                                      an.title = dic[@"title"];
                                                      
                                                      
                                                      [weakSelf.gaodeMapview addAnnotation:an];
                                                  }
                                              }
                                              block();
                                              
                                              
                                          } else {
                                              NSLog(@"无房源！");
                                          }
                                      }];
}


/// 使用苹果原生库计算两个经纬度直接的距离
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

#pragma mark - 点击AnnotationView大头针 数据源方法

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

    if (anno.type == 0 || anno.type == 1 || anno.type == 2) {
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
        
    } else {
        
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

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    //输出的是模拟器的坐标
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    self.coordinate = coordinate2D;
    self.gaodeMapview.centerCoordinate = coordinate2D;
    
}


#pragma mark - 点击AnnotationView大头针事件

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

    if (annotationView.type == 3) {
        
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        
        //让点击的大头针放大效果
        [messageAnno didSelectedAnnotation:messageAnno];
        
        self.messageA = messageAnno;
        annotationView.messageAnnoIsBig = @"yes";
        //取消大头针的选中状态，否则下次再点击同一个则无法响应事件
//        [mapView deselectAnnotation:annotationView animated:NO];
        //计算距离 --> 请求列表数据 --> 完成 --> 展示表格
//        self.communityId = annotationView.Id;

    } else if (annotationView.type == 0) {
        
    } else {
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
    if (annotationView.type == 3) {
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        annotationView.messageAnnoIsBig = @"no";
        [messageAnno didDeSelectedAnnotation:messageAnno];
        [mapView reloadMap];
    }
}

@end
