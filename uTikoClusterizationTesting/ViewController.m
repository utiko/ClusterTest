//
//  ViewController.m
//  uTikoClusterizationTesting
//
//  Created by Kostya Kolesnyk on 10/20/14.
//  Copyright (c) 2014 Stfalcon. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "uTikoMKClusterController.h"
#import "McDonaldsAnnotationObject.h"
#import "ClusterAnnotationView.h"

@interface TestAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation TestAnnotation


@end

@interface ViewController () <MKMapViewDelegate, uTikoMKClusterControllerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, strong) uTikoMKClusterController * clusterController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clusterController = [[uTikoMKClusterController alloc] initWithMapView:self.mapView];
    self.clusterController.delegate = self;
    [self loadObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)loadObjects
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"McdonFiltered" ofType:@"plist"];
    NSArray * data = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray * annotationObjectsArray = [NSMutableArray array];
    for (NSDictionary * dataDict in data) {
        if ([dataDict isKindOfClass:[NSDictionary class]]) {
            McDonaldsAnnotationObject * annotationObject = [[McDonaldsAnnotationObject alloc] initWithDictionary:dataDict];
            [annotationObjectsArray addObject:annotationObject];
            
            //TestAnnotation * annotation = [[TestAnnotation alloc] init];
            //annotation.coordinate = annotationObject.coordinate;
            //[self.mapView addAnnotation:annotation];
        }
    }
    [self.clusterController addMarkerObjects:annotationObjectsArray];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.clusterController refreshMarkers];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString * annotationIdentifier = @"annotation";
    NSString * clusterAnnotationIdentifier = @"clusterAnnotation";
    if ([annotation isKindOfClass:[uTikoMKClusterAnnotation class]]) {
        uTikoMKClusterAnnotation * cluster = (uTikoMKClusterAnnotation *)annotation;
        if (cluster.annotationObjects.count == 1) {
            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
            if (!annotationView) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            }
            annotationView.image = [UIImage imageNamed:@"icon_pin.png"];
            annotationView.centerOffset = CGPointMake(0, 0);
            return annotationView;
        } else {
            ClusterAnnotationView * clusterAnnotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:clusterAnnotationIdentifier];
            if (!clusterAnnotationView) {
                clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:clusterAnnotationIdentifier];
            }
            clusterAnnotationView.image = [UIImage imageNamed:@"icon_cluster.png"];
            [clusterAnnotationView setClusterAnnotationText:[NSString stringWithFormat:@"%lu", (unsigned long)cluster.annotationObjects.count]];
            clusterAnnotationView.centerOffset = CGPointMake(0, 0);
            return clusterAnnotationView;
        }
    } else {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        annotationView.image = [UIImage imageNamed:@"icon_pin.png"];
        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height / 2);
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[uTikoMKClusterAnnotation class]]) {
        uTikoMKClusterAnnotation * clusterAnnotation = view.annotation;
        if (clusterAnnotation.annotationObjects.count > 1) {
            float minLatitude = 0;
            float minLongitude = 0;
            float maxLatitude = 0;
            float maxLongitude = 0;
            int i = 0;
            for (uTikoMKAnnotationObject * annotationObject in clusterAnnotation.annotationObjects) {
                if (i == 0) {
                    minLatitude = annotationObject.coordinate.latitude;
                    maxLatitude = annotationObject.coordinate.latitude;
                    minLongitude = annotationObject.coordinate.longitude;
                    maxLongitude = annotationObject.coordinate.longitude;
                } else {
                    if (annotationObject.coordinate.latitude < minLatitude) minLatitude = annotationObject.coordinate.latitude;
                    if (annotationObject.coordinate.longitude < minLongitude) minLongitude = annotationObject.coordinate.longitude;
                    if (annotationObject.coordinate.latitude > maxLatitude) maxLatitude = annotationObject.coordinate.latitude;
                    if (annotationObject.coordinate.longitude > maxLongitude) maxLongitude = annotationObject.coordinate.longitude;
                }
                i++;
            }
            float delta = 0;
            if (fabs(maxLongitude - minLongitude) > fabs(maxLatitude - minLatitude)) {
                delta = fabs(maxLongitude - minLongitude) * 1.1;
            } else {
                delta = fabs(maxLatitude - minLatitude) * 1.1;
            }
            if (delta > 0.00042){
                [mapView deselectAnnotation:clusterAnnotation animated:NO];
                MKCoordinateRegion newRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake((minLatitude + maxLatitude) / 2, (minLongitude + maxLongitude) / 2), MKCoordinateSpanMake(delta, delta));
                [self.mapView setRegion:newRegion animated:YES];
            } else {
                clusterAnnotation.selectedObject ++;
                if (clusterAnnotation.selectedObject >= clusterAnnotation.annotationObjects.count) clusterAnnotation.selectedObject = 0;
                //facility = [[clusterAnnotation.annotationObjects allObjects] objectAtIndex:clusterAnnotation.selectedObject];
            }
        } else if (clusterAnnotation.annotationObjects.count == 1) {

        }
        
    }
}


@end
