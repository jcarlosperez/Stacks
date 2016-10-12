//
//  CPPCUtilities.m
//  PicChoose
//
//  Created by Ben Rosen on 10/11/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCUtilities.h"

@implementation CPPCUtilities

+ (NSURL *)URLFromQuestion:(NSString *)question imageNames:(NSArray<NSString *>*)imageNames {
    // make a string with all the image names in this format: image1,image2,image3
    NSMutableString *imageNamesString = [NSMutableString string];
    for (int i = 0; i < [imageNames count]; i++) {
        // put commas before each name, except for the first one
        if (i != 0) {
            [imageNamesString appendString:@"&"];
        }
        [imageNamesString appendFormat:@"pictures[]=%@", imageNames[i]];
    }

    // make the whole string,
    NSString *base = [[NSString stringWithFormat:@"http://picchoose.com/choice/info.php?question=%@&%@", question, imageNamesString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

    return [NSURL URLWithString:base];
}

@end