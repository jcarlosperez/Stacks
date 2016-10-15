//
//  CPPCCameraView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/15/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCCameraView.h"
#import "CompactConstraint.h"

@implementation CPPCCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        _inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_inputDevice error:nil];
        
        AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [captureOutput setVideoSettings:videoSettings];
        _captureSession = [[AVCaptureSession alloc] init];
        NSString* preset = 0;
        if (!preset) {
            preset = AVCaptureSessionPresetPhoto;
        }
        _captureSession.sessionPreset = preset;
        if ([_captureSession canAddInput:_captureInput]) {
            [_captureSession addInput:_captureInput];
        }
        
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
        [_captureSession addOutput:_stillImageOutput];
        
        _livePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        
        _livePreviewLayer.frame = CGRectMake(10, 10, 240, self.frame.size.height - 20);
        _livePreviewLayer.cornerRadius = 10;
        _livePreviewLayer.masksToBounds = YES;
        _livePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer: _livePreviewLayer];
        
        [_captureSession startRunning];
        
        if ([_inputDevice hasFlash] == YES) {
            [_inputDevice lockForConfiguration:nil];
            _inputDevice.flashMode = AVCaptureFlashModeAuto;
        }
        
        _captureTrigger = [[UIButton alloc] initWithFrame:CGRectZero];
        [_captureTrigger addTarget:self action:@selector(triggerShutter:) forControlEvents:UIControlEventTouchUpInside];
        [_captureTrigger setImage:[UIImage imageNamed:@"cameraShutter"] forState:UIControlStateNormal];
        [_captureTrigger setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _captureTrigger.layer.cornerRadius = 20;
        _captureTrigger.layer.masksToBounds = YES;
        _captureTrigger.userInteractionEnabled = YES;
        [self addSubview:_captureTrigger];
        
        

    }
    
    return self;
}

- (void)updatePreviewLayer {
    
    _livePreviewLayer.frame = CGRectMake(10, 10, 240, self.frame.size.height - 20);
    _captureTrigger.frame = CGRectMake((_livePreviewLayer.frame.size.width/2)-25,_livePreviewLayer.frame.size.height - 70, 50, 50);
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray * Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ;
    for (AVCaptureDevice *Device in Devices) if (Device.position == position ) return Device;
    
    return nil;
}

- (CameraMode)cameraMode {
    NSArray * inputs = _captureSession.inputs;
    for ( AVCaptureDeviceInput *INPUT in inputs ) {
        AVCaptureDevice *Device = INPUT.device ;
        if ([Device hasMediaType : AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = Device.position;
            
            if (position == AVCaptureDevicePositionFront) {
                return FrontView;
            } else {
                return BackView;
            }
            break;
        }
    }
    return UnknownView;
}

- (void)switchCamera {
    if ([self cameraMode] == BackView) {
        [self toggleCamera:FrontView];
    }
    else if ([self cameraMode] == FrontView) {
        [self toggleCamera:BackView];
    }
    
}

- (void)toggleCamera:(CameraMode)cameraViewMode {
    NSArray * inputs = _captureSession.inputs;
    for ( AVCaptureDeviceInput *INPUT in inputs ) {
        AVCaptureDevice *Device = INPUT.device ;
        if ([Device hasMediaType : AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = Device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront) {
                if (cameraViewMode == BackView) {
                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                } else {
                    return;
                }
            } else {
                if (cameraViewMode == FrontView) {
                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                } else {
                    return;
                }
            }
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [_captureSession beginConfiguration];
            
            [_captureSession removeInput : INPUT];
            [_captureSession addInput : newInput];
            
            [_captureSession commitConfiguration];
            break;
        }
    }
    
}

- (void)triggerShutter:(UIButton *)button {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *imgTaken = [[UIImage alloc] initWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didCaptureNewImage:imgTaken];
        });
        //UIImageWriteToSavedPhotosAlbum(imgTaken, nil, nil, nil);
    }];
}

@end
