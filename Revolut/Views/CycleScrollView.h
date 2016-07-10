//
//  CycleScrollView.h
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CycleScrollView;

@protocol CycleScrollViewDataSource <NSObject>

@required
- (NSArray *)numberOfCurrencyView:(CycleScrollView *)bannerView;
@end

@protocol CycleScrollViewDelegate <NSObject>

@optional
- (void)cycleBannerView:(CycleScrollView *)bannerView didScrollToIndex:(NSUInteger)index;
- (void)cycleBannerView:(CycleScrollView *)bannerView didSelectedAtIndex:(NSUInteger)index;
@end

@interface CycleScrollView : UIView

// Delegate and Datasource
@property (weak, nonatomic) IBOutlet id<CycleScrollViewDataSource> datasource;
@property (weak, nonatomic) IBOutlet id<CycleScrollViewDelegate> delegate;

@end
