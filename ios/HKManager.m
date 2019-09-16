//
//  HKManager.m
//  HealthKitPoc
//
//  Created by Luke Gurgel on 9/16/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "HKManager.h"

@implementation HKManager

RCT_EXPORT_MODULE();

// allocWithZone -> github.com/facebook/react-native/issues/15421#issuecomment-335346159

+ (id) allocWithZone: (NSZone *) zone {
  static HKManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [super allocWithZone: zone];
  });
  return sharedInstance;
}

- (NSArray<NSString *> *) supportedEvents {
  return @[@"HK_CYCLING"];
}

- (void) cyclingDataDidChange: (NSArray<__kindof HKQuantitySample *> *) cyclingSamples {
  NSArray *cyclingData = [self gatherCyclingSamples: cyclingSamples];
  [self sendEventWithName: @"HK_CYCLING" body: cyclingData];
}

- (NSArray<__kindof NSDictionary *> *) gatherCyclingSamples: (NSArray<__kindof HKQuantitySample *> *) cyclingSamples {
  NSMutableArray *data = [[NSMutableArray alloc] init];
  
  for (HKQuantitySample *sample in cyclingSamples) {
    NSDictionary *parsedSample = [self parseCyclingData: sample];
    [data addObject: parsedSample];
  }
  
  return data;
}

- (NSDictionary *) parseCyclingData: (HKQuantitySample *) cyclingSample {
  NSString *uuid = [cyclingSample UUID].description;
  NSString *quantity = [cyclingSample quantity].description;
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat: @"yyyy MM dd HH:mm"];
  NSString *endDate = [formatter stringFromDate: [cyclingSample endDate]];
  NSString *startDate = [formatter stringFromDate: [cyclingSample startDate]];
  
  NSDictionary *body = @{
                         @"uuid": uuid,
                         @"quantity": quantity,
                         @"startDate": startDate,
                         @"endDate": endDate
                        };
  
  return body;
}

@end

