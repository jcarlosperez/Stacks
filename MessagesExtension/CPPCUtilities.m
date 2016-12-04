//
//  CPPCUtilities.m
//  PicChoose
//
//  Created by Ben Rosen on 10/11/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCUtilities.h"
#import <Photos/Photos.h>
#import "CPPCStackManager.h"

@import AssetsLibrary;

@implementation CPPCUtilities

+ (NSURL *)URLFromImageNames:(NSArray<NSString *>*)imageNames {
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
    NSString *base = [[NSString stringWithFormat:@"http://picchoose.com/choice/info.php?%@", imageNamesString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

    return [NSURL URLWithString:base];
}

+ (NSURL *)URLFromImageNames:(NSArray<NSString *>*)imageNames andRatings:(NSDictionary *)ratings {
    NSString *preRatingsURLString = [self URLFromImageNames:imageNames].absoluteString;
    NSMutableString *imageRatingsString = [NSMutableString string];
    
    for (int i = 0; i < [ratings count]; i++) {
        NSLog(@"when we loop thruuuu %i", i);
        // put commas before each name, except for the first one
        
        NSString *key = [NSString stringWithFormat:@"image%i", i];
        [imageRatingsString appendFormat:@"&ratings[%@]=%@", key, ratings[key]];
    }

    
    // make the whole string,
    NSString *wholeURL = [[preRatingsURLString stringByAppendingString:imageRatingsString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSLog(@"THE BASE = %@", wholeURL);
    return [NSURL URLWithString:wholeURL];
}



+ (NSDictionary *)handleNewURL:(NSURL *)URL {
    NSString *query = URL.query.stringByRemovingPercentEncoding;
    
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableDictionary *ratings = [NSMutableDictionary dictionary];
    
    NSArray *imageNamesParsed = [query componentsSeparatedByString:@"&"];
    for (NSString *parsedComponent in imageNamesParsed) {
        NSArray *components = [parsedComponent componentsSeparatedByString:@"="];
        if ([components[0] containsString:@"pictures"]) {
            [keys addObject:components[1]];
        } else if ([components[0] containsString:@"ratings"]) {
            NSString *name = [[[components[0] stringByReplacingOccurrencesOfString:@"ratings" withString:@""] stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
            [ratings setValue:components[1] forKey:name];
        }
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (keys) {
        data[@"keys"] = keys;
    }
    
    if (ratings) {
        data[@"ratings"] = ratings;
    }
    return data;
}

+ (NSArray *)imageNamesFromURL:(NSURL *)URL {
    return [self handleNewURL:URL][@"keys"];
}

+ (NSDictionary *)ratingsFromURL:(NSURL *)URL {
    return [self handleNewURL:URL][@"ratings"];
}

+ (void)recentImageNumberFromRecent:(NSInteger)imageNumber completionBlock:(void (^)(UIImage *image))completionBlock {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *photos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    if (photos) {
        // 500x500 is the smallest you can do without it being pixelated
        [[PHImageManager defaultManager] requestImageForAsset:[photos objectAtIndex:imageNumber] targetSize:CGSizeMake(500, 500) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            completionBlock(result);
        }];
    }
}

@end
