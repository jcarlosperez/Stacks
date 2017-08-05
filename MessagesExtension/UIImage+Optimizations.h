//
//  UIImage+Optimizations.h
//  Stacks
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Optimizations)

- (UIImage *)scaledImageToSize:(CGSize)size;

- (UIImage *)imageBorderedWithColor:(UIColor *)color borderWidth:(CGFloat)width;

+ (UIImage *)imageFromView:(UIView *)view;

@end
