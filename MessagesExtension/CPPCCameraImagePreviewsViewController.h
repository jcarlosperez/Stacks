//
//  CPPCCameraImagePreviewsViewController.h
//  PicChoose
//
//  Created by Ben Rosen on 11/1/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCCameraImagePreviewsViewController : UIViewController

@property (nonatomic, assign) NSInteger nextImageIndex;

- (NSInteger)indexForTappedPoint:(CGPoint)point;

- (void)updateImageAtIndexWithNextAvailableImage:(NSInteger)index;

@end
