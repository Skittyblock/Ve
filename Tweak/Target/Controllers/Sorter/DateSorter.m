//
//  DateSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "DateSorter.h"
#import "../../../../Utils/DateUtil.h"

@implementation DateSorter

/**
 * Returns an array of specifiers sorted by date.
 *
 * @return The specifiers array.
 */
- (NSArray *)getSpecifiers {
    NSMutableArray *specifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary *json = [[LogManager sharedInstance] getJson];
    NSMutableArray *logs = [[LogManager sharedInstance] getLogsFromJson:json];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale autoupdatingCurrentLocale];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    // Display "Today" or "Yesterday" instead of the date if applicable.
    formatter.doesRelativeDateFormatting = YES;

    for (NSDate *date in [self getUniqueDatesForLogs:logs]) {
        NSString *dateString = [formatter stringFromDate:date];
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:dateString]];

        for (NSDictionary *dictionary in logs) {
            Log *log = [Log logFromDictionary:dictionary];

            if ([DateUtil isDate:[log date] inDate:date]) {
                [specifiers addObject:[self createSpecifierForLog:log]];
            }
        }
    }

    return specifiers;
}

/**
 * Returns a unique array of start-of-day dates from logs.
 *
 * @param logs The logs from which to get the dates from.
 *
 * @return The array of unique dates.
 */
- (NSArray<NSDate *> *)getUniqueDatesForLogs:(NSArray *)logs {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSMutableOrderedSet<NSDate *> *dates = [[NSMutableOrderedSet alloc] init];

    for (NSDictionary *dictionary in logs) {
        Log *log = [Log logFromDictionary:dictionary];
        [dates addObject:[calendar startOfDayForDate:[log date]]];
    }

    return [dates sortedArrayUsingComparator:^NSComparisonResult(NSDate *a, NSDate *b) {
        return [b compare:a];
    }];
}

@end
