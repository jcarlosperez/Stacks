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
        
        self.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        
        int imageCount;
        
        for(UIImage *image in images) {
            
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
            [self addSubview:containerView];
            
            if(imageCount == 1) {
                containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));

            } else if(imageCount == 2) {
                containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
            }
            
            imageCount++;
            
        }
    }
    
    return self;
}

@end
