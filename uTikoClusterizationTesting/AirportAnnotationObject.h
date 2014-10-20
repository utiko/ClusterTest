//
//  AirportAnnotationObject.h
//  uTikoClusterizationTesting
//
//  Created by Kostya Kolesnyk on 10/20/14.
//  Copyright 2014 Stfalcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uTikoMKAnnotationObject.h"

@interface AirportAnnotationObject : uTikoMKAnnotationObject {
    
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString * code;

@end
