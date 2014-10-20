//
//  uTikoGMMarkerObject.h
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface uTikoGMMarkerObject : NSObject

@property CLLocationCoordinate2D coordinate;
@property NSInteger tag;
@property id info;

@end
