
#import <Foundation/Foundation.h>

@interface StationDataViewModel : NSObject

+ (void)loadDataWithLatitude:(NSString *)latitude
                andLongitude:(NSString *)longitude
                    andScale:(NSString *)scale
                    andBlock:(void(^)(id result))block;

@end
