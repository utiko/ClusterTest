//
//  uTikoMKClusterAnnotation.h
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class uTikoMKClusterController;
@class uTikoMKAnnotationObject;

@interface uTikoMKClusterAnnotation : NSObject <MKAnnotation>

-(instancetype)initWithClusterRect:(MKMapRect)clusterRect parentCluster:(uTikoMKClusterAnnotation *)parentCluster;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableSet * annotationObjects;
@property (nonatomic, strong) NSMutableDictionary * childClusters;
@property (nonatomic, strong) uTikoMKClusterAnnotation * parentCluster;
@property (nonatomic) NSInteger annotationCount;
@property (nonatomic) MKMapRect clusterRect;
@property (nonatomic, readonly) BOOL isLowest;



@property float radius;
@property (nonatomic) int selectedObject;


- (void)addAnnotationObject:(uTikoMKAnnotationObject *)annotationObject;

- (void)restoreCoordinate;

- (void)setPosition:(CLLocationCoordinate2D)position animated:(BOOL)animated completion:(void(^)())completion;



@end
