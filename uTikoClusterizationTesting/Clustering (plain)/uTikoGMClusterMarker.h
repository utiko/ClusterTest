//
//  uTikoGMClusterMarker.h
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "uTikoGMMarkerObject.h"

@class uTikoGMClusterController;

@interface uTikoGMClusterMarker : GMSMarker

-(id)initWithMarkerObjectsArray:(NSArray *)markerObjects parentController:(uTikoGMClusterController *)parentController;

//@property (nonatomic, strong) NSString * markerFamilyName;
@property (nonatomic, strong) NSMutableSet * markerObjects;
@property (nonatomic, strong) uTikoGMClusterController * parentController;
@property float radius;
@property (nonatomic) int selectedObject;

-(void)setPosition:(CLLocationCoordinate2D)position animated:(BOOL)animated completion:(void(^)())completion;

@end
