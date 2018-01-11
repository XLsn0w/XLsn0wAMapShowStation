//
//  GDAnnotation.h
//  AMapDemo
//
//  Created by ginlong on 2018/1/11.
//  Copyright © 2018年 ginlong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GDAnnotation : NSObject <MAAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *image;
@property(nonatomic, assign) NSInteger type;//在地图找房中1 大区  2 小区
@property(nonatomic, strong) NSString *Id;//可以是区域id 也可以是小区id
@property(nonatomic, strong) NSString *minPrice;//最低价格
@property(nonatomic, strong) NSString *messageAnnoIsBig;//当类型是message的时候。是否被放大了？yes/no

@end
