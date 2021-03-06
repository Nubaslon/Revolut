//
//  ViewController.m
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "ViewController.h"

#import "NetworkOperation.h"
#import "CurrencyView.h"

@interface ViewController ()

@property(nonatomic, retain) NSDecimalNumber *countGPB;
@property(nonatomic, retain) NSDecimalNumber *countEUR;
@property(nonatomic, retain) NSDecimalNumber *countUSD;
@property (strong, nonatomic) NSMutableArray *currenciesStats;
@property (weak, nonatomic) IBOutlet UIButton *exchangeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.currenciesStats = [NSMutableArray new];
    [self.exchangeButton addTarget:self action:@selector(priv_exchange) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.currencyStatsLabel.text = [NSString stringWithFormat:@"1 EUR = %.4f %@", [[[self.currenciesStats objectAtIndex:0] objectForKey:@"_rate"] floatValue], [[self.currenciesStats objectAtIndex:0] objectForKey:@"_currency"]];
    [self.cycleViewTop loadDataToViews];
    [self.cycleViewBottom loadDataToViews];
    [self.cycleViewBottom setCurrentPage:1 animated:NO];
}

- (void)priv_loadData {
    __weak typeof(self) weakSelf = self;
    [[NetworkOperation sharedOperation] requestCurrencysStatsOnSuccess:^(id result) {
        NSLog(@"Result - %@", result);
        [weakSelf.currenciesStats removeAllObjects];
        [weakSelf.currenciesStats addObject:[result objectAtIndex:0]];
        [weakSelf.currenciesStats addObject:[result objectAtIndex:5]];
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

- (void)priv_exchange {
    float currencyValue = [[self.cycleViewTop.currentView.valueTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""] floatValue];
    if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 1) {
        //EUR -> USD
        if (currencyValue < [self.countEUR floatValue]) {
            self.countEUR = [[NSDecimalNumber alloc] initWithFloat:(self.countEUR.floatValue - currencyValue)];
            self.countUSD = [[NSDecimalNumber alloc] initWithFloat:(self.countUSD.floatValue + [self.cycleViewBottom.currentView.valueTextField.text floatValue])];
        } else {
            [self priv_showAlertView:@"Insufficient funds in the EUR"];
        }
    } else if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 2) {
        //EUR -> GPB
        if (currencyValue < [self.countEUR floatValue]) {
            self.countEUR = [[NSDecimalNumber alloc] initWithFloat:(self.countEUR.floatValue - currencyValue)];
            self.countGPB = [[NSDecimalNumber alloc] initWithFloat:(self.countGPB.floatValue + [self.cycleViewBottom.currentView.valueTextField.text floatValue])];
        } else {
            [self priv_showAlertView:@"Insufficient funds in the EUR"];
        }
    } else if (self.cycleViewTop.currentSelectedPage == 1 && self.cycleViewBottom.currentSelectedPage == 0) {
        //USD -> EUR
        if (currencyValue < [self.countUSD floatValue]) {
            self.countUSD = [[NSDecimalNumber alloc] initWithFloat:(self.countUSD.floatValue - currencyValue)];
            self.countEUR = [[NSDecimalNumber alloc] initWithFloat:(self.countEUR.floatValue + [self.cycleViewBottom.currentView.valueTextField.text floatValue])];
        } else {
            [self priv_showAlertView:@"Insufficient funds in the USD"];
        }
    } else if (self.cycleViewTop.currentSelectedPage == 2 && self.cycleViewBottom.currentSelectedPage == 0) {
        //GPB -> EUR
        if (currencyValue < [self.countGPB floatValue]) {
            self.countGPB = [[NSDecimalNumber alloc] initWithFloat:(self.countGPB.floatValue - currencyValue)];
            self.countEUR = [[NSDecimalNumber alloc] initWithFloat:(self.countEUR.floatValue + [self.cycleViewBottom.currentView.valueTextField.text floatValue])];
        } else {
            [self priv_showAlertView:@"Insufficient funds in the GPB"];
        }
    }
    [self priv_refreshInterfaceWithData];
}

- (void)priv_showAlertView:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Attention:" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CycleScrollViewDataSource

- (NSMutableArray *)currensiesStats:(CycleScrollView *)bannerView {
    return self.currenciesStats;
}

- (NSArray *)numberOfCurrencyView:(CycleScrollView *)bannerView {
    
    return @[self.countEUR,
             self.countUSD,
             self.countGPB];
}

#pragma mark - CycleScrollViewDelegate

- (void)cycleBannerView:(CycleScrollView *)bannerView didScrollToIndex:(NSUInteger)index {
    NSLog(@"currentPage:%ld", (long)index);
    if (self.cycleViewTop.currentSelectedPage == self.cycleViewBottom.currentSelectedPage) {
        self.currencyStatsLabel.hidden = YES;
    } else {
        self.currencyStatsLabel.hidden = NO;
        if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 1) {
            //EUR -> USD
            self.currencyStatsLabel.text = [NSString stringWithFormat:@"1 EUR = %.4f %@", [[[self.currenciesStats objectAtIndex:0] objectForKey:@"_rate"] floatValue], [[self.currenciesStats objectAtIndex:0] objectForKey:@"_currency"]];
        } else if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 2) {
            //EUR -> GPB
            self.currencyStatsLabel.text = [NSString stringWithFormat:@"1 EUR = %.4f %@", [[[self.currenciesStats objectAtIndex:1] objectForKey:@"_rate"] floatValue], [[self.currenciesStats objectAtIndex:1] objectForKey:@"_currency"]];
        } else if (self.cycleViewTop.currentSelectedPage == 1 && self.cycleViewBottom.currentSelectedPage == 0) {
            //USD -> EUR
            self.currencyStatsLabel.text = [NSString stringWithFormat:@"1 EUR = %.4f %@", [[[self.currenciesStats objectAtIndex:0] objectForKey:@"_rate"] floatValue], [[self.currenciesStats objectAtIndex:0] objectForKey:@"_currency"]];
        } else if (self.cycleViewTop.currentSelectedPage == 2 && self.cycleViewBottom.currentSelectedPage == 0) {
            //GPB -> EUR
            self.currencyStatsLabel.text = [NSString stringWithFormat:@"1 EUR = %.4f %@", [[[self.currenciesStats objectAtIndex:1] objectForKey:@"_rate"] floatValue], [[self.currenciesStats objectAtIndex:1] objectForKey:@"_currency"]];
        }
    }
}

