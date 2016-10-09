//
//  PicChooseImageSelectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicChooseImageSelectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *imageSelectionCollectionView;
- (void)updateViewWithImageAtPath:(NSString *)filePath;
@end
