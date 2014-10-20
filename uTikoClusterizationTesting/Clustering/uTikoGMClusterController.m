//
//  uTikoGMClusterController.m
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import "uTikoGMClusterController.h"


@interface uTikoGMClusterController ()
@property (nonatomic) NSMutableArray * markerObjects;
@property (nonatomic) NSMutableArray * currentClusters;


@end


@implementation uTikoGMClusterController {
    BOOL clustersVisible;
}

@synthesize markerObjects;
@synthesize currentClusters;
@synthesize mapView;

-(id)initWithMapView:(uTikoGMSMapView *)initialMapView
{
    self = [super init];
    mapView = initialMapView;
    markerObjects = [NSMutableArray array];
    currentClusters = [NSMutableArray array];
    clustersVisible = YES;
    return self;
}

-(id)initWithMarkerObjects:(NSArray *)objects
{
    self = [super init];
    markerObjects = [NSMutableArray arrayWithArray:objects];
    clustersVisible = YES;
    return self;
}

-(void)addMarkerObjects:(NSArray *)objects
{
    for (uTikoGMMarkerObject * newObject in objects) {
        BOOL exists = NO;
        for (uTikoGMMarkerObject * object in markerObjects) {
            if (object.tag == newObject.tag) {
                exists = YES;
                break;
            }
        }
        if (!exists) [markerObjects addObject:newObject];
    }
    
}


-(void)refreshMarkers
{
    if (mapView && clustersVisible) {
        
        float koef = pow(2, floor(mapView.camera.zoom)); // Zoom koeficient
        float gridDimension = 7;
        float maximumScreenSize = 500;
        float clusterAreaSize = maximumScreenSize / koef / (gridDimension - 3);
        
        /// Calculating grid 
        CLLocationCoordinate2D leftBottomCorner = [mapView.projection coordinateForPoint:CGPointMake(0, mapView.frame.size.height)];
        //NSLog(@"%f %f", leftCorner.latitude, leftCorner.longitude);
        leftBottomCorner.latitude = (floor( leftBottomCorner.latitude / clusterAreaSize ) - 1) * clusterAreaSize;
        leftBottomCorner.longitude = (floor( leftBottomCorner.longitude / clusterAreaSize ) - 1) * clusterAreaSize;


        /// Generating new clusters

        NSMutableArray * newClusters = [NSMutableArray array];
        for (int i=0; i < gridDimension; i++)
            for (int j=0; j < gridDimension; j++) {
                MKMapRect mapRect = MKMapRectMake(leftBottomCorner.longitude + j*clusterAreaSize, leftBottomCorner.latitude + i*clusterAreaSize, clusterAreaSize, clusterAreaSize);
                NSMutableArray * markersInRegion = [self getMarkerObjectsInMapRect:mapRect];
                if (markersInRegion.count>0) {
                    
                    /// Create cluster object
                    uTikoGMClusterMarker * cluster = [[uTikoGMClusterMarker alloc] initWithMarkerObjectsArray:markersInRegion parentController:self];
                  
                    /// Customize cluster
                    if([self.delegate respondsToSelector:@selector(clusterController:configureClusterMarkerForDisplay:)]){
                        [self.delegate clusterController:self configureClusterMarkerForDisplay:cluster];
                    }
                    //cluster.title = [[NSString alloc] initWithFormat:@"%d", markersInRegion.count ];

                    [newClusters addObject:cluster];
                }
            }
        
        //NSLog(@"%f %f %d", leftBottomCorner.latitude, leftBottomCorner.longitude, [self getMarkerObjectsInMapRect:MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude, gridDimension*clusterAreaSize, gridDimension*clusterAreaSize)].count);
        
        
        /// Updating clusters
        NSMutableArray * oldClusterForRemove = [NSMutableArray array];
        for (uTikoGMClusterMarker * newCluster in newClusters) {

            BOOL addNewClusterToArray = YES;
            BOOL addNewClusterToMap = YES;

            for (uTikoGMClusterMarker * oldCluster in currentClusters) {
                if ([oldCluster.markerObjects isSubsetOfSet:newCluster.markerObjects] &&
                    newCluster.markerObjects.count == oldCluster.markerObjects.count) {
                    /// Clusters are identical - ignoring new cluster
                    addNewClusterToMap = NO;
                    addNewClusterToArray = NO;
                }
                else if ([newCluster.markerObjects isSubsetOfSet:oldCluster.markerObjects]) {
                    /// New cluster is part of old cluster
                    ///     Remove old cluster, animate new cluster from old coordinate to new coordinate
                    
                    CLLocationCoordinate2D newPosition = newCluster.position;
                    newCluster.position = oldCluster.position;
                    
                    [self.mapView addMarker:newCluster];
                    [self.mapView removeMarker:oldCluster];
                    if ([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]) {
                        [self.delegate clusterController:self removingCluster:oldCluster canRemoveSelected:YES];
                    }
                    
                    [oldClusterForRemove addObject:oldCluster];
                    addNewClusterToMap = NO;
                    addNewClusterToArray = YES;
                    
                    [newCluster setPosition:newPosition animated:YES completion:nil];
                }
                else if ([oldCluster.markerObjects isSubsetOfSet:newCluster.markerObjects]) {
                    /// Old cluster is part of new cluster
                    ///     Move old cluster to new coordinate. Then add new cluster and remove old.
                    __weak uTikoGMClusterMarker * _oldCluster = oldCluster;
                    [self.mapView addMarker:oldCluster];
                    [_oldCluster setPosition:newCluster.position animated:YES completion:^(){
                        [_oldCluster setMap:nil];
                        if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
                            [self.delegate clusterController:self removingCluster:oldCluster canRemoveSelected:YES];
                        }
                        if ([currentClusters containsObject:newCluster]) [self.mapView addMarker:newCluster];
                    }];
                    [oldClusterForRemove addObject:oldCluster];
                    addNewClusterToMap = NO;
                    addNewClusterToArray = YES;     
                }
            }

            
            
            if (addNewClusterToMap) {
                [self.mapView addMarker:newCluster];
            }
            if (addNewClusterToArray) {
                [currentClusters addObject:newCluster];
            }
        }
        
        /// Remove all clusters out of visible rect
        for (uTikoGMClusterMarker * cluster in currentClusters) {
            MKMapRect mapRect = MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude,
                                        gridDimension*clusterAreaSize, gridDimension*clusterAreaSize);
            if (![self isCoordinate:cluster.position inMapRect:mapRect]) {
                BOOL canDelete = YES;
                if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
                    canDelete = [self.delegate clusterController:self removingCluster:cluster canRemoveSelected:NO];
                }
                if (canDelete) {
                    cluster.map = nil;
                    [self.mapView removeMarker:cluster];
                    [oldClusterForRemove addObject:cluster];
                }
            }
        }
        
        [currentClusters removeObjectsInArray:oldClusterForRemove];
        [oldClusterForRemove removeAllObjects];
        oldClusterForRemove = nil;
        //NSLog(@"%d - %d", currentClusters.count, mapView.markers.count);
    }
}

