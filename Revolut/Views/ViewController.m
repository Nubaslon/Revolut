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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self priv_loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)priv_refreshInterfaceWithData:(NSDictionary *)dictionary {
    
}

- (void)priv_loadData {
    __weak typeof(self) weakSelf = self;
    [[NetworkOperation sharedOperation] requestCurrencysStatsOnSuccess:^(id result) {
        NSLog(@"Result - %@", result);
        [weakSelf priv_refreshInterfaceWithData:result];
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

- (NSArray *)numberOfCurrencyView:(CycleScrollView *)bannerView {
    
    return @[@"1",
             @"2",
             @"3"];
}

#pragma mark - CycleScrollViewDelegate

- (void)cycleBannerView:(CycleScrollView *)bannerView didScrollToIndex:(NSUInteger)index {
    NSLog(@"didScrollToIndex:%ld", (long)index);
}

- (void)cycleBannerView:(CycleScrollView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    NSLog(@"didSelectedAtIndex:%ld", (long)index);
}
@end
