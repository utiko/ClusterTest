
#import "ClusterAnnotationView.h"

@implementation ClusterAnnotationView
@synthesize coordinate;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 32.f, 28.f)];
        clusterLabel.textColor = [UIColor blackColor];
        clusterLabel.backgroundColor = [UIColor clearColor];
        clusterLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:8.f];
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