/// Helpers

-(NSMutableArray *)getMarkerObjectsInMapRect:(MKMapRect)mapRect
{
    NSMutableArray * result = [NSMutableArray array];
    for (uTikoGMMarkerObject * markerObject in markerObjects) {
        if (!(markerObject.coordinate.latitude==0 && markerObject.coordinate.longitude==0) && [self isCoordinate:markerObject.coordinate inMapRect:mapRect])
            [result addObject:markerObject];
    }
    return result;
}

-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate inMapRect:(MKMapRect)mapRect
{
    BOOL latitudeInMapRect = coordinate.latitude >= mapRect.origin.y &&
    coordinate.latitude < mapRect.origin.y + mapRect.size.height;
    BOOL longitudeInMapRect = coordinate.longitude >= mapRect.origin.x &&
    coordinate.longitude < mapRect.origin.x + mapRect.size.width;
    BOOL longitudeInExtraMapRect = coordinate.longitude >= mapRect.origin.x - 360 &&
    coordinate.longitude < mapRect.origin.x + mapRect.size.width - 360;
    
    return latitudeInMapRect && (longitudeInMapRect || longitudeInExtraMapRect);
}

-(void)removeAllObjects
{
    for (uTikoGMClusterMarker * cluster in currentClusters) {
        [self.mapView removeMarker:cluster];
    }
    [currentClusters removeAllObjects];
    [markerObjects removeAllObjects];
    //[self refreshMarkers];
}

-(void)hideClusters {
    for (uTikoGMClusterMarker * cluster in self.currentClusters) {
        [self.mapView removeMarker:cluster];
        if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
            [self.delegate clusterController:self removingCluster:cluster canRemoveSelected:YES];
        }
    }
    clustersVisible = NO;
}

-(void)showClusters {
    for (uTikoGMClusterMarker * cluster in self.currentClusters) {
        [self.mapView addMarker:cluster];
    }
    clustersVisible = YES;
    [self refreshMarkers];
}

@end
