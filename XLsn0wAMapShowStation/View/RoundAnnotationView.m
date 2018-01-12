//
//  RoundAnnotationView.m
//  AMapDemo
//
//  Created by ginlong on 2018/1/11.
//  Copyright © 2018年 ginlong. All rights reserved.
//

#import "RoundAnnotationView.h"

@interface RoundAnnotationView ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation RoundAnnotationView

///自定义AnnotationView
- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self setBounds:CGRectMake(0.f, 0.f, 80, 80)];
        [self setContentView];
    }
    return self;
}

- (void)setContentView {
    
    self.layer.cornerRadius = 40;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:234/255. green:130/255. blue:80/255. alpha:1];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 20)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = font(15);
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.layer.masksToBounds = YES;
    [self addSubview:self.titleLabel];

    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.frame), 20)];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = font(13);
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.layer.masksToBounds = YES;
    [self addSubview:self.subTitleLabel];
    
    
    
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}
- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    self.subTitleLabel.text = subTitle;
}


@end
