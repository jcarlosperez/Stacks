//
//  STKSCameraViewController.h
//  Stacks
//
//  Created by Juan Carlos Perez on 10/15/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface STKSCameraViewController : UIViewController

@property (nonatomic, copy) void (^imageCaptured)(UIImage *image);

@end
