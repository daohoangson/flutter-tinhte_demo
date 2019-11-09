#import <UIKit/UIKit.h>

@interface FcmService : NSObject

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
