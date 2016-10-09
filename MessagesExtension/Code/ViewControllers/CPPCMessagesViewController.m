//
//  CPPCMessagesViewController.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCMessagesViewController.h"
#import "PicChooseImageSelectionView.h"

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface CPPCMessagesViewController () <CTAssetsPickerControllerDelegate> {
    NSString *__fileName;
}
@property (nonatomic, strong ) PicChooseImageSelectionView *imageSelectionView;
@end

@implementation CPPCMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTemporaryFolders];
    [self setupAWSCognito];
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    questionLabel.text = @"Which Shoes Should I Buy?";
    questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:questionLabel];
    
    _imageSelectionView = [[PicChooseImageSelectionView alloc] initWithFrame:CGRectZero];
    _imageSelectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageSelectionView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(showAlertController:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Send Image" forState:UIControlStateNormal];
    [button.titleLabel setTextColor:[UIColor blackColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:questionLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:10]];
    
}

- (void)createNewMessageWithImage:(UIImage *)image andURL:(NSURL *)url {
    
    MSConversation *currentConversation = self.activeConversation;
    
    // Create the message layout
    MSMessageTemplateLayout *messageLayout = [[MSMessageTemplateLayout alloc] init];
    messageLayout.subcaption = [NSString stringWithFormat:@"%@ needs your help choosing.", currentConversation.localParticipantIdentifier];
    messageLayout.image = image;
    
    // Create a message setting its layout and url
    MSMessage *message = [[MSMessage alloc] init];
    message.layout = messageLayout;
    message.URL = url;
    [currentConversation insertMessage:message completionHandler:nil];
    
    // If extension is expanded animate to compact style so user can see message
    if(self.presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
    }
    
}

- (void)createTemporaryFolders {
    
    // Create temp folder to store images user selects
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
}

- (void)setupAWSCognito {
    
    // Setup Cognito credentials for user pool to use without authorization
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"***REMOVED***" unauthRoleArn:@"***REMOVED***" authRoleArn:nil  identityProviderManager:nil];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

#pragma mark - User Alert Controller

- (void)showAlertController:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Available Actions"
                                                                             message:@"Choose your action."
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak CPPCMessagesViewController *weakSelf = self;
    UIAlertAction *selectPictureAction = [UIAlertAction actionWithTitle:@"Select Pictures"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    
                                                                    CPPCMessagesViewController *strongSelf = weakSelf;
                                                                    [strongSelf selectPicturesFromLibrary];
                                                                    
                                                                }];
    [alertController addAction:selectPictureAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectPicturesFromLibrary {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    
    NSLog(@"assetsPickerController:didFinishPickingAssets:");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for(PHAsset *asset in assets) {
        
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^void(UIImage *image, NSDictionary *info) {
            
            NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpg"];
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
            
            __fileName = fileName;
            
            // Calculate scaled height
            CGFloat height = image.size.height / (image.size.width/800);
            UIImage *scaledImaged = [self scaleDown:image withSize:CGSizeMake(800, height)];
            NSData * imageData = UIImageJPEGRepresentation(scaledImaged, 0.6);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
                if(!error) {
                    
                    // Really I shouldn't upload now, only until user taps on send which creates the MSMessage
                    [self createUploadWithImageAtPath:filePath withFilename:fileName];
                    [_imageSelectionView updateViewWithImageAtPath:filePath];
                }
            });
        }];
    }
    
}

-(UIImage*)scaleDown:(UIImage*)img withSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)createUploadWithImageAtPath:(NSString *)path withFilename:(NSString *)fileName {
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = [NSURL fileURLWithPath:path];
    uploadRequest.key = fileName;
    uploadRequest.bucket = @"picchoosebackend";
    [self transferUploadWithRequest:uploadRequest];
    
}

- (void)transferDownloadWithRequest:(AWSS3TransferManagerDownloadRequest *)request {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager download:request] continueWithBlock:^id(AWSTask *task) {
        
        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
            && task.error.code == AWSS3TransferManagerErrorPaused) {
            NSLog(@"Download paused.");
        } else if (task.error) {
            NSLog(@"Download failed: [%@]", task.error);
        } else {
            NSLog(@"Task: %@", task);
            NSURL *downloadedFilePath = ((AWSS3TransferManagerDownloadOutput *)task.result).body;
            NSLog(@"Download File Path: %@", downloadedFilePath);
        }
        
        return nil;
    }];
    
}

- (void)transferUploadWithRequest:(AWSS3TransferManagerUploadRequest *)request {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //__weak CPPCMessagesViewController *weakSelf = self;
    
    [[transferManager upload:request] continueWithBlock:^id(AWSTask *task) {
        
        if (task.result) {
            NSLog(@"Task Result: %@", task.result);
            
            // The key is just the filename as we set in the upload request. Hardcoded here for now
            /*NSString *fileKey = @"02DD0010-B9B8-457C-A4E5-98C77A720673-2171-0000015CF046E756.jpg";
            
            NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:fileKey];
            NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
            
            AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
            downloadRequest.bucket = @"picchoosebackend";
            downloadRequest.key = @"02DD0010-B9B8-457C-A4E5-98C77A720673-2171-0000015CF046E756.jpg";
            downloadRequest.downloadingFileURL = downloadingFileURL;
            [self transferDownloadWithRequest:downloadRequest];*/
            
        } else if(task.error) {
            NSLog(@"Task Result: %@", task.error);
        }
        
        return nil;
    }];
}

#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
}

@end
