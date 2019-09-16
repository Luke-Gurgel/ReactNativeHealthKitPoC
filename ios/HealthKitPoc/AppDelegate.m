/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTEventEmitter.h>
#import <HealthKit/HealthKit.h>
#import "HKManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate: self launchOptions: launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc]
                           initWithBridge: bridge
                           moduleName: @"HealthKitPoc"
                           initialProperties: nil
                          ];

  rootView.backgroundColor = [[UIColor alloc] initWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  
  if ([HKHealthStore isHealthDataAvailable]) {
    NSLog(@"Health data is available");

    if (self.hkStore == nil) {
      self.hkStore = [[HKHealthStore alloc] init];
    }

    HKObjectType *cyclingType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDistanceCycling];
    HKSampleType *cyclingSampleType = [HKSampleType quantityTypeForIdentifier: HKQuantityTypeIdentifierDistanceCycling];
    BOOL hasAccessToCycling = [self.hkStore authorizationStatusForType: cyclingType];
    __block BOOL hasExecutedQuery = false;

    if (hasAccessToCycling) {
      NSLog(@"We have access to cycling, setting up queries and enabling background delivery");
      
      HKManager *hkManager = [HKManager allocWithZone: nil];

      HKAnchoredObjectQuery *cyclingAnchoredQuery = [[HKAnchoredObjectQuery alloc] initWithType: cyclingSampleType predicate: nil anchor: HKAnchoredObjectQueryNoAnchor limit: HKObjectQueryNoLimit resultsHandler: ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        if (error) {
          NSLog(@"Could not set up anchored query for cycling: %@", error.localizedDescription);
          abort();
        }

        NSLog(@"Results from the initial anchored query");

        if (sampleObjects) {
          for (HKQuantitySample *sample in sampleObjects) {
            if (@available(iOS 12.0, *)) { NSLog(@"count: %ld", (long)sample.count); } // 1 how many quantities are there in this HKQuantitySample
            NSLog(@"UUID: %@", sample.UUID);
            NSLog(@"sampleType: %@", sample.sampleType); // HKQuantityTypeIdentifierDistanceCycling
            NSLog(@"quantity: %@", sample.quantity); // 2 mi
            NSLog(@"startDate: %@", sample.startDate); // Fri Sep 13 14:06:00 2019
            NSLog(@"endDate: %@", sample.endDate); // Fri Sep 13 14:06:00 2019
            NSLog(@"metadata: %@", sample.metadata); // { HKWasUserEntered = 1 }
          }
        }
      }];

      cyclingAnchoredQuery.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        if (error) {
          NSLog(@"Could not set up anchored query for cycling: %@", error.localizedDescription);
          abort();
        }
        
        NSLog(@"Results from the anchored query updateHandler");

        if (addedObjects) {
          [hkManager cyclingDataDidChange: addedObjects];
        }

        if (deletedObjects) {
          // NSLog(@"cycling deleted samples: %@", deletedObjects);
        }
      };

      HKObserverQuery *cyclingObserverQuery = [[HKObserverQuery alloc] initWithSampleType: cyclingSampleType predicate: nil updateHandler: ^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
        if (error) {
          NSLog(@"Error setting up cyclingObserverQuery: %@", error.localizedDescription);
          abort();
        }

        completionHandler();
        if (!hasExecutedQuery) {
          [self.hkStore executeQuery: cyclingAnchoredQuery];
          hasExecutedQuery = true;
        }
      }];

      NSLog(@"Executing cycling ObserverQuery");
      [self.hkStore executeQuery: cyclingObserverQuery];

      [self.hkStore enableBackgroundDeliveryForType: cyclingType frequency: 1 withCompletion: ^(BOOL success, NSError * _Nullable error) {
        if (success == false || error != nil) {
          NSLog(@"Error enabling background deliveries for cycling: %@", error.localizedDescription);
        }
        
        NSLog(@"App is registered for background deliveries for cycling data");
      }];
    } else {
      NSLog(@"Whoops, we don't have access to cycling data");
    }
  }
  
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end

// 2019-09-16 12:47:32.619027-0400 HealthKitPoc[1462:508466] [] nw_socket_handle_socket_event [C3:1] Socket SO_ERROR [61: Connection refused]
// 2019-09-16 12:47:32.620479-0400 HealthKitPoc[1462:508492] [] nw_connection_get_connected_socket [C3] Client called nw_connection_get_connected_socket on unconnected nw_connection
// 2019-09-16 12:47:32.620647-0400 HealthKitPoc[1462:508492] TCP Conn 0x282676880 Failed : error 0:61 [61]


/*
 HKSampleType *walkRunSampleType = [HKSampleType quantityTypeForIdentifier: HKQuantityTypeIdentifierDistanceWalkingRunning];
 BOOL hasAccessToWalkRun = [self.hkStore authorizationStatusForType: walkRunType];
 
 if (hasAccessToWalkRun) {
 NSLog(@"We have access to walking/running, setting up queries and enabling background delivery");
 
 HKAnchoredObjectQuery *walkRunAnchoredQuery = [[HKAnchoredObjectQuery alloc] initWithType: walkRunSampleType predicate: nil anchor: nil limit: HKObjectQueryNoLimit resultsHandler: ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
 if (error) {
 NSLog(@"Could not set up anchored query for walking/running: %@", error.localizedDescription);
 return;
 }
 
 if (sampleObjects) {
 NSLog(@"new walking/running samples: %@", sampleObjects);
 // send added samples to RN
 }
 
 if (deletedObjects) {
 NSLog(@"deleted walking/running samples: %@", deletedObjects);
 // send deleted samples to RN
 }
 }];
 
 HKObserverQuery *walkRunObserverQuery = [[HKObserverQuery alloc] initWithSampleType: walkRunSampleType predicate: nil updateHandler: ^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
 if (error) {
 return;
 }
 
 completionHandler();
 //        [self.hkStore executeQuery: walkRunAnchoredQuery];
 }];
 
 [self.hkStore executeQuery: walkRunObserverQuery];
 
 [self.hkStore enableBackgroundDeliveryForType: walkRunType frequency: 1 withCompletion: ^(BOOL success, NSError * _Nullable error) {
 if (success == false || error != nil) {
 NSLog(@"Error enabling background deliveries for walking/running: %@", error.localizedDescription);
 }
 }];
 }
*/
