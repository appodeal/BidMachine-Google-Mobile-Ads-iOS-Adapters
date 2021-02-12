//
//  AppDelegate.m
//  AdMobBidMachineSample
//
//  Created by Yaroslav Skachkov on 5/14/19.
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "AppDelegate.h"
#import "GADBidMachineUtils.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <BidMachine/BidMachine.h>

@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (GADBidMachineUtils.sharedUtils.isAdManagerApp) {
        [self startAsAdManagerApp];
    } else {
        [self startAsDefault];
    }
    return YES;
}

- (void)startAsDefault {
    // Start Google Mobile Ads first
    [GADMobileAds.sharedInstance startWithCompletionHandler:^(GADInitializationStatus *status) {
        NSDictionary *statuses = status.adapterStatusesByClassName;
        NSLog(@"%@", [statuses.allKeys componentsJoinedByString:@","]);
    }];
    [self setupWindowWithController:@"DefaultViewController"];
}

- (void)startAsAdManagerApp {
    // Start BidMachine first
    BDMSdkConfiguration *config = [BDMSdkConfiguration new];
    config.testMode = YES;
    [BDMSdk.sharedSdk startSessionWithSellerID:@"1"
                                 configuration:config
                                    completion:^{
        // Then start ad manager
        [GADMobileAds.sharedInstance startWithCompletionHandler:^(GADInitializationStatus *status) {
            NSDictionary *statuses = status.adapterStatusesByClassName;
            NSLog(@"%@", [statuses.allKeys componentsJoinedByString:@","]);
        }];
    }];
    [self setupWindowWithController:@"AdManagerViewController"];
}

- (void)setupWindowWithController:(NSString *)controlerIdentifier {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:bundle];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:controlerIdentifier];
    [self.window makeKeyAndVisible];
}

@end
