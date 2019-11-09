#import "FcmService.h"

@import UserNotifications;

@implementation FcmService

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *readNotificationId = [userInfo objectForKey:@"read_notification_id"];
    if (readNotificationId != nil) {
        [self onNotificationRead:readNotificationId];
    }
}

- (void)onNotificationRead:(NSString *)which {
    BOOL isAll = [which isEqualToString:@"all"];
    UNUserNotificationCenter *unc = [UNUserNotificationCenter currentNotificationCenter];
    
    [unc getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {
        int count = 0;
        for (UNNotification* notification in notifications) {
            NSDictionary* userInfo = notification.request.content.userInfo;
            
            NSString *notificationId = [userInfo objectForKey:@"notification_id"];
            if (notificationId == nil) {
                continue;
            }
            
            if (isAll || [which isEqualToString:notificationId]) {
                [unc removeDeliveredNotificationsWithIdentifiers:@[notification.request.identifier]];
                count++;
            }
        }
        
        NSLog(@"onNotificationRead(which=%@) dismissed=%d", which, count);
    }];
}

@end
