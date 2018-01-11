//
//  RectangleAnnotationView.h
//  AMapDemo
//
//  Created by ginlong on 2018/1/11.
//  Copyright © 2018年 ginlong. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface RectangleAnnotationView : MAAnnotationView

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *messageAnnoIsBig;

-(void)didSelectedAnnotation:(RectangleAnnotationView *)annotation;
-(void)didDeSelectedAnnotation:(RectangleAnnotationView *)annotation;

@end
