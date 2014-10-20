
#import "ClusterAnnotationView.h"

@implementation ClusterAnnotationView
@synthesize coordinate;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 23.f, 24.f)];
        clusterLabel.textColor = [UIColor whiteColor];
        clusterLabel.backgroundColor = [UIColor clearColor];
        clusterLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.f];
        clusterLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:clusterLabel];
    }
    
    return self;
}

- (void)setClusterAnnotationText:(NSString *)text
{
    clusterLabel.text = text;
}


@end
