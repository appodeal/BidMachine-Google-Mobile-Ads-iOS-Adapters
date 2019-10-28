//
//  AdManagerViewController.m
//  AdMobBidMachineSample
//
//  Created by Stas Kochkin on 28.10.2019.
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "AdManagerViewController.h"
#import "DFPBidMachineFetcher.h"
#import "GADBidMachineNetworkExtras.h"

#import <BidMachine/BidMachine.h>
#import <GoogleMobileAds/DFPRequest.h>
#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import <GoogleMobileAds/GoogleMobileAds.h>


@interface AdManagerViewController () <BDMRequestDelegate, GADBannerViewDelegate, GADInterstitialDelegate, GADRewardedAdDelegate>

@property (nonatomic, strong) NSHashTable <BDMRequest *> *requests;
@property (nonatomic, strong) DFPBannerView *bannerView;
@property (nonatomic, strong) DFPInterstitial *interstitial;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;

@property (weak, nonatomic) IBOutlet UIButton *showInterstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *showRewardedButton;

@end

@implementation AdManagerViewController

- (NSHashTable<BDMRequest *> *)requests {
    if (!_requests) {
        _requests = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _requests;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startBidMachine];
}

- (void)startBidMachine {
    DFPBidMachineFetcher.sharedFetcher.roundingMode = NSNumberFormatterRoundDown;
    DFPBidMachineFetcher.sharedFetcher.format = @"0.00";
}

#pragma mark - IBAction

- (IBAction)loadBanner:(id)sender {
    BDMBannerRequest *request = [BDMBannerRequest new];
    [request performWithDelegate:self];
    [self.requests addObject:request];
}

- (IBAction)loadInterstitial:(id)sender {
    BDMInterstitialRequest *request = [BDMInterstitialRequest new];
    BDMPriceFloor *pf = [BDMPriceFloor new];
    pf.value = [[NSDecimalNumber alloc] initWithDecimal:[@0.1 decimalValue]];
    request.priceFloors = @[ pf ];
    [request performWithDelegate:self];
    [self.requests addObject:request];
}

- (IBAction)loadRewarded:(id)sender {
    BDMRewardedRequest *request = [BDMRewardedRequest new];
    [request performWithDelegate:self];
    [self.requests addObject:request];
}

- (IBAction)showInterstitial:(id)sender {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (IBAction)showRewarded:(id)sender {
    if ([self.rewardedAd isReady]) {
        [self.rewardedAd presentFromRootViewController:self
                                              delegate:self];
    }
}

#pragma mark - AdManager

- (void)loadDFPBannerView:(DFPRequest *)request {
    self.bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.delegate = self;
    self.bannerView.rootViewController = self;
    self.bannerView.adUnitID = @"YOUR_AD_UNIT";
    [self.bannerView loadRequest:request];
}

- (void)loadDFPInterstitial:(DFPRequest *)request {
    self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:@"YOUR_AD_UNIT"];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:request];
}

- (void)loadDFPRewardedVideo:(DFPRequest *)request {
    self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:@"YOUR_AD_UNIT"];
    [self.rewardedAd loadRequest:request completionHandler:^(GADRequestError *error) {
        NSLog(error ? @"Rewarded ad failed": @"Rearded ad did load");
    }];
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    // After request complete loading application can lost strong ref on it
    // BidMachineFetcher will capture request by itself
    [self.requests removeObject:request];
    // Get extras from fetcher
    // After whith call fetcher will has strong ref on request
    NSDictionary *customTargeting = [DFPBidMachineFetcher.sharedFetcher fetchParamsFromRequest:request];
    DFPRequest *dfpRequest = [DFPRequest request];
    dfpRequest.customTargeting = customTargeting;
    // Set extras for local bid id matching
    GADCustomEventExtras *extras = [GADCustomEventExtras new];
    GADBidMachineNetworkExtras *bmExtras = [GADBidMachineNetworkExtras new];
    bmExtras.bidID = request.info.bidID;
    [extras setExtras:bmExtras.allExtras forLabel:@"BidMachine"];
    [dfpRequest registerAdNetworkExtras:extras];
    
    if ([request isKindOfClass:BDMBannerRequest.class]) {
        [self loadDFPBannerView:dfpRequest];
    } else if ([request isKindOfClass:BDMInterstitialRequest.class]) {
        [self loadDFPInterstitial:dfpRequest];
    } else if ([request isKindOfClass:BDMRewardedRequest.class]) {
        [self loadDFPRewardedVideo:dfpRequest];
    }
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    // In case request failed we can release it
    // and build some retry logic
    [self.requests removeObject:request];
}

- (void)requestDidExpire:(BDMRequest *)request {}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self.bannerView removeFromSuperview];
    [self.view addSubview:bannerView];
    bannerView.translatesAutoresizingMaskIntoConstraints = false;
    if (@available(iOS 11, *)) {
        [bannerView.bottomAnchor constraintEqualToAnchor:bannerView.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [bannerView.bottomAnchor constraintEqualToAnchor:bannerView.bottomAnchor].active = YES;
    }
    [bannerView.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor].active = YES;
    [bannerView.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor].active = YES;
    [bannerView.heightAnchor constraintEqualToConstant:bannerView.adSize.size.height].active = YES;
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"Interstitial did load");
}

#pragma mark - GADRewardedAdDelegate

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    NSLog(@"User did earh reward: %@", reward);
}

@end
