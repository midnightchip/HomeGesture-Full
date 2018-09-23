#import "ccbanner.h"
#import <Preferences/PSSpecifier.h>

 NSString *const PATH_TO_IMAGE = @"/Library/PreferenceBundles/HomeGesture.bundle/cc.png";

@implementation ccbanner

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        UIImage *img = [UIImage imageNamed:PATH_TO_IMAGE];
        CGFloat constant = (width / img.size.width);
        UIImageView *iv = [[UIImageView alloc] initWithFrame: CGRectMake(0,0, width, img.size.height * constant)];
        [iv setContentMode: UIViewContentModeScaleAspectFit];
        [iv setImage:img];
        self.backgroundColor = [UIColor clearColor];
        [self addSubview: iv];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIImage *img = [UIImage imageNamed:PATH_TO_IMAGE];
    CGFloat constant = (width / img.size.width);
    return (CGFloat)img.size.height * constant;

}
@end
