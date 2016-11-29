//
//  CPPCUtilities.h
//  PicChoose
//
//  Created by Ben Rosen on 10/11/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCUtilities : NSObject

+ (NSURL *)URLFromImageNames:(NSArray<NSString *>*)imageNames;

+ (NSURL *)URLFromImageNames:(NSArray<NSString *>*)imageNames andRatings:(NSDictionary *)ratings;

+ (NSArray *)imageNamesFromURL:(NSURL *)URL;

+ (NSDictionary *)ratingsFromURL:(NSURL *)URL;

+ (void)recentImageNumberFromRecent:(NSInteger)imageNumber completionBlock:(void (^)(UIImage *image))completionBlock;

@end
