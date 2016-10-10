//
//  PicChooseImageSelectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPCChoicesCollectionViewDelegate <NSObject>

- (void)addImageCellTapped;

@end

@interface CPPCChoicesCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *imageAssets;

@property (nonatomic, weak) id <CPPCChoicesCollectionViewDelegate> choicesDelegate;

- (void)updateViewWithImage:(UIImage *)image;
- (void)updateViewWithImageAtPath:(NSString *)filePath;

@end
