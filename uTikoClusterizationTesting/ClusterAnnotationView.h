
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ClusterAnnotationView : MKAnnotationView <MKAnnotation> {
    UILabel *clusterLabel;
}

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (void)setClusterAnnotationText:(NSString *)text;

@end
