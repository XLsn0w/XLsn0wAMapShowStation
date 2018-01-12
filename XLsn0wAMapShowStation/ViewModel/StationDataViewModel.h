
#import <Foundation/Foundation.h>

@interface StationDataViewModel : NSObject


/**
 ViewModel 处理加载数据

 @param latitude  纬度
 @param longitude 经度
 @param scale     比例
 @param block     回调数据
 */
+ (void)loadDataWithLatitude:(NSString *)latitude
                andLongitude:(NSString *)longitude
                    andScale:(NSString *)scale
                    andBlock:(void(^)(id result))block;

@end
