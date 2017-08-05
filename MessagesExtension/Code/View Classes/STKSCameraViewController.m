//
//  STKSCameraViewController.m
//  Stacks
//
//  Created by Juan Carlos Perez on 10/15/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSCameraViewController.h"
#import "CompactConstraint.h"
#import "STKSCameraImagePreviewsViewController.h"
#import "STKSStackManager.h"
#import "STKSUtilities.h"

@interface STKSCameraViewController () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) UIView *livePreviewContainerView;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *livePreviewLayer;

@property (nonatomic, strong) AVCapturePhotoOutput *capturePhotoOutput;

@property (nonatomic, strong) AVCapturePhotoSettings *photoSettings;

@property (nonatomic, strong) UIButton *captureTrigger;

@property (nonatomic, strong) STKSCameraImagePreviewsViewController *previewsViewController;

@end

@implementation STKSCameraViewController

- (instancetype)init {
    if (self = [super init]) {
        
        _photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecJPEG}];
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        [_captureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil]];
        [_captureSession addOutput:_capturePhotoOutput = [[AVCapturePhotoOutput alloc] init]];
        [_captureSession startRunning];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;
    self.view.exclusiveTouch = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
    // don't add the capture view directly as a layer, add it to a container and add that
    _livePreviewContainerView = [[UIView alloc] init];
    _livePreviewContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_livePreviewContainerView];
    
    _livePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _livePreviewLayer.cornerRadius = 10;
    _livePreviewLayer.masksToBounds = YES;
    _livePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_livePreviewContainerView.layer addSublayer:_livePreviewLayer];
    
    _captureTrigger = [[UIButton alloc] init];
    [_captureTrigger addTarget:self action:@selector(triggerShutter:) forControlEvents:UIControlEventTouchUpInside];
    [_captureTrigger setImage:[UIImage imageNamed:@"cameraShutter"] forState:UIControlStateNormal];
    [_captureTrigger setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _captureTrigger.layer.cornerRadius = 20;
    _captureTrigger.layer.masksToBounds = YES;
    _captureTrigger.translatesAutoresizingMaskIntoConstraints = NO;
    [_livePreviewContainerView addSubview:_captureTrigger];
    
    [_livePreviewContainerView addCompactConstraints:@[@"captureTrigger.centerX = livePreviewContainerView.centerX",
                                                       @"captureTrigger.bottom = livePreviewContainerView.bottom-20",
                                                       @"captureTrigger.height = 40",
                                                       @"captureTrigger.width = 40"]
                                             metrics:nil
                                               views:@{@"captureTrigger": _captureTrigger,
                                                       @"livePreviewContainerView": _livePreviewContainerView}];
    
    _previewsViewController = [[STKSCameraImagePreviewsViewController alloc] init];
    _previewsViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_previewsViewController.view];
    [_previewsViewController didMoveToParentViewController:self];
    
    [self.view addCompactConstraints:@[@"livePreviewContainerView.left = view.left+10",
                                       @"livePreviewContainerView.top = view.top+10",
                                       @"livePreviewContainerView.width = 240",
                                       @"livePreviewContainerView.height = self.height-20",
                                       @"previewsViewController.left = livePreviewContainerView.right+10",
                                       @"previewsViewController.top = livePreviewContainerView.top+6",
                                       @"previewsViewController.right = view.right-10",
                                       @"previewsViewController.bottom = livePreviewContainerView.bottom-6"]
                             metrics:nil
                               views:@{@"livePreviewContainerView": _livePreviewContainerView,
                                       @"previewsViewController": _previewsViewController.view,
                                       @"view": self.view}];
    
    UITapGestureRecognizer *switchCameraPositionRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCameraTriggered:)];
    switchCameraPositionRecognizer.numberOfTapsRequired = 2;
    [_livePreviewContainerView addGestureRecognizer:switchCameraPositionRecognizer];
    
    UITapGestureRecognizer *subviewImageSelectionRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSelectionRecognizer:)];
    subviewImageSelectionRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:subviewImageSelectionRecognizer];
    [subviewImageSelectionRecognizer requireGestureRecognizerToFail:switchCameraPositionRecognizer];
}



- (void)viewWillLayoutSubviews {
    // set the preview view to fit correctly once the view is properly loaded
    _livePreviewLayer.frame = _livePreviewContainerView.bounds;
}

- (void)switchCameraTriggered:(UITapGestureRecognizer *)gestureRecognizer {
    AVCaptureDeviceInput *input = _captureSession.inputs[0];
    AVCaptureDevicePosition wantedPosition = input.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:wantedPosition];
    
    [_captureSession removeInput:input];
    [_captureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:discoverySession.devices[0] error:nil]];
}

- (void)imageSelectionRecognizer:(UIGestureRecognizer *)recognizer {
    
    CGPoint tappedPoint = [recognizer locationInView:self.view];
    
    UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
    [feedbackGenerator prepare];
    
    if([STKSStackManager sharedInstance].images.count < 5) {
        
        if (CGRectContainsPoint(_previewsViewController.view.frame, tappedPoint)) {
            
            [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
            feedbackGenerator = nil;
            
            CGPoint imageIndexPoints = [_previewsViewController indexPointsForTappedImageAtPoint:tappedPoint];
            
            [STKSUtilities recentImageNumberFromRecent:imageIndexPoints.x completionBlock:^(UIImage *image) {
                _imageCaptured(image);
            }];
            
            [_previewsViewController updateImageAtIndexWithNextAvailableImage:imageIndexPoints.y];
        }
    } else {
        [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeError];
        feedbackGenerator = nil;
    }
}

#pragma mark - Shutter handling

- (void)triggerShutter:(UIButton *)button {
    
    if([STKSStackManager sharedInstance].images.count < 5) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_capturePhotoOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettingsFromPhotoSettings:_photoSettings] delegate:self];
        });
    } else {
        UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        [feedbackGenerator prepare];
        [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeError];
        feedbackGenerator = nil;
    }
    
}

#pragma mark - Photo Capturing Delegate

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    if (error) {
        NSLog(@"Error with capturing: %@", error);
        return;
    }
    
    UIImage *capturedImage = [UIImage imageWithData:[AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer]];
    // make sure to update this on the main thread—otherwise the app briefly hangs after an image is taken
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageCaptured(capturedImage);
    });
}

@end
