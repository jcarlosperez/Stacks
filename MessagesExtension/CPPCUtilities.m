//
//  CPPCUtilities.m
//  PicChoose
//
//  Created by Ben Rosen on 10/11/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCUtilities.h"
#import <Photos/Photos.h>

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
    
    // make a string with all the image names in this format: image1,image2,image3
    NSMutableString *imageNamesString = [NSMutableString string];
    NSMutableString *imageRatingsString = [NSMutableString string];
    
    for (int i = 0; i < [imageNames count]; i++) {
        
        if (i != 0) {
            [imageNamesString appendString:@"&"];
        }
        
        [imageNamesString appendFormat:@"pictures[]=%@", imageNames[i]];
        
        if([ratings objectForKey:[NSString stringWithFormat:@"image%d", i]]) {
            [imageRatingsString appendFormat:@"&image%d[]=%@", i, [[ratings objectForKey:[NSString stringWithFormat:@"image%d", i]] stringValue]];
        } else {
            [imageRatingsString appendFormat:@"&image%d[]=0", i];
        }
    }
    
    // make the whole string,
    NSString *base = [[NSString stringWithFormat:@"http://picchoose.com/choice/info.php?%@%@", imageNamesString, imageRatingsString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    return [NSURL URLWithString:base];
}

+ (NSArray *)imageNamesFromURL:(NSURL *)URL {
    NSString *query = URL.query.stringByRemovingPercentEncoding;
    
    if([query containsString:@"&image"]) {
        NSRange rangeToRatings = [query rangeOfString:@"&image" options:NSCaseInsensitiveSearch];
        query = [query substringToIndex:rangeToRatings.location];
    }
    
    NSString *imageNames = [query stringByReplacingOccurrencesOfString:@"pictures[]=" withString:@""];
    NSArray *imageNamesParsed = [imageNames componentsSeparatedByString:@"&"];
    return imageNamesParsed;
}

+ (NSDictionary *)ratingsFromURL:(NSURL *)URL {
    
    NSString *query = URL.query.stringByRemovingPercentEncoding;
    
    if(![query containsString:@"&image"]) {
        return nil;
    }
    // Get the range up to the first image rating
    NSRange rangeToRatings = [query rangeOfString:@"&image" options:NSCaseInsensitiveSearch];
    // Trim the picture keys since not needed for the ratings
    query = [query substringWithRange:NSMakeRange(rangeToRatings.location+1, (query.length-rangeToRatings.location)-1)];
    // Remove brackets before parsing into dictionary
    query = [query stringByReplacingOccurrencesOfString:@"[]" withString:@""];
    
    return [self parsedQueryString:query];
}

+ (NSDictionary *)parsedQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
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
