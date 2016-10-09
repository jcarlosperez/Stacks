//
//  CPPCMessagesViewController.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCMessagesViewController.h"

#import <AWSS3/AWSS3.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface CPPCMessagesViewController () <CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *uploadImagePaths;
@end

@implementation CPPCMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTemporaryUploadsFolder];
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    questionLabel.text = @"Which Shoes Should I Buy?";
    questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:questionLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(showAlertController:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show Alert" forState:UIControlStateNormal];
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
    
}

- (void)createTemporaryUploadsFolder {
    
    NSLog(@"Attempting to create folder with path: %@", [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]);
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"reating 'upload' directory failed: [%@]", error);
    }
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
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
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
    _uploadImagePaths = [NSMutableArray new];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for(PHAsset *asset in assets) {
        
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^void(UIImage *image, NSDictionary *info) {
            
            NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".png"];
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
            NSData * imageData = UIImagePNGRepresentation(image);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
                NSLog(@"Error: %@", error);
            });
            
            [self createUploadWithImageAtPath:filePath withFilename:fileName];
            
        }];
    }
    
}

- (void)createUploadWithImageAtPath:(NSString *)path withFilename:(NSString *)fileName {
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = [NSURL fileURLWithPath:path];
    uploadRequest.key = fileName;
    uploadRequest.bucket = @"picchoosebackend";
    [self transferUploadWithRequest:uploadRequest];
    
}

- (void)transferUploadWithRequest:(AWSS3TransferManagerUploadRequest *)request {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //__weak CPPCMessagesViewController *weakSelf = self;
    
    [[transferManager upload:request] continueWithBlock:^id(AWSTask *task) {
        
        if (task.result) {
            NSLog(@"Task Result: %@", task.result);
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
