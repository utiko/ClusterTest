//
//  uTikoMKAnnotationObject.h
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface uTikoMKAnnotationObject : NSObject

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate tag:(NSString *)tag;
@property CLLocationCoordinate2D coordinate;
@property NSString * tag;
@property id info;

@end
