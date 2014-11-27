//
//  uTikoGMSMapView.h
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 3/25/14.
//  Copyright (c) 2014 Kostya Kolesnyk. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>


@interface uTikoGMSMapView : GMSMapView

@property (nonatomic, strong, readonly) NSArray * markers;

- (NSArray *)getMarkersInMapRect:(MKMapRect)mapRect;
- (void)addMarker: (GMSMarker *)marker;
- (void)removeMarker: (GMSMarker *)marker;

@end
