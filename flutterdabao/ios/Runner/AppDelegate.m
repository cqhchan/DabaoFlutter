#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"
#import <CoreLocation/CoreLocation.h>

@import Firebase;


@implementation AppDelegate
CLLocationManager *_locationManager;



- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"AIzaSyA1VBJqZV92zUzMmNUrrq2oZpDKo_ckk2o"];
    NSLog(@"itCamehere ");
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel* locationCannel = [FlutterMethodChannel
                                            methodChannelWithName:@"flutter.dabao/locations"
                                            binaryMessenger:controller];
    
    __weak typeof(self) weakSelf = self;
    [locationCannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"startLocationBackgroundListening" isEqualToString:call.method]) {
            
            int location = [weakSelf startListeningToBackgroundLocation];
            result(@(location));
            
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat:@"EEEE"];
    


        for(CLLocation *location in locations){
            
            
            @try {
                NSDate *time = location.timestamp;
            
                double timestamp = [[NSDate date] timeIntervalSince1970];
                int64_t timeInMilisInt64 = (int64_t)(timestamp*1000);
                NSString *t = [NSString stringWithFormat:@"%lld", timeInMilisInt64];

                NSString *theDate = [dateFormat stringFromDate:time];
                NSString *dayOFWeek = [dateFormatter stringFromDate:time].uppercaseString;
                
                if ([FIRAuth auth].currentUser) {
                    
                    FIRUser *user = [FIRAuth auth].currentUser;
                    
                    
                    
                    FIRFirestore *defaultFirestore = [FIRFirestore firestore];
                    
                    FIRGeoPoint *point = [[FIRGeoPoint alloc] initWithLatitude: location.coordinate.latitude longitude:location.coordinate.longitude ];
                    
                    [[[[[defaultFirestore collectionWithPath:@"locations"] documentWithPath:user.uid] collectionWithPath:dayOFWeek] documentWithPath:theDate] setData:@{t: @{@"Location": point, @"Time": time },} merge:true completion:^(NSError * _Nullable error) {
                        if (error != nil) {
                            NSLog(@"Error adding document: %@", error);
                        } else {
                            NSLog(@"Document added");
                        }
                    }];
                }
                

            }
            @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
            
        }
    
}


- (int)startListeningToBackgroundLocation {
    
    
    //The Location Manager must have a strong reference to it.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    
    //Request Always authorization (iOS8+)
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    
    //Allow location updates in the background (iOS9+)
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    
    [_locationManager startMonitoringSignificantLocationChanges];
    return 1;
}
@end

