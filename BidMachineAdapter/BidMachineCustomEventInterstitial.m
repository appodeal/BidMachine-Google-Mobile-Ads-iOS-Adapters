//
//  BidMachineCustomEventInterstitial.m
//  BidMachineAdapter
//
//  Created by Yaroslav Skachkov on 5/15/19.
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "BidMachineCustomEventInterstitial.h"
#import "GADBidMachineUtils+Request.h"
#import <BidMachine/BidMachine.h>


@interface BidMachineCustomEventInterstitial () <BDMInterstitialDelegate>

@property (nonatomic, strong) BDMInterstitial *interstitial;

@end


@implementation BidMachineCustomEventInterstitial

- (void)requestInterstitialAdWithParameter:(nullable NSString *)serverParameter
                                     label:(nullable NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestInfo = [[GADBidMachineUtils sharedUtils] requestInfoFrom:serverParameter request:request];
    [[GADBidMachineUtils sharedUtils] initializeBidMachineWithRequestInfo:requestInfo completion:^(NSError *error) {
        weakSelf.interstitial.delegate = weakSelf;
        BDMInterstitialRequest *interstitialRequest = [[GADBidMachineUtils sharedUtils] interstitialRequestWithRequestInfo:requestInfo];
        [weakSelf.interstitial populateWithRequest:interstitialRequest];
    }];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if ([self.interstitial isLoaded]) {
        [self.interstitial presentFromRootViewController:rootViewController];
    }
}

#pragma mark - Lazy

- (BDMInterstitial *)interstitial {
    if (!_interstitial) {
        _interstitial = [BDMInterstitial new];
    }
    return _interstitial;
}

#pragma mark - BDMInterstitialDelegate

- (void)interstitialReadyToPresent:(BDMInterstitial *)interstitial {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)interstitial:(BDMInterstitial *)interstitial failedWithError:(NSError *)error {
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)interstitialWillPresent:(BDMInterstitial *)interstitial {
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)interstitial:(BDMInterstitial *)interstitial failedToPresentWithError:(NSError *)error {
    // The Google Mobile Ads SDK does not have an equivalent callback.
    NSLog(@"Interstitial failed to present!");
}

- (void)interstitialDidDismiss:(BDMInterstitial *)interstitial {
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)interstitialRecieveUserInteraction:(BDMInterstitial *)interstitial {
    [self.delegate customEventInterstitialWasClicked:self];
}

@end
