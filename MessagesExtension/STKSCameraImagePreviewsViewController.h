//
//  STKSCameraImagePreviewsViewController.h
//  Stacks
//
//  Created by Ben Rosen on 11/1/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKSCameraImagePreviewsViewController : UIViewController

@property (nonatomic, assign) NSInteger nextImageIndex;

- (CGPoint)indexPointsForTappedImageAtPoint:(CGPoint)point;

- (void)updateImageAtIndexWithNextAvailableImage:(NSInteger)index;

@end
