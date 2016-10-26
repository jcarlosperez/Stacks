//
//  CPPCMessagesViewController.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCMessagesViewController.h"
#import "CPPCCameraView.h"
#import "CPPCChoicesCollectionView.h"
#import "CPPCSelectionCollectionView.h"
#import "CompactConstraint.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "CPPCServerManager.h"
#import "UIImage+Optimizations.h"
#import "RXPromise.h"
#import "CPPCUtilities.h"

@interface CPPCMessagesViewController () <CPPCCameraViewDelegate, CTAssetsPickerControllerDelegate> {
    BOOL _presentingCameraView;
    BOOL _presentingSelectionView;
}

@property (nonatomic, strong) CPPCCameraView *cameraView;
@property (nonatomic, strong) CPPCChoicesCollectionView *choicesCollectionView;
@property (nonatomic, strong) CPPCSelectionCollectionView *selectionCollectionView;

@property (nonatomic, strong) UIButton *cameraImageButton;
@property (nonatomic, strong) UIButton *libraryImageButton;
@property (nonatomic, strong) UIButton *createMessageButton;

@property (nonnull, strong) UILabel *stacksNameLabel;

@property (strong, nonatomic) UILabel *clickAddLabel;

@end

@implementation CPPCMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.957 green:0.965 blue:0.969 alpha:1.00];
    
    _stacksNameLabel = [[UILabel alloc] init];
    _stacksNameLabel.text = @"STACKS";
    _stacksNameLabel.textAlignment = NSTextAlignmentCenter;
    _stacksNameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    _stacksNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_stacksNameLabel];
    
    _createMessageButton = [[UIButton alloc] init];
    _createMessageButton.enabled = NO;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    [_createMessageButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_createMessageButton setTitle:@"Select New Images" forState:UIControlStateDisabled];
    [_createMessageButton setTitle:@"Create Message Stack" forState:UIControlStateNormal];
    [_createMessageButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_createMessageButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_createMessageButton setTitleColor:[UIColor colorWithRed:1.00 green:0.00 blue:0.42 alpha:1.0] forState:UIControlStateHighlighted];
    _createMessageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_createMessageButton];
    
    _choicesCollectionView = [[CPPCChoicesCollectionView alloc] init];
    _choicesCollectionView.backgroundColor = [UIColor whiteColor];
    _choicesCollectionView.layer.cornerRadius = 10;
    _choicesCollectionView.layer.masksToBounds = YES;
    _choicesCollectionView.scrollEnabled = NO;
    _choicesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_choicesCollectionView];
    
    _clickAddLabel = [[UILabel alloc] init];
    _clickAddLabel.text = @"Click Library or Camera to add a picture";
    _clickAddLabel.textAlignment = NSTextAlignmentCenter;
    _clickAddLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_clickAddLabel];
    
    _cameraImageButton = [[UIButton alloc] init];
    _cameraImageButton.backgroundColor = [UIColor whiteColor];
    _cameraImageButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    _cameraImageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _cameraImageButton.layer.cornerRadius = 10;
    _cameraImageButton.layer.masksToBounds = YES;
    [_cameraImageButton addTarget:self action:@selector(cameraImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraImageButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_cameraImageButton setTitle:@"Camera" forState:UIControlStateNormal];
    [_cameraImageButton.titleLabel setTextColor:[UIColor blackColor]];
    [_cameraImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cameraImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cameraImageButton];
    
    _libraryImageButton = [[UIButton alloc] init];
    _libraryImageButton.backgroundColor = [UIColor whiteColor];
    _libraryImageButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    _libraryImageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _libraryImageButton.layer.cornerRadius = 10;
    _libraryImageButton.layer.masksToBounds = YES;
    [_libraryImageButton addTarget:self action:@selector(libraryImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_libraryImageButton setImage:[UIImage imageNamed:@"library"] forState:UIControlStateNormal];
    [_libraryImageButton setTitle:@"Library" forState:UIControlStateNormal];
    [_libraryImageButton.titleLabel setTextColor:[UIColor blackColor]];
    [_libraryImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _libraryImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_libraryImageButton];
    
    [self.view addCompactConstraints:@[@"stacksNameLabel.top = topLayoutGuide.bottom+10",
                                       @"stacksNameLabel.left = view.left+20",
                                       @"stacksNameLabel.height = 16",
                                       @"createMessageButton.top = topLayoutGuide.bottom+10",
                                       @"createMessageButton.bottom = stacksNameLabel.bottom",
                                       @"createMessageButton.right = view.right-20",
                                       @"cameraButton.bottom = bottomLayoutGuide.top-10",
                                       @"cameraButton.left = view.left+20",
                                       @"cameraButton.width = view.width/2.28",
                                       @"cameraButton.height = 50",
                                       @"libraryButton.bottom = bottomLayoutGuide.top-10",
                                       @"libraryButton.right = view.right-20",
                                       @"libraryButton.width = view.width/2.28",
                                       @"libraryButton.height = 50",
                                       @"choicesCollectionView.top = stacksNameLabel.bottom+10",
                                       @"choicesCollectionView.bottom = cameraButton.top-4",
                                       @"choicesCollectionView.left = view.left+20",
                                       @"choicesCollectionView.right = view.right-20",
                                       @"clickAddLabel.left = view.left",
                                       @"clickAddLabel.right = view.right",
                                       @"clickAddLabel.centerX = choicesCollectionView.centerX",
                                       @"clickAddLabel.centerY = choicesCollectionView.centerY"]
                             metrics:nil
                               views:@{@"stacksNameLabel": _stacksNameLabel,
                                       @"view": self.view,
                                       @"topLayoutGuide": self.topLayoutGuide,
                                       @"bottomLayoutGuide": self.bottomLayoutGuide,
                                       @"cameraButton": _cameraImageButton,
                                       @"libraryButton": _libraryImageButton,
                                       @"choicesCollectionView": _choicesCollectionView,
                                       @"clickAddLabel": _clickAddLabel,
                                       @"createMessageButton" : _createMessageButton}];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [_cameraView updatePreviewLayer];
}

- (void)sendPressed:(UIButton *)sender {
    // prep all the other stuff
    UIImage *previewImage = [UIImage previewImageFromSelectedImages:_choicesCollectionView.imageAssets];
    MSMessageTemplateLayout *messageLayout = [[MSMessageTemplateLayout alloc] init];
    messageLayout.subcaption = [NSString stringWithFormat:@"$%@ wants your help choosing!", self.activeConversation.localParticipantIdentifier];
    messageLayout.image = previewImage;
    
    NSMutableArray *allUploadedImageNames = [NSMutableArray array];
    for (UIImage *image in _choicesCollectionView.imageAssets) {
        RXPromise *promise = [[RXPromise alloc] init];
        promise.thenOnMain(^id(id result) {
            NSString *fileName = (NSString *)result;
            [allUploadedImageNames addObject:fileName];
            
            if (allUploadedImageNames.count == _choicesCollectionView.imageAssets.count) {
                // all images are uploaded, get the url
                NSURL *url = [CPPCUtilities URLFromImageNames:allUploadedImageNames];
                
                // we have everything. make the session, message, and add it
                MSSession *session = [[MSSession alloc] init];
                
                MSMessage *message = [[MSMessage alloc] initWithSession:session];
                message.layout = messageLayout;
                message.URL = url;
                message.summaryText = @"Choose an option";
                [self.activeConversation insertMessage:message completionHandler:nil];
            }
            return nil;
        }, nil);
        
        [[CPPCServerManager sharedInstance] uploadRawImage:image promise:promise];
    }
}

#pragma mark - CPCCCameraViewDelegate

- (void)didCaptureNewImage:(UIImage *)image {
    
    _createMessageButton.enabled = YES;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _clickAddLabel.alpha = 0;
        }];
    });
    
    [_choicesCollectionView updateViewWithImage:image];
}

