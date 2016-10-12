//
//  UIImage+Optimizations.m
//  PicChoose
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "UIImage+Optimizations.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation UIImage (Optimizations)

- (UIImage *)scaledImageToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage *)imageBorderedWithColor:(UIColor *)color borderWidth:(CGFloat)width {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawAtPoint:CGPointZero];
    [color setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    path.lineWidth = width;
    [path stroke];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageFromView:(UIView *)view {
    CGSize itemSize = CGSizeMake(view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)previewImageFromSelectedImages:(NSArray <UIImage *>*)images {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    
    for (int i = 0; i < [images count]; i++) {
        
        UIImage *image = images[i];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(2, 2);
        containerView.layer.shadowOpacity = 0.8;
        containerView.layer.shadowRadius = 10;
        
        UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        imageLayer.contentMode = UIViewContentModeScaleAspectFill;
        imageLayer.image = image;
        imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
        imageLayer.layer.borderWidth = 6;
        imageLayer.layer.masksToBounds = YES;
        imageLayer.layer.shouldRasterize = YES;
        imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [containerView addSubview:imageLayer];
        [backgroundView addSubview:containerView];
        
        
        if (i == 0) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));
        } else if (i == 1) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
        }
        
    }
    return [self imageFromView:backgroundView];
}

@end
