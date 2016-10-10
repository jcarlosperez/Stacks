//
//  CPPCMessagesViewController.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCMessagesViewController.h"
#import "PicChooseImageSelectionView.h"
#import "CompactConstraint.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "CPPCServerManager.h"

@interface CPPCMessagesViewController () <CTAssetsPickerControllerDelegate, UITextFieldDelegate> {
    NSString *__fileName;
}
@property (nonatomic, strong ) PicChooseImageSelectionView *choicesCollectionView;
@end

@implementation CPPCMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.957 green:0.965 blue:0.969 alpha:1.00];
    
    UITextField *questionTextField = [[UITextField alloc] init];
    questionTextField.delegate = self;
    questionTextField.text = @"Which Shoes Should I Buy?";
    questionTextField.textAlignment = NSTextAlignmentCenter;
    questionTextField.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
    questionTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:questionTextField];
    
    _choicesCollectionView = [[PicChooseImageSelectionView alloc] init];
    _choicesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_choicesCollectionView];
    
    UIButton *sendButton = [[UIButton alloc] init];
    [sendButton addTarget:self action:@selector(showAlertController:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"Send Image" forState:UIControlStateNormal];
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
                                       @"choicesCollectionView.top = questionTextField.bottom",
                                       @"choicesCollectionView.bottom = sendButton.top",
                                       @"choicesCollectionView.left = view.left+10",
                                       @"choicesCollectionView.right = view.right-10"]
                             metrics:nil
                               views:@{@"questionTextField": questionTextField,
                                       @"view": self.view,
                                       @"topLayoutGuide": self.topLayoutGuide,
                                       @"sendButton": sendButton,
                                       @"choicesCollectionView": _choicesCollectionView}];
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
            [[CPPCServerManager sharedInstance] uploadRawImage:image];
            
        }];
    }
    
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

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
}

@end
