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
    for (uTikoMKAnnotationObject * newObject in objects) {
        BOOL exists = NO;
        /*for (uTikoMKAnnotationObject * object in self.annotationObjects) {
            if (object.tag == newObject.tag && newObject.tag!=0) {
                exists = YES;
                break;
            }
        }*/
        if (!exists) [self.annotationObjects addObject:newObject];
    }
    [self refreshMarkers];
}

-(void)refreshMarkers
{
    if (self.mapView && self.clustersVisible) {
        
        //float koef = pow(2, floor(self.mapView.camera.zoom)); // Zoom koeficient
        float gridDimension = 7;
        float clusterScreenSize = 500;
        while (clusterScreenSize / 2 > self.mapView.region.span.longitudeDelta) {
            clusterScreenSize = clusterScreenSize / 2;
        }
        float clusterAreaSize = clusterScreenSize / (gridDimension - 3);
        
        /// Calculating grid
        CLLocationCoordinate2D leftBottomCorner = [self.mapView convertPoint:CGPointMake(0, self.mapView.frame.size.height) toCoordinateFromView:self.mapView];
        leftBottomCorner.latitude = (floor( leftBottomCorner.latitude / clusterAreaSize ) - 1) * clusterAreaSize;
        leftBottomCorner.longitude = (floor( leftBottomCorner.longitude / clusterAreaSize ) - 1) * clusterAreaSize;
        //NSLog(@"%f %f %f", leftBottomCorner.latitude, leftBottomCorner.longitude, clusterAreaSize);
        
        /// Generating new clusters
        
        NSArray * newClusters = [self generateVisibleCustersForGridWithDimention:gridDimension leftBottomCorner:leftBottomCorner clusterAreaSize:clusterAreaSize];
        /*for (int i=0; i < gridDimension; i++)
            for (int j=0; j < gridDimension; j++) {
                MKMapRect mapRect = MKMapRectMake(leftBottomCorner.longitude + j*clusterAreaSize, leftBottomCorner.latitude + i*clusterAreaSize, clusterAreaSize, clusterAreaSize);
                NSMutableArray * markersInRegion = [self getMarkerObjectsInMapRect:mapRect];
                if (markersInRegion.count>0) {
                    
                    /// Create cluster object
                    uTikoMKClusterAnnotation * cluster = [[uTikoMKClusterAnnotation alloc] initWithMarkerObjectsArray:markersInRegion parentController:self];
                    
                    /// Customize cluster
                    if([self.delegate respondsToSelector:@selector(clusterController:configureClusterAnnotationForDisplay:)]){
                        [self.delegate clusterController:self configureClusterAnnotationForDisplay:cluster];
                    }
                    //cluster.title = [[NSString alloc] initWithFormat:@"%d", markersInRegion.count ];
                    
                    [newClusters addObject:cluster];
                }
            }*/
        
        //NSLog(@"%f %f %d", leftBottomCorner.latitude, leftBottomCorner.longitude, [self getMarkerObjectsInMapRect:MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude, gridDimension*clusterAreaSize, gridDimension*clusterAreaSize)].count);
        
        
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
        NSLog(@"chk4");
    }
}

/*-(NSMutableArray *)getMarkerObjectsInMapRect:(MKMapRect)mapRect
{
    NSMutableArray * result = [NSMutableArray array];
    for (uTikoMKAnnotationObject * markerObject in self.annotationObjects) {
        if (!(markerObject.coordinate.latitude==0 && markerObject.coordinate.longitude==0) && [self isCoordinate:markerObject.coordinate inMapRect:mapRect])
            [result addObject:markerObject];
    }
    return result;
}*/

- (NSArray *)generateVisibleCustersForGridWithDimention:(NSInteger)gridDimension
                                       leftBottomCorner:(CLLocationCoordinate2D)leftBottomCorner
                                        clusterAreaSize:(float)clusterAreaSize
{
    NSLog(@"chk1");
    NSMutableDictionary * grid = [NSMutableDictionary dictionary];
    float visibleAreaSize = clusterAreaSize * gridDimension;
    for (uTikoMKAnnotationObject * annotationObject in self.annotationObjects) {
        MKMapRect visibleMapRect = MKMapRectMake(leftBottomCorner.longitude, leftBottomCorner.latitude, visibleAreaSize, visibleAreaSize);
        CLLocationCoordinate2D annotationCoordinate = annotationObject.coordinate;
        if ([self isCoordinate:annotationObject.coordinate inMapRect:visibleMapRect]) {
            if (annotationCoordinate.longitude < leftBottomCorner.longitude) annotationCoordinate.longitude += 360;
            if (annotationCoordinate.longitude > leftBottomCorner.longitude + visibleAreaSize) annotationCoordinate.longitude -= 360;
            int clusterGridCol = (int)trunc((annotationCoordinate.longitude - leftBottomCorner.longitude) / clusterAreaSize);
            int clusterGridRow = (int)trunc((annotationCoordinate.latitude - leftBottomCorner.latitude) / clusterAreaSize);
            NSString * key = [NSString stringWithFormat:@"%d-%d", clusterGridCol, clusterGridRow];
            if (![grid objectForKey:key]) [grid setObject:[NSMutableArray array] forKey:key];
            NSMutableArray * clusterAnnotations = [grid objectForKey:key];
            [clusterAnnotations addObject:annotationObject];
        }
    }
    NSLog(@"chk2");
    NSMutableArray * result = [NSMutableArray array];
    for (int row = 0; row < gridDimension; row++) {
        for (int col = 0; col < gridDimension; col++) {
            NSString * key = [NSString stringWithFormat:@"%d-%d", col, row];
            if ([[grid objectForKey:key] isKindOfClass:[NSArray class]]) {
                NSArray * annotations = [grid objectForKey:key];
                if (annotations.count > 0) {
                    uTikoMKClusterAnnotation * cluster = [[uTikoMKClusterAnnotation alloc] initWithMarkerObjectsArray:annotations parentController:self];
                    [result addObject:cluster];
                }
            }
        }
    }
    NSLog(@"chk3");
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
