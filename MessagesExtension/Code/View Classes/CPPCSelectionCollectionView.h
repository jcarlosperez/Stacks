//
//  CPPCSelectionCollectionView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCSelectionCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *choiceImageKeys;

@end