- (void)cycleBannerView:(CycleScrollView *)bannerView enteredValue:(NSString *)value {
    NSLog(@"current value 2: %@", value);
    NSString *newStr = [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 1) {
        //EUR -> USD
        self.cycleViewBottom.currentView.valueTextField.text = [NSString stringWithFormat:@"+%.2f", [newStr floatValue] / [[[self.currenciesStats objectAtIndex:0] objectForKey:@"_rate"] floatValue]];
    } else if (self.cycleViewTop.currentSelectedPage == 0 && self.cycleViewBottom.currentSelectedPage == 2) {
        //EUR -> GPB
        self.cycleViewBottom.currentView.valueTextField.text = [NSString stringWithFormat:@"+%.2f", [newStr floatValue] * [[[self.currenciesStats objectAtIndex:1] objectForKey:@"_rate"] floatValue]];
    } else if (self.cycleViewTop.currentSelectedPage == 1 && self.cycleViewBottom.currentSelectedPage == 0) {
        //USD -> EUR
        self.cycleViewBottom.currentView.valueTextField.text = [NSString stringWithFormat:@"+%.2f", [newStr floatValue] * [[[self.currenciesStats objectAtIndex:0] objectForKey:@"_rate"] floatValue]];
    } else if (self.cycleViewTop.currentSelectedPage == 2 && self.cycleViewBottom.currentSelectedPage == 0) {
        //GPB -> EUR
        self.cycleViewBottom.currentView.valueTextField.text = [NSString stringWithFormat:@"+%.2f", [newStr floatValue] / [[[self.currenciesStats objectAtIndex:1] objectForKey:@"_rate"] floatValue]];
    }
}

@end
