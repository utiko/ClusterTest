//
//  uTikoGMClusterMarker.m
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import "uTikoGMClusterMarker.h"

#define uTikoGMClusterMarkerAnimationStepCount 10

@implementation uTikoGMClusterMarker{
    CLLocationCoordinate2D animationStartCoordinate;
    CLLocationCoordinate2D animationFinishCoordinate;
    int animationsProgress;   
}

-(id)initWithMarkerObjectsArray:(NSArray *)markerObjects parentController:(uTikoGMClusterController *)parentController
{
    self = [super init];
    self.markerObjects = [NSMutableSet setWithArray:markerObjects];
    self.parentController = parentController;
    [self calculateValues];
    return self;
}

-(void)setPosition:(CLLocationCoordinate2D)position animated:(BOOL)animated completion:(void(^)())completion
{
    if (animated) {
        animationStartCoordinate = self.position;
        animationFinishCoordinate = position;
        animationsProgress = 0;

        [NSTimer scheduledTimerWithTimeInterval:0.3 / uTikoGMClusterMarkerAnimationStepCount
                                         target:self
                                       selector:@selector(animatePosition:)
                                       userInfo:completion
                                        repeats:YES];
    }
    else {
        [self setPosition:position];
    }
}

-(void)animatePosition:(NSTimer *)timer
{
    CLLocationCoordinate2D currentPosition = self.position;
    currentPosition.latitude += (animationFinishCoordinate.latitude - animationStartCoordinate.latitude) / uTikoGMClusterMarkerAnimationStepCount;
    currentPosition.longitude += (animationFinishCoordinate.longitude - animationStartCoordinate.longitude) / uTikoGMClusterMarkerAnimationStepCount;
    
    [self setPosition:currentPosition];
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
    
    for(uTikoGMMarkerObject * markerObject in self.markerObjects){
        
        CLLocationDegrees lat = markerObject.coordinate.latitude;
        CLLocationDegrees lng = markerObject.coordinate.longitude;
        
        minLat = MIN(minLat, lat);
        minLng = MIN(minLng, lng);
        maxLat = MAX(maxLat, lat);
        maxLng = MAX(maxLng, lng);
        
        totalLat += lat;
        totalLng += lng;
    }
    
    
    self.position = CLLocationCoordinate2DMake(totalLat / self.markerObjects.count,
                                                 totalLng / self.markerObjects.count);
    
    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                              longitude:minLng]
                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                   longitude:maxLng]] / 2.f;
}

@end
