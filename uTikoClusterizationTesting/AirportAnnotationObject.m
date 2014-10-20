//
//  AirportAnnotationObject.m
//  uTikoClusterizationTesting
//
//  Created by Kostya Kolesnyk on 10/20/14.
//  Copyright 2014 Stfalcon. All rights reserved.
//

#import "AirportAnnotationObject.h"


@implementation AirportAnnotationObject

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    float latitude = [[dictionary objectForKey:@"Latitude"] floatValue];
    float longitude = [[dictionary objectForKey:@"Longitude"] floatValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.code = [dictionary objectForKey:@"Code"];
    
    return self;
}

@end
