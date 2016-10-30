//
//  CPPCCameraViewController.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/15/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface CPPCCameraViewController : UIViewController

@property (nonatomic, copy) void (^imageCaptured)(UIImage *image);

@end
