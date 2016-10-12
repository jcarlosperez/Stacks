//
//  CPPCMessagesViewController.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCMessagesViewController.h"
#import "CPPCChoicesCollectionView.h"
#import "CompactConstraint.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "CPPCServerManager.h"
#import "UIImage+Optimizations.h"
#import "RXPromise.h"
#import "CPPCUtilities.h"

@interface CPPCMessagesViewController () <CTAssetsPickerControllerDelegate, CPPCChoicesCollectionViewDelegate>

@property (nonatomic, strong) CPPCChoicesCollectionView *choicesCollectionView;

@property (nonnull, strong) UITextField *questionTextField;

@end

@implementation CPPCMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.957 green:0.965 blue:0.969 alpha:1.00];
    
    _questionTextField = [[UITextField alloc] init];
    _questionTextField.placeholder = @"Which Shoes Should I Buy?";
    _questionTextField.textAlignment = NSTextAlignmentCenter;
    _questionTextField.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
    _questionTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_questionTextField];
    
    _choicesCollectionView = [[CPPCChoicesCollectionView alloc] init];
    _choicesCollectionView.choicesDelegate = self;
    _choicesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_choicesCollectionView];
    
    UIButton *sendButton = [[UIButton alloc] init];
    [sendButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"Create Message" forState:UIControlStateNormal];
    [sendButton.titleLabel setTextColor:[UIColor blackColor]];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sendButton];
    
    [self.view addCompactConstraints:@[@"questionTextField.centerX = view.centerX",
                                       @"questionTextField.top = topLayoutGuide.bottom+10",
                                       @"questionTextField.left = view.left+20",
                                       @"questionTextField.right = view.right-20",
                                       @"sendButton.bottom = view.bottom-50",
                                       @"sendButton.centerX = view.centerX",
                                       @"sendButton.height = 50",
                                       @"sendButton.width = 200",
                                       @"choicesCollectionView.top = questionTextField.bottom+15",
                                       @"choicesCollectionView.bottom = sendButton.top",
                                       @"choicesCollectionView.left = view.left+10",
                                       @"choicesCollectionView.right = view.right-10"]
                             metrics:nil
                               views:@{@"questionTextField": _questionTextField,
                                       @"view": self.view,
                                       @"topLayoutGuide": self.topLayoutGuide,
                                       @"sendButton": sendButton,
                                       @"choicesCollectionView": _choicesCollectionView}];
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
                NSURL *url = [CPPCUtilities URLFromQuestion:_questionTextField.text imageNames:allUploadedImageNames];
                
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

#pragma mark - PicChoose Image Selection

- (void)addImageCellTapped {
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHImageManager *manager = [PHImageManager defaultManager];
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^void(UIImage *image, NSDictionary *info) {
            [_choicesCollectionView updateViewWithImage:image];
        }];
    }
}

@end
