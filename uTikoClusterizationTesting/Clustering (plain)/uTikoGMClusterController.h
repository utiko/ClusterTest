//
//  uTikoGMClusterController.h
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>

#import "uTikoGMClusterMarker.h"
#import "uTikoGMMarkerObject.h"
#import "uTikoGMSMapView.h"

@protocol uTikoGMClusterControllerDelegate;

@interface uTikoGMClusterController : NSObject

-(id)initWithMapView:(uTikoGMSMapView *)initialMapView;

-(void)addMarkerObjects:(NSArray *)objects;
-(void)refreshMarkers;
-(void)removeAllObjects;
-(void)hideClusters;
-(void)showClusters;

@property (nonatomic, weak) id<uTikoGMClusterControllerDelegate> delegate;
@property (nonatomic) uTikoGMSMapView * mapView;
@property (nonatomic, strong) NSString * familyName;





@end

@protocol uTikoGMClusterControllerDelegate <NSObject>

@optional

- (void)clusterController:(uTikoGMClusterController *)clusterController configureClusterMarkerForDisplay:(uTikoGMClusterMarker *)clusterMarker;

- (BOOL)clusterController:(uTikoGMClusterController *)clusterController removingCluster:(uTikoGMClusterMarker *)clusterMarker canRemoveSelected:(BOOL)canRemoveSelected;

@end
