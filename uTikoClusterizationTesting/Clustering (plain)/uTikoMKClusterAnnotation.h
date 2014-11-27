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

@interface uTikoMKClusterAnnotation : NSObject <MKAnnotation>

-(id)initWithMarkerObjectsArray:(NSArray *)markerObjects parentController:(uTikoMKClusterController *)parentController;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableSet * annotationObjects;
@property (nonatomic, strong) uTikoMKClusterController * parentController;
@property float radius;
@property (nonatomic) int selectedObject;


-(void)setPosition:(CLLocationCoordinate2D)position animated:(BOOL)animated completion:(void(^)())completion;

@end
