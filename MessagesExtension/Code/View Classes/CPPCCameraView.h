//
//  CPPCCameraView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/15/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

typedef enum {
    FrontView,
    BackView,
    UnknownView
} CameraMode;

@class CPPCCameraView;
@protocol CPPCCameraViewDelegate <NSObject>
- (void)didCaptureNewImage:(UIImage *)image;
@end

@interface CPPCCameraView : UIView
@property (nonatomic, weak) id <CPPCCameraViewDelegate> delegate;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) AVCaptureDeviceInput  *captureInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *livePreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIButton *captureTrigger;
- (void)updatePreviewLayer;
@end
