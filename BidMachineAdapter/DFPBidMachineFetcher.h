//
//  DFPBidMachineFetcher.h
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 28.10.2019.
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BidMachine.h>


NS_ASSUME_NONNULL_BEGIN

@interface DFPBidMachineFetcher : NSObject

@property (nonatomic, assign) NSNumberFormatterRoundingMode roundingMode;
@property (nonatomic, copy) NSString *format;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedFetcher;
- (nullable NSDictionary <NSString *, id> *)fetchParamsFromRequest:(BDMRequest *)request;
- (nullable id)requestForBidId:(nullable NSString *)bidId;

@end

NS_ASSUME_NONNULL_END
