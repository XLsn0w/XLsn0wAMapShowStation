
#import "StationDataViewModel.h"

@implementation StationDataViewModel

+ (void)loadDataWithLatitude:(NSString *)latitude
                andLongitude:(NSString *)longitude
                    andScale:(NSString *)scale
                    andBlock:(void(^)(id result))block {
    
    
    //模拟一个杭州市数据
    block(@[@{@"latitude" : @"58.3696160000",
              @"longitude" : @"90.3586490000",
              @"count" : @"2",
              @"title" : @"俄罗斯"
              },
  
            @{@"latitude" : @"39.9110666857",
              @"longitude" : @"116.4136103013",
              @"count" : @"2",
              @"title" : @"中国电站"
              }]);
    
}

/*
 39.9110666857,  116.4136103013
 法国 46.1943030000,  3.2290510000
 俄罗斯 58.3696160000,  90.3586490000
 中国：29.8423920000,   120.3796840000
 浙江省   30.2945570162,   120.1621399712
 
 
 
 */

@end
