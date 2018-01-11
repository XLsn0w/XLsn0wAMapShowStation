
#import "StationDataViewModel.h"

@implementation StationDataViewModel

+ (void)loadDataWithLatitude:(NSString *)latitude
                andLongitude:(NSString *)longitude
                    andScale:(NSString *)scale
                    andBlock:(void(^)(id result))block {
    
    
    //模拟一个杭州市数据
    block(@[@{@"latitude" : @"30.2773074061",
              @"longitude" : @"120.1522257631",
              @"count" : @"2",
              @"title" : @"西湖电站"
              },
            
            @{@"latitude" : @"30.1959745592",
              @"longitude" : @"120.1840553079",
              @"count" : @"3",
              @"title" : @"滨江电站"
              }]);
    
}

@end
