//
//  Util.m
//  GeekUpload
//
//  Created by hl on 2021/1/28.
//

#import "Util.h"

@implementation Util

+ (NSDate *) convert:(NSString *)time {
    NSLog(@"date: %@", [NSDate dateWithTimeIntervalSince1970: [time floatValue]]);
    return [NSDate dateWithTimeIntervalSince1970: [time floatValue]];
}

@end
