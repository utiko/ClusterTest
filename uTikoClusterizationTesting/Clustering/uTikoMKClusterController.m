//
//  uTikoMKClusterController.m
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import "uTikoMKClusterController.h"
#import "uTikoMKClusterAnnotation.h"

@interface uTikoMKClusterController ()

@property (nonatomic) NSMutableArray * annotationObjects;
@property (nonatomic) NSMutableArray * currentClusters;
@property (nonatomic) BOOL clustersVisible;
@property (nonatomic) uTikoMKClusterAnnotation * rootCluster;

@end

@implementation uTikoMKClusterController

-(id)initWithMapView:(MKMapView *)initialMapView
{
    self = [super init];
    self.mapView = initialMapView;
    self.annotationObjects = [NSMutableArray array];
    self.currentClusters = [NSMutableArray array];
    self.clustersVisible = YES;
    return self;
}

-(id)initWithMarkerObjects:(NSArray *)objects
{
    self = [super init];
    self.annotationObjects = [NSMutableArray arrayWithArray:objects];
    self.clustersVisible = YES;
    return self;
}

-(void)addMarkerObjects:(NSArray *)objects
{
    self.rootCluster = [[uTikoMKClusterAnnotation alloc] init];
    for (uTikoMKAnnotationObject * annotationObject in objects)
        [self.rootCluster addAnnotationObject:annotationObject];
    [self refreshMarkers];
}

-(void)refreshMarkers
{
    if (self.mapView && self.clustersVisible) {
        
        MKMapRect mapRect = MKMapRectMake(self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta,
                                          self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta, self.mapView.region.span.longitudeDelta * 2, self.mapView.region.span.latitudeDelta * 2);
        NSArray * newClusters = [self clustersForMapRect:mapRect inCluster:self.rootCluster];
        for (uTikoMKClusterAnnotation * cluster in newClusters) {
            [cluster restoreCoordinate];
        }
        
        /// Updating clusters
        NSMutableArray * oldClusterForRemove = [NSMutableArray array];
        for (uTikoMKClusterAnnotation * newCluster in newClusters) {
            
            BOOL addNewClusterToArray = YES;
            BOOL addNewClusterToMap = YES;
            
            for (uTikoMKClusterAnnotation * oldCluster in self.currentClusters) {
                if ([oldCluster.annotationObjects isSubsetOfSet:newCluster.annotationObjects] &&
                    newCluster.annotationObjects.count == oldCluster.annotationObjects.count) {
                    /// Clusters are identical - ignoring new cluster
                    addNewClusterToMap = NO;
                    addNewClusterToArray = NO;
                }
                else if ([newCluster.annotationObjects isSubsetOfSet:oldCluster.annotationObjects]) {
                    /// New cluster is part of old cluster
                    ///     Remove old cluster, animate new cluster from old coordinate to new coordinate
                    
                    CLLocationCoordinate2D newPosition = newCluster.coordinate;
                    newCluster.coordinate = oldCluster.coordinate;
                    
                    [self.mapView addAnnotation:newCluster];
                    [self.mapView removeAnnotation:oldCluster];
                    if ([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]) {
                        [self.delegate clusterController:self removingCluster:oldCluster canRemoveSelected:YES];
                    }
                    
                    [oldClusterForRemove addObject:oldCluster];
                    addNewClusterToMap = NO;
                    addNewClusterToArray = YES;
                    
                    [newCluster setPosition:newPosition animated:YES completion:nil];
                }
                else if ([oldCluster.annotationObjects isSubsetOfSet:newCluster.annotationObjects]) {
                    /// Old cluster is part of new cluster
                    ///     Move old cluster to new coordinate. Then add new cluster and remove old.
                    __weak uTikoMKClusterAnnotation * _oldCluster = oldCluster;
                    [self.mapView addAnnotation:oldCluster];
                    [_oldCluster setPosition:newCluster.coordinate animated:YES completion:^(){
                        [self.mapView removeAnnotation:_oldCluster];
                        if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
                            [self.delegate clusterController:self removingCluster:oldCluster canRemoveSelected:YES];
                        }
                        if ([self.currentClusters containsObject:newCluster]) [self.mapView addAnnotation:newCluster];
                    }];
                    [oldClusterForRemove addObject:oldCluster];
                    addNewClusterToMap = NO;
                    addNewClusterToArray = YES;
                }
            }
            
            
            
            if (addNewClusterToMap) {
                [self.mapView addAnnotation:newCluster];
            }
            if (addNewClusterToArray) {
                [self.currentClusters addObject:newCluster];
            }
        }
        
        /// Remove all clusters out of visible rect
        for (uTikoMKClusterAnnotation * cluster in self.currentClusters) {
            if (![self isCoordinate:cluster.coordinate inMapRect:mapRect]) {
                BOOL canDelete = YES;
                if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
                    canDelete = [self.delegate clusterController:self removingCluster:cluster canRemoveSelected:NO];
                }
                if (canDelete) {
                    [self.mapView removeAnnotation:cluster];
                    [oldClusterForRemove addObject:cluster];
                }
            }
        }
        
        [self.currentClusters removeObjectsInArray:oldClusterForRemove];
        [oldClusterForRemove removeAllObjects];
        oldClusterForRemove = nil;
    }
}


-(NSArray *)clustersForMapRect:(MKMapRect)mapRect inCluster:(uTikoMKClusterAnnotation *)cluster
{
    BOOL isMinimumClusterForScreen = cluster.clusterRect.size.width < mapRect.size.width / 4;
    if (isMinimumClusterForScreen || cluster.isLowest) return @[cluster];
    
    NSMutableArray * clusters = [NSMutableArray array];
    for (NSString * key in cluster.childClusters) {
        uTikoMKClusterAnnotation * childCluster = [cluster.childClusters objectForKey:key];
        BOOL isVisible = MKMapRectIntersectsRect(mapRect, childCluster.clusterRect);
        if (isVisible) [clusters addObjectsFromArray:[self clustersForMapRect:mapRect inCluster:childCluster]];
    }
    return clusters;
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
    for (uTikoMKClusterAnnotation * cluster in self.currentClusters) {
        [self.mapView removeAnnotation:cluster];
    }
    [self.currentClusters removeAllObjects];
    [self.annotationObjects removeAllObjects];
    //[self refreshMarkers];
}

-(void)hideClusters {
    for (uTikoMKClusterAnnotation * cluster in self.currentClusters) {
        [self.mapView removeAnnotation:cluster];
        if([self.delegate respondsToSelector:@selector(clusterController:removingCluster:canRemoveSelected:)]){
            [self.delegate clusterController:self removingCluster:cluster canRemoveSelected:YES];
        }
    }
    self.clustersVisible = NO;
}

-(void)showClusters {
    for (uTikoMKClusterAnnotation * cluster in self.currentClusters) {
        [self.mapView addAnnotation:cluster];
    }
    self.clustersVisible = YES;
    [self refreshMarkers];
}



@end
