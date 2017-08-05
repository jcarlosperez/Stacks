//
//  STKSMessagesViewController.m
//  Stacks
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSMessagesViewController.h"
#import "STKSCameraViewController.h"
#import "STKSChoicesCollectionView.h"
#import "STKSSelectionCollectionView.h"
#import "CompactConstraint.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "STKSServerManager.h"
#import "UIImage+Optimizations.h"
#import "RXPromise.h"
#import "STKSUtilities.h"
#import "STKSStackManager.h"

#define kMessageCreation 1
#define kResponseCreation 2

@interface STKSMessagesViewController () <STKSRatingDelegate, CTAssetsPickerControllerDelegate> {
    BOOL _hasRatedAnImage;
    BOOL _presentingCameraView;
    BOOL _presentingSelectionView;
}

@property (nonatomic, strong) STKSCameraViewController *cameraViewController;
@property (nonatomic, strong) STKSChoicesCollectionView *choicesCollectionView;
@property (nonatomic, strong) STKSSelectionCollectionView *selectionCollectionView;

@property (nonatomic, strong) UIButton *cameraImageButton;
@property (nonatomic, strong) UIButton *libraryImageButton;
@property (nonatomic, strong) UIButton *createMessageButton;

@property (nonnull, strong) UILabel *stacksNameLabel;

@property (strong, nonatomic) UILabel *clickAddLabel;

@end

@implementation STKSMessagesViewController

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:STKSImageChangeNotificationName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [_choicesCollectionView reloadData];
        }];
    }
    return self;
}

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
    _createMessageButton.tag = kMessageCreation;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    [_createMessageButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_createMessageButton setTitle:@"Select New Images" forState:UIControlStateDisabled];
    [_createMessageButton setTitle:@"Create Message Stack" forState:UIControlStateNormal];
    [_createMessageButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_createMessageButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_createMessageButton setTitleColor:[UIColor colorWithRed:1.00 green:0.00 blue:0.42 alpha:1.0] forState:UIControlStateHighlighted];
    _createMessageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_createMessageButton];
    
    _choicesCollectionView = [[STKSChoicesCollectionView alloc] init];
    _choicesCollectionView.backgroundColor = [UIColor whiteColor];
    _choicesCollectionView.layer.cornerRadius = 10;
    _choicesCollectionView.layer.masksToBounds = YES;
    _choicesCollectionView.scrollEnabled = NO;
    _choicesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_choicesCollectionView];
    
    _clickAddLabel = [[UILabel alloc] init];
    _clickAddLabel.text = @"Tap Library or Camera to add a picture";
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
                                       @"cameraButton.width = view.width/2.24",
                                       @"cameraButton.height = 50",
                                       @"libraryButton.bottom = bottomLayoutGuide.top-10",
                                       @"libraryButton.right = view.right-20",
                                       @"libraryButton.width = view.width/2.24",
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
    
    if(_selectionCollectionView) {
        UIEdgeInsets insets = _selectionCollectionView.contentInset;
        CGFloat value = (self.view.frame.size.width - ((UICollectionViewFlowLayout *)_selectionCollectionView.collectionViewLayout).itemSize.width) * 0.5;
        insets.left = value;
        insets.right = value;
        _selectionCollectionView.contentInset = insets;
        _selectionCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

- (void)handleNewImageSelected:(UIImage *)image {
    _createMessageButton.enabled = YES;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _clickAddLabel.alpha = 0;
        }];
    });
    
    [[STKSStackManager sharedInstance] addImage:image];
}

- (void)createNewMessageFromImageStack {
    
    if(self.presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
    }
    
    MSMessageTemplateLayout *messageLayout = [[MSMessageTemplateLayout alloc] init];
    messageLayout.subcaption = [NSString stringWithFormat:@"$%@ wants your help choosing!", self.activeConversation.localParticipantIdentifier];
    messageLayout.image = [STKSStackManager sharedInstance].previewImage;
    
    RXPromise *promise = [[RXPromise alloc] init];
    promise.thenOnMain(^id(id result) {
        
        [_choicesCollectionView updateCellWithActivityIndicators:NO];
        
        NSURL *url = [STKSUtilities URLFromImageNames:result];
        // we have everything. make the session, message, and add it
        
        MSSession *session = [[MSSession alloc] init];
        
        MSMessage *message = [[MSMessage alloc] initWithSession:session];
        message.layout = messageLayout;
        message.URL = url;
        message.summaryText = @"Help choose the best option";
        [self.activeConversation insertMessage:message completionHandler:nil];
        
        return nil;
    }, nil);
    
    [_choicesCollectionView updateCellWithActivityIndicators:YES];
    [[STKSServerManager sharedInstance] uploadRawImages:[STKSStackManager sharedInstance].images promise:promise];
}

