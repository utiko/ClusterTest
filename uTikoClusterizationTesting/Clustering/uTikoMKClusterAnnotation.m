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
    
    float totalLatitude;
    float totalLongitude;
}

-(instancetype)init
{
    self = [super init];
    self.clusterRect = MKMapRectMake(-180, -180, 360, 360);
    self.annotationCount = 0;
    self.parentCluster = nil;
    self.childClusters = [NSMutableDictionary dictionary];
    return self;
}

-(instancetype)initWithClusterRect:(MKMapRect)clusterRect parentCluster:(uTikoMKClusterAnnotation *)parentCluster
{
    self = [super init];
    self.clusterRect = clusterRect;
    self.parentCluster = parentCluster;
    self.childClusters = [NSMutableDictionary dictionary];
    return self;
}

- (void)addAnnotationObject:(uTikoMKAnnotationObject *)annotationObject
{
    if (!self.annotationObjects) self.annotationObjects = [NSMutableSet set];
    [self.annotationObjects addObject:annotationObject];
    
    if (!self.isLowest) {
        NSString * subClusterColl = (annotationObject.coordinate.longitude<self.clusterRect.origin.x + self.clusterRect.size.width / 2)?@"left":@"right";
        NSString * subClusterRow = (annotationObject.coordinate.latitude<self.clusterRect.origin.y + self.clusterRect.size.height / 2)?@"bottom":@"top";
        
        NSString * subClusterKey = [NSString stringWithFormat:@"%@-%@", subClusterColl, subClusterRow];
        
        uTikoMKClusterAnnotation * subclaster;
        if ([self.childClusters objectForKey:subClusterKey]) {
            subclaster = [self.childClusters objectForKey:subClusterKey];
        } else {
            float width = self.clusterRect.size.width / 2;
            float height = self.clusterRect.size.height / 2;
            float x = [subClusterColl isEqual:@"left"]?self.clusterRect.origin.x:self.clusterRect.origin.x + width;
            float y = [subClusterRow isEqual:@"bottom"]?self.clusterRect.origin.y:self.clusterRect.origin.y + height;
            MKMapRect subClusterRect = MKMapRectMake(x, y, width, height);
            subclaster = [[uTikoMKClusterAnnotation alloc] initWithClusterRect:subClusterRect parentCluster:self];
            [self.childClusters setObject:subclaster forKey:subClusterKey];
        }
        [subclaster addAnnotationObject:annotationObject];
    }
    totalLongitude += annotationObject.coordinate.longitude;
    totalLatitude += annotationObject.coordinate.latitude;
    self.annotationCount ++;
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

- (void)restoreCoordinate
{
    self.coordinate = CLLocationCoordinate2DMake(totalLatitude / self.annotationCount, totalLongitude / self.annotationCount);
}


-(BOOL)isLowest
{
    return self.clusterRect.size.width < 0.00034;
}


/*-(void)animatePosition:(NSTimer *)timer
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
}*/

/*- (void)calculateValues {
    
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
}*/

@end
