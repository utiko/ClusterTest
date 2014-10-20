//
//  uTikoGMSMapView.m
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 3/25/14.
//  Copyright (c) 2014 Kostya Kolesnyk. All rights reserved.
//

#import "uTikoGMSMapView.h"


@implementation uTikoGMSMapView {
    NSMutableArray * markers;
}

-(NSArray *)getMarkersInMapRect:(MKMapRect)mapRect
{
    NSMutableArray *result = [NSMutableArray array];
    for (GMSMarker * marker in self.markers) {
        if ([self isCoordinate:marker.position inMapRect:mapRect])
            [result addObject:marker];
    }
    return [NSArray arrayWithArray:result];
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

-(NSArray *)markers
{
    if (!markers) markers = [NSMutableArray array];
    return [NSArray arrayWithArray: markers];
}

- (void)addMarker: (GMSMarker *)marker
{
    marker.map = self;
    if (!markers) markers = [NSMutableArray array];
    [markers addObject:marker];
}

- (void)removeMarker: (GMSMarker *)marker
{
    if ([self.markers containsObject:marker]) {
        [markers removeObject:marker];
        marker.map = nil;
    }
}

@end