- (void)createResponseForExistingConversation {
    
    if(self.presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
    }
    
    MSMessageTemplateLayout *messageLayout = [[MSMessageTemplateLayout alloc] init];
    messageLayout.subcaption = [NSString stringWithFormat:@"$%@ rated your image Stack!", self.activeConversation.localParticipantIdentifier];
    messageLayout.image = [STKSStackManager sharedInstance].responseImage;
    
    NSLog(@"WHAT WE ARE PASSING IT %@ %@", [STKSStackManager sharedInstance].imageKeys, [STKSStackManager sharedInstance].imageRatings);
    NSURL *url = [STKSUtilities URLFromImageNames:[STKSStackManager sharedInstance].imageKeys andRatings:[STKSStackManager sharedInstance].imageRatings];
    
    NSLog(@"URL is: %@", url);
    
    MSMessage *message = [[MSMessage alloc] initWithSession:self.activeConversation.selectedMessage.session];
    message.layout = messageLayout;
    message.URL = url;
    message.summaryText = @"Rated images and responded";
    [self.activeConversation insertMessage:message completionHandler:nil];
}

- (void)sendPressed:(UIButton *)sender {
    
    if(sender.tag == kMessageCreation) {
        [self createNewMessageFromImageStack];
    } else if(sender.tag == kResponseCreation) {
        [self createResponseForExistingConversation];
    }
}

#pragma mark - STKSRateSelectionDelegate

- (void)imageHasBeenRated {
    _createMessageButton.enabled = YES;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    
}

#pragma mark - MSMessagesAppViewController Delegate Methods

- (void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    [[STKSStackManager sharedInstance] removeAllImages];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _clickAddLabel.alpha = 1;
        }];
    });
    
    _createMessageButton.enabled = NO;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    [_createMessageButton setTitle:@"Stack Sent! Select New Images" forState:UIControlStateDisabled];
    [_createMessageButton setTitle:@"Create Message Stack" forState:UIControlStateNormal];
}

- (void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
}

- (void)didResignActiveWithConversation:(MSConversation *)conversation {
    
    [[STKSStackManager sharedInstance] removeAllImages];
}

- (void)willBecomeActiveWithConversation:(MSConversation *)conversation {
    
    MSMessage *message = conversation.selectedMessage;
    
    if(message) {
        
        if (message.URL) {
            [self didSelectMessage:message conversation:conversation];
            [self willTransitionToPresentationStyle:MSMessagesAppPresentationStyleExpanded];
        }
    }
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
            [_cameraViewController.view removeFromSuperview];
            _cameraViewController = nil;
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
            
            _cameraViewController = [[STKSCameraViewController alloc] init];
            _cameraViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:_cameraViewController.view];
            [_cameraViewController didMoveToParentViewController:self];
            
            __weak typeof(self) weakSelf = self;
            _cameraViewController.imageCaptured = ^(UIImage *image) {
                [weakSelf handleNewImageSelected:image];
            };
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_choicesCollectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
            
            for(NSLayoutConstraint *constraint in self.view.constraints) {
                
                if((constraint.firstItem == _choicesCollectionView) && (constraint.firstAttribute == NSLayoutAttributeBottom)) {
                    
                    [self.view removeConstraint:constraint];
                    
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_choicesCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cameraViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cameraImageButton attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_choicesCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:90]];
                }
                
                [self.view updateConstraints];
                [super updateViewConstraints];
            }
        }
        
        if(_presentingSelectionView) {
            
            [_createMessageButton setTitle:@"Rate the Images To Continue" forState:UIControlStateDisabled];
            [_createMessageButton setTitle:@"Send Response" forState:UIControlStateNormal];
            _createMessageButton.tag = kResponseCreation;
            
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
        
        _presentingSelectionView = YES;
        
        _selectionCollectionView = [[STKSSelectionCollectionView alloc] init];
        _selectionCollectionView.backgroundColor = [UIColor whiteColor];
        _selectionCollectionView.layer.cornerRadius = 10;
        _selectionCollectionView.layer.masksToBounds = YES;
        _selectionCollectionView.scrollEnabled = YES;
        _selectionCollectionView.selectionDelegate = self;
        _selectionCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _selectionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_selectionCollectionView];
        
        [_selectionCollectionView updateWithImageKeys:[STKSUtilities imageNamesFromURL:message.URL] andRatings:[STKSUtilities ratingsFromURL:message.URL]];
    }
}

#pragma mark - PicChoose Image Selection

- (void)cameraImageButtonTapped:(UIButton *)button {
    _presentingCameraView = YES;
    [_createMessageButton setTitle:@"Select New Images" forState:UIControlStateDisabled];
    [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
}

- (void)libraryImageButtonTapped:(UIButton *)button {
    [_createMessageButton setTitle:@"Select New Images" forState:UIControlStateDisabled];
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

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    
    UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
    [feedbackGenerator prepare];
    
    if(picker.selectedAssets.count < 5) {
        [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
        feedbackGenerator = nil;
        return YES;
    }
    
    [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeError];
    feedbackGenerator = nil;
    
    return NO;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    _createMessageButton.enabled = YES;
    _createMessageButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHImageManager *manager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset targetSize:CGSizeMake(1000, 1000) contentMode:PHImageContentModeDefault options:options resultHandler:^void(UIImage *image, NSDictionary *info) {
            [self handleNewImageSelected:image];
        }];
    }
}

@end
