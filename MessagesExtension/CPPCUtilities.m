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

+ (NSArray *)imageNamesFromURL:(NSURL *)URL {
    NSString *query = URL.query.stringByRemovingPercentEncoding;
    NSString *imageNames = [query stringByReplacingOccurrencesOfString:@"pictures[]=" withString:@""];
    NSArray *imageNamesParsed = [imageNames componentsSeparatedByString:@"&"];
    return imageNamesParsed;
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

+ (NSString *)localFileURLFromImageName:(NSString *)imageName {
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:imageName];
}

@end
