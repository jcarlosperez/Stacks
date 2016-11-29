//
//  PicChooseImageSelectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCChoicesCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (void)updateCellWithActivityIndicators:(BOOL)indicators;
@end