#pragma mark - MSMessagesAppViewController Delegate Methods

- (void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    _choicesCollectionView.imageAssets = nil;
    _choicesCollectionView.imageAssets = [NSMutableArray new];
    [_choicesCollectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _clickAddLabel.alpha = 1;
        }];
    });
}

- (void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    NSLog(@"didTransitionToPresentationStyle:");
}

- (void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    
    if(presentationStyle == MSMessagesAppPresentationStyleCompact) {
        
        if(_presentingCameraView) {
            
            for(NSLayoutConstraint *constraint in self.view.constraints) {
                
                if((constraint.firstItem == _choicesCollectionView) && (constraint.firstAttribute == NSLayoutAttributeBottom)) {
                    [self.view removeConstraint:constraint];
                    
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_choicesCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cameraImageButton attribute:NSLayoutAttributeTop multiplier:1 constant:-4]];
                    
                } else if((constraint.firstItem == _choicesCollectionView) && (constraint.firstAttribute == NSLayoutAttributeHeight)) {
                    
                    [self.view removeConstraint:constraint];
                }
                
                [self.view updateConstraints];
                [super updateViewConstraints];
            }
            
            [_createMessageButton setTitle:@"Select New Images" forState:UIControlStateDisabled];
            [_createMessageButton setTitle:@"Create Message Stack" forState:UIControlStateNormal];
            
            _presentingCameraView = NO;
            [_cameraView removeFromSuperview];
            _cameraView = nil;
        }
        
        if(_presentingSelectionView) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    _choicesCollectionView.alpha = 1;
                }];
            });
            
            _presentingSelectionView = NO;
            [_selectionCollectionView removeFromSuperview];
            _selectionCollectionView = nil;
        }
    }
    
    if(presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        
        if(_presentingCameraView) {
            
            _cameraView = [[CPPCCameraView alloc] initWithFrame:CGRectZero];
            _cameraView.delegate = self;
            _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:_cameraView];
            
            [_createMessageButton setTitle:@"Rate the Images" forState:UIControlStateDisabled];
            [_createMessageButton setTitle:@"Create Message Stack" forState:UIControlStateNormal];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
            
            for(NSLayoutConstraint *constraint in self.view.constraints) {
                
                if((constraint.firstItem == _choicesCollectionView) && (constraint.firstAttribute == NSLayoutAttributeBottom)) {
                    
                    [self.view removeConstraint:constraint];
                    
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_choicesCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cameraView attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cameraImageButton attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_choicesCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:90]];
                }
                
                [self.view updateConstraints];
                [super updateViewConstraints];
            }
        }
        
        if(_presentingSelectionView) {
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_selectionCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_selectionCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_selectionCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_selectionCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    _choicesCollectionView.alpha = 0;
                }];
            });
        }
    }
}

