//
//  McDonaldsAnnotationObject.m
//  uTikoClusterizationTesting
//
//  Created by Kostia on 26.11.14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import "McDonaldsAnnotationObject.h"

@implementation McDonaldsAnnotationObject

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    NSDictionary * location = [dictionary objectForKey:@"location"];
    float latitude = [[location objectForKey:@"lat"] floatValue];
    float longitude = [[location objectForKey:@"lng"] floatValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    return self;
}

@end
