//
//  VeDetailListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractListController.h"

@class Log;

NSUserDefaults* preferences;
NSMutableArray* pfBlockedSenders;

@interface VeDetailListController : AbstractListController
@property(nonatomic)UIButton* removeButton;
@property(nonatomic)UIBarButtonItem* item;
@property(nonatomic)Log* log;
@end
