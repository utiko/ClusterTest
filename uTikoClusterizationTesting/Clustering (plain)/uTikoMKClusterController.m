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
    /*for (uTikoMKAnnotationObject * newObject in objects) {
        BOOL exists = NO;
        for (uTikoMKAnnotationObject * object in self.annotationObjects) {
            if (object.tag == newObject.tag) {
                exists = YES;
                break;
            }
        }
        if (!exists) [self.annotationObjects addObject:newObject];
        [self insertAnnotationObject:newObject];
    }*/
    [self.annotationObjects addObjectsFromArray:objects];
    [self refreshMarkers];
}

-(void)refreshMarkers
{
    if (self.mapView && self.clustersVisible) {
        
        //float koef = pow(2, floor(self.mapView.camera.zoom)); // Zoom koeficient
        
        float gridDimension = 7;
        float clusterGridSize = 360;
        float screenDelta = self.mapView.region.span.longitudeDelta;
        while (clusterGridSize / 3 > screenDelta) {
            clusterGridSize = clusterGridSize / 2;
        }
        float clusterAreaSize = clusterGridSize / gridDimension;
        
        /// Calculating grid
        CLLocationCoordinate2D leftBottomCorner =
        [self.mapView convertPoint:CGPointMake(0, self.mapView.frame.size.height)
              toCoordinateFromView:self.mapView];
        
        leftBottomCorner.latitude = (floor( leftBottomCorner.latitude / clusterAreaSize ) - 1) * clusterAreaSize;
        leftBottomCorner.longitude = (floor( leftBottomCorner.longitude / clusterAreaSize ) - 1) * clusterAreaSize;
        
        
        /// Generating new clusters
        
        //NSMutableArray * newClusters = [NSMutableArray array];
        
        NSArray * newClusters = [self generateClustersWithBottomLeftCorner:leftBottomCorner
                                                                    gridDimension:gridDimension
                                                                         gridSize:clusterGridSize];
        
        
        /*for (int i=0; i < gridDimension; i++)
            for (int j=0; j < gridDimension; j++) {
                MKMapRect mapRect = MKMapRectMake(leftBottomCorner.longitude + j*clusterAreaSize, leftBottomCorner.latitude + i*clusterAreaSize, clusterAreaSize, clusterAreaSize);
                NSArray * markersInRegion = [self getMarkerObjectsInMapRect:mapRect];
                if (markersInRegion.count>0) {
                    uTikoMKClusterAnnotation * cluster = [[uTikoMKClusterAnnotation alloc] initWithMarkerObjectsArray:markersInRegion parentController:self];
                    [newClusters addObject:cluster];
                }
            }*/
        
        
        //NSLog(@"%f %f %d", leftBottomCorner.latitude, leftBottomCorner.longitude, [self getMarkerObjectsInMapRect:MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude, gridDimension*clusterAreaSize, gridDimension*clusterAreaSize)].count);
        
        NSLog(@"%f %f %f %f %d", clusterGridSize, clusterAreaSize, leftBottomCorner.latitude, leftBottomCorner.longitude, newClusters.count);
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
            MKMapRect mapRect = MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude,
                                              gridDimension*clusterAreaSize, gridDimension*clusterAreaSize);
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


- (NSArray *)generateClustersWithBottomLeftCorner:(CLLocationCoordinate2D)bottomLeftCorner
                                    gridDimension:(NSInteger)gridDimension
                                         gridSize:(float)size
{
    MKMapRect gridRect = MKMapRectMake(bottomLeftCorner.longitude, bottomLeftCorner.latitude, size, size);
    float cellSize = size/gridDimension;
    
    NSMutableDictionary * gridDictionary = [NSMutableDictionary dictionary];
    for (uTikoMKAnnotationObject * annotationObject in self.annotationObjects) {
        if ([self isCoordinate:annotationObject.coordinate inMapRect:gridRect]) {
            int kRow = (annotationObject.coordinate.latitude - bottomLeftCorner.latitude) / cellSize;
            int kCol = (annotationObject.coordinate.longitude - bottomLeftCorner.longitude) / cellSize;
            NSString * key = [NSString stringWithFormat:@"%d_%d", kRow, kCol];
            NSMutableArray * clusterAnnotations;
            if (![gridDictionary objectForKey:key]) {
                [gridDictionary setObject:[NSMutableArray array] forKey:key];
            }
            clusterAnnotations = [gridDictionary objectForKey:key];
            [clusterAnnotations addObject:annotationObject];
        }
    }
    NSMutableArray * result = [NSMutableArray array];
    for (NSString * key in gridDictionary) {
        NSArray * clusterAnnotations = [gridDictionary objectForKey:key];
        uTikoMKClusterAnnotation * cluster = [[uTikoMKClusterAnnotation alloc] initWithMarkerObjectsArray:clusterAnnotations parentController:self];
        [result addObject:cluster];
    }
    return result;
}

-(NSMutableArray *)getMarkerObjectsInMapRect:(MKMapRect)mapRect
{
    NSMutableArray * result = [NSMutableArray array];
    for (uTikoMKAnnotationObject * markerObject in self.annotationObjects) {
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
