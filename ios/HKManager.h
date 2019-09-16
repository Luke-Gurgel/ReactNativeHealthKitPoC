//
//  HKManager.h
//  HealthKitPoc
//
//  Created by Luke Gurgel on 9/16/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKManager: RCTEventEmitter<RCTBridgeModule>

- (void) cyclingDataDidChange: (NSArray<__kindof HKQuantitySample *> *) cyclingSamples;
- (NSDictionary *) parseCyclingData: (HKQuantitySample *) cyclingSample;
- (NSArray<__kindof NSDictionary *> *) gatherCyclingSamples: (NSArray<__kindof HKQuantitySample *> *) cyclingSamples;

@end

NS_ASSUME_NONNULL_END
