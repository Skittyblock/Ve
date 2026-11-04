#import "VeSliderCell.h"
#import <Preferences/PSSpecifier.h>

@implementation VeSliderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
            scaledFontForFont:[UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightRegular]];
        self.valueLabel.adjustsFontForContentSizeCategory = YES;
        self.valueLabel.textColor = [UIColor secondaryLabelColor];
        self.valueLabel.textAlignment = NSTextAlignmentNatural;
        self.valueLabel.isAccessibilityElement = NO;
        self.accessoryView = self.valueLabel;
        [self updateValue];
    }
    return self;
}

- (void)setValue:(id)value {
    [super setValue:value];
    [self updateValue];
}

- (void)controlChanged:(UIControl *)control {
    [super controlChanged:control];
    [self updateValue];
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    [self updateValue];
}

- (void)updateValue {
    UISlider *slider = (UISlider *)self.control;
    self.valueLabel.text = [NSString localizedStringWithFormat:@"%.0f", slider.value];
    [self.valueLabel sizeToFit];
    [self setNeedsLayout];
}

@end
