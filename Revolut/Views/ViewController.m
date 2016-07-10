//
//  ViewController.m
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "ViewController.h"

#import "NetworkOperation.h"

@interface ViewController ()

@property(nonatomic, retain) NSDecimalNumber *countGPB;
@property(nonatomic, retain) NSDecimalNumber *countEUR;
@property(nonatomic, retain) NSDecimalNumber *countUSD;
@property (strong, nonatomic) NSMutableArray *currenciesStats;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.currenciesStats = [NSMutableArray new];
    
    [self priv_loadData];
    [self priv_initCurrencies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)priv_initCurrencies {
    self.countUSD = [[NSDecimalNumber alloc] initWithFloat:100.0];
    self.countEUR = [[NSDecimalNumber alloc] initWithFloat:100.0];
    self.countGPB = [[NSDecimalNumber alloc] initWithFloat:100.0];
}

- (void)priv_refreshInterfaceWithData {
    [self.cycleViewTop loadDataToViews];
    [self.cycleViewBottom loadDataToViews];
    [self.cycleViewBottom setCurrentPage:1 animated:NO];
}

- (void)priv_loadData {
    __weak typeof(self) weakSelf = self;
    [[NetworkOperation sharedOperation] requestCurrencysStatsOnSuccess:^(id result) {
        NSLog(@"Result - %@", result);
        [weakSelf.currenciesStats removeAllObjects];
        [weakSelf.currenciesStats addObject:[[result objectAtIndex:0] objectForKey:@"_rate"]];
        [weakSelf.currenciesStats addObject:[[result objectAtIndex:5] objectForKey:@"_rate"]];
        [weakSelf priv_refreshInterfaceWithData];
        [weakSelf priv_updateData];
    } onFailure:^(NSError *error) {
        NSLog(@"Error - %@", error);
        [weakSelf priv_updateData];
    }];
}

- (void)priv_updateData {
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(priv_loadData) userInfo:nil repeats:YES];
}

#pragma mark - CycleScrollViewDataSource

- (NSMutableArray *)currensiesStats:(CycleScrollView *)bannerView {
    return self.currenciesStats;
}

- (NSArray *)numberOfCurrencyView:(CycleScrollView *)bannerView {
    
    return @[self.countGPB,
             self.countEUR,
             self.countUSD];
}

#pragma mark - CycleScrollViewDelegate

- (void)cycleBannerView:(CycleScrollView *)bannerView didScrollToIndex:(NSUInteger)index {
    NSLog(@"currentPage:%ld", (long)index);
    if (self.cycleViewTop.currentSelectedPage == self.cycleViewBottom.currentSelectedPage) {
        self.currencyStatsLabel.hidden = YES;
    } else {
        self.currencyStatsLabel.hidden = NO;
    }
}

- (void)cycleBannerView:(CycleScrollView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    NSLog(@"didSelectedAtIndex:%ld", (long)index);
}
@end
