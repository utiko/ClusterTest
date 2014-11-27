//
//  uTikoMKClusterAnnotation.m
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import "uTikoMKClusterAnnotation.h"
#import "uTikoMKAnnotationObject.h"

#define uTikoGMClusterMarkerAnimationStepCount 10

@implementation uTikoMKClusterAnnotation {
    CLLocationCoordinate2D animationStartCoordinate;
    CLLocationCoordinate2D animationFinishCoordinate;
    int animationsProgress;
}

-(id)initWithMarkerObjectsArray:(NSArray *)markerObjects parentController:(uTikoMKClusterController *)parentController
{
    self = [super init];
    self.annotationObjects = [NSMutableSet setWithArray:markerObjects];
    self.parentController = parentController;
    [self calculateValues];
    return self;
}

-(void)setPosition:(CLLocationCoordinate2D)position animated:(BOOL)animated completion:(void (^)())completion
{
    if (animated) {
        /// run animation little bit after creation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [self setCoordinate:position];
            } completion:^(BOOL finished) {
                if (completion) completion();
            }];
        });
    }
    else {
        [self setCoordinate:position];
    }
}

-(void)animatePosition:(NSTimer *)timer
{
    CLLocationCoordinate2D currentPosition = self.coordinate;
    currentPosition.latitude += (animationFinishCoordinate.latitude - animationStartCoordinate.latitude) / uTikoGMClusterMarkerAnimationStepCount;
    currentPosition.longitude += (animationFinishCoordinate.longitude - animationStartCoordinate.longitude) / uTikoGMClusterMarkerAnimationStepCount;
    
    [self setCoordinate:currentPosition];
    animationsProgress++;
    if (animationsProgress >= uTikoGMClusterMarkerAnimationStepCount) {
        if (timer.userInfo) {
            void (^compl)() = timer.userInfo;
            compl();
        }
        [timer invalidate];
    }
}

- (void)calculateValues {
    
    CLLocationDegrees minLat = INT_MAX;
    CLLocationDegrees minLng = INT_MAX;
    CLLocationDegrees maxLat = -INT_MAX;
    CLLocationDegrees maxLng = -INT_MAX;
    
    CLLocationDegrees totalLat = 0;
    CLLocationDegrees totalLng = 0;
    
    for(uTikoMKAnnotationObject * markerObject in self.annotationObjects){
        
        CLLocationDegrees lat = markerObject.coordinate.latitude;
        CLLocationDegrees lng = markerObject.coordinate.longitude;
        
        minLat = MIN(minLat, lat);
        minLng = MIN(minLng, lng);
        maxLat = MAX(maxLat, lat);
        maxLng = MAX(maxLng, lng);
        
        totalLat += lat;
        totalLng += lng;
    }
    
    self.coordinate = CLLocationCoordinate2DMake(totalLat / self.annotationObjects.count,
                                               totalLng / self.annotationObjects.count);
    
    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                              longitude:minLng]
                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                   longitude:maxLng]] / 2.f;
}

@end
