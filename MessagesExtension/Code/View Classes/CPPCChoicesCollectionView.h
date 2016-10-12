//
//  PicChooseImageSelectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCChoicesCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *imageAssets;

- (void)updateViewWithImage:(UIImage *)image;

- (void)updateViewWithImageAtPath:(NSString *)filePath;

@end
