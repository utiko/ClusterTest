//
//  uTikoGMMarkerObject.m
//  MegaSOS
//
//  Created by Kostya Kolesnyk on 7/18/13.
//  Copyright (c) 2013 Kostya Kolesnyk. All rights reserved.
//

#import "uTikoGMMarkerObject.h"

@implementation uTikoGMMarkerObject

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate tag:(NSInteger)tag
{
    self = [super init];
    self.tag = tag;
    self.coordinate = coordinate;
    return self;
}

@end