#pragma mark - MSMessages Message selection

- (void)didSelectMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // check if message has a URL (only received or sent message have it) because this method is triggered a lot
    if (message.URL) {
        
        NSArray *imageNames = [CPPCUtilities imageNamesFromURL:message.URL];
        
        _presentingSelectionView = YES;
        
        _selectionCollectionView = [[CPPCSelectionCollectionView alloc] init];
        _selectionCollectionView.backgroundColor = [UIColor whiteColor];
        _selectionCollectionView.choiceImageKeys = imageNames;
        _selectionCollectionView.layer.cornerRadius = 10;
        _selectionCollectionView.layer.masksToBounds = YES;
        _selectionCollectionView.scrollEnabled = YES;
        _selectionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_selectionCollectionView];
        
    }
}

#pragma mark - PicChoose Image Selection

- (void)cameraImageButtonTapped:(UIButton *)button {
    _presentingCameraView = YES;
    [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
}

- (void)libraryImageButtonTapped:(UIButton *)button {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

#pragma mark - PicChoose Image Selection Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    
    _createMessageButton.enabled = YES;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHImageManager *manager = [PHImageManager defaultManager];
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^void(UIImage *image, NSDictionary *info) {
            [UIView animateWithDuration:0.5 animations:^{
                _clickAddLabel.alpha = 0;
            }];
            [_choicesCollectionView updateViewWithImage:image];
        }];
    }
}

@end
