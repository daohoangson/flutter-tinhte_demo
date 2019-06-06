#include "AppDelegate.h"
#include "FcmService.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate {
    FcmService *fcmService;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    fcmService = [[FcmService alloc] init];

    [GeneratedPluginRegistrant registerWithRegistry:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [fcmService application:application didReceiveRemoteNotification:userInfo];

    return [super application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

@end
