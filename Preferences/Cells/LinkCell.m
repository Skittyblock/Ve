//
//  LinkCell.m
//  Akarii Utils
//
//  Created by Alexandra Aurora Göttlicher
//

#import "LinkCell.h"

@implementation LinkCell
/**
 * Initializes the link cell.
 *
 * @param style
 * @param reuseIdentifier
 * @param specifier
 *
 * @return The cell.
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
        NSString *title = [specifier propertyForKey:@"label"];
        NSString *subtitle = [specifier propertyForKey:@"subtitle"];

        self.selectionStyle = UITableViewCellSelectionStyleDefault;

        self.textLabel.text = title;

        if (subtitle) {
            self.detailTextLabel.text = subtitle;
            self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        }

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"safari"]];
        imageView.tintColor = [UIColor systemGray3Color];
        self.accessoryView = imageView;
    }

    return self;
}
@end
