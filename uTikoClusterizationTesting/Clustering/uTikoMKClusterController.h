//
//  uTikoMKClusterController.h
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "uTikoMKClusterAnnotation.h"
#import "uTikoMKAnnotationObject.h"

@protocol uTikoMKClusterControllerDelegate;

@interface uTikoMKClusterController : NSObject

-(id)initWithMapView:(MKMapView *)initialMapView;
-(void)addMarkerObjects:(NSArray *)objects;
-(void)refreshMarkers;
-(void)removeAllObjects;
-(void)hideClusters;
-(void)showClusters;

@property (nonatomic, weak) id <uTikoMKClusterControllerDelegate> delegate;
@property (nonatomic) MKMapView * mapView;
@property (nonatomic, strong) NSString * familyName;

@end


@protocol uTikoMKClusterControllerDelegate <NSObject>

@optional

- (void)clusterController:(uTikoMKClusterController *)clusterController configureClusterAnnotationForDisplay:(uTikoMKClusterAnnotation *)clusterAnnotation;
- (BOOL)clusterController:(uTikoMKClusterController *)clusterController removingCluster:(uTikoMKClusterAnnotation *)clusterMarker canRemoveSelected:(BOOL)canRemoveSelected;

@end

