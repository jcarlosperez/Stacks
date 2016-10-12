//
//  UIImage+Optimizations.h
//  PicChoose
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Optimizations)

- (UIImage *)scaledImageToSize:(CGSize)size;

- (UIImage *)imageBorderedWithColor:(UIColor *)color borderWidth:(CGFloat)width;

+ (UIImage *)previewImageFromSelectedImages:(NSArray <UIImage *>*)images;

@end
