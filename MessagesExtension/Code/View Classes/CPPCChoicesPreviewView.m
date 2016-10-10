//
//  CPPCChoicesPreviewView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/10/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesPreviewView.h"
#import "UIImage+Optimizations.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation CPPCChoicesPreviewView

- (instancetype)initWithImageAssets:(NSArray *)images {
    
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]) {
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        int imageCount;
        
        for(UIImage *image in images) {
            
            UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
            imageLayer.contentMode = UIViewContentModeScaleAspectFill;
            imageLayer.image = image;
            imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
            imageLayer.layer.borderWidth = 6;
            imageLayer.layer.masksToBounds = YES;
            imageLayer.layer.shadowColor = [UIColor blackColor].CGColor;
            imageLayer.layer.shadowOffset = CGSizeMake(2, 2);
            imageLayer.layer.shadowOpacity = 0.8;
            imageLayer.layer.shadowRadius = 5;
            imageLayer.layer.shouldRasterize = YES;
            imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            
            if(imageCount == 1) {
                imageLayer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));

            } else if(imageCount == 2) {
                imageLayer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
            }
            
            imageCount++;
            
            [self addSubview:imageLayer];
            
        }
    }
    
    return self;
}

@end
