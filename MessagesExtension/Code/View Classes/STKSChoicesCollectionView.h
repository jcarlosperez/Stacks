//
//  StacksImageSelectionView.h
//  Stacks
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKSChoicesCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (void)updateCellWithActivityIndicators:(BOOL)indicators;
@end
