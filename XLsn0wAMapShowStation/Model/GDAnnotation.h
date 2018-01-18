//
//  GDAnnotation.h
//  AMapDemo
//
//  Created by ginlong on 2018/1/11.
//  Copyright © 2018年 ginlong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
 return nil;
 }
 移除 MAUserLocation
 因为MAUserLocation和GDAnnotation都是遵守<MAAnnotation>
 */
@interface GDAnnotation : NSObject <MAAnnotation>///遵守协议

@property(nonatomic, assign) NSInteger type;///区分层级

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *Id;//可以是区域id 也可以是小区id
@property (nonatomic, strong) NSString *minPrice;//最低价格
@property (nonatomic, strong) NSString *messageAnnoIsBig;//当类型是message的时候。是否被放大了？yes/no

@end
