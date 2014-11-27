//
//  uTikoMKAnnotationObject.m
//  Keepsnap
//
//  Created by Kostya Kolesnyk on 8/27/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import "uTikoMKAnnotationObject.h"

@implementation uTikoMKAnnotationObject

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate tag:(NSString *)tag
{
    self = [super init];
    self.tag = tag;
    self.coordinate = coordinate;
    return self;
}

@end
