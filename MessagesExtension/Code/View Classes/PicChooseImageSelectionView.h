//
//  PicChooseImageSelectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicChooseImageSelectionView;
@protocol PicChooseImageSelectionViewDelegate <NSObject>
- (void)tappedAddImageCell;

@end

@interface PicChooseImageSelectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *imageAssets;
@property (nonatomic, strong) UICollectionView *imageSelectionCollectionView;

@property (nonatomic, weak) id <PicChooseImageSelectionViewDelegate> delegate;

- (void)updateViewWithImage:(UIImage *)image;
- (void)updateViewWithImageAtPath:(NSString *)filePath;
@end
