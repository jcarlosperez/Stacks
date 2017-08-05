//
//  STKSSelectionCollectionView.h
//  Stacks
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STKSRatingDelegate;

@interface STKSSelectionCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

//@property (nonatomic, strong) NSArray *choiceImageKeys;

@property (nonatomic, assign) NSObject<STKSRatingDelegate> *selectionDelegate;

- (void)updateWithImageKeys:(NSArray *)keys andRatings:(NSDictionary *)ratings;

@end

@protocol STKSRatingDelegate

- (void)imageHasBeenRated;

@end
