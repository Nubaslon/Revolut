//
//  CycleScrollView.m
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "CycleScrollView.h"

@interface CycleScrollView () <UIScrollViewDelegate, CurrencyViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *datasourceCurrencies;

@end

@implementation CycleScrollView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self initialize];
}

- (void)initialize {
    self.clipsToBounds = YES;
    
    [self initializeScrollView];
    [self initializePageControl];
    
    [self priv_loadData];
}

- (void)initializeScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = self.autoresizingMask;
    self.scrollView.scrollsToTop = NO;
    [self addSubview:self.scrollView];
}

- (void)initializePageControl {
    CGRect pageControlFrame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), 30);
    self.pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    self.pageControl.center = CGPointMake(CGRectGetWidth(self.scrollView.frame)*0.5, CGRectGetHeight(self.scrollView.frame) - 12.);
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
}

- (void)priv_loadData {
    self.datasourceViews = [NSMutableArray new];
    NSAssert(_datasource != nil, @"datasource must not nil");
    self.datasourceCurrencies = [_datasource numberOfCurrencyView:self];
    
    _pageControl.numberOfPages = self.datasourceCurrencies.count;
    _pageControl.currentPage = 0;
    
    NSMutableArray *cycleDatasource = [self.datasourceCurrencies mutableCopy];
    [cycleDatasource insertObject:[self.datasourceCurrencies lastObject] atIndex:0];
    [cycleDatasource addObject:[self.datasourceCurrencies firstObject]];
    self.datasourceCurrencies = [cycleDatasource copy];
    
    CGFloat contentWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat contentHeight = CGRectGetHeight(_scrollView.frame);
    
    _scrollView.contentSize = CGSizeMake(contentWidth * self.datasourceCurrencies.count, contentHeight);
    
    for (NSInteger i = 0; i < self.datasourceCurrencies.count; i++) {
        CGRect imgRect = CGRectMake(contentWidth * i, 0, contentWidth, contentHeight);
        CurrencyView *currencyView = [[CurrencyView alloc] initWithFrame:imgRect];
        currencyView.delegate = self;
        switch (i) {
            case 1:
                currencyView.currencyName.text = @"EUR";
                break;
            case 2:
                currencyView.currencyName.text = @"USD";
                break;
            case 3:
                currencyView.currencyName.text = @"GBP";
                break;
            default:
                break;
        }
        [self.datasourceViews addObject:currencyView];
        [_scrollView addSubview:currencyView];
    }
    [self loadDataToViews];
    
    if (self.datasourceCurrencies.count > 1) {
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    }
}

- (void)loadDataToViews {
    self.datasourceCurrencies = [_datasource numberOfCurrencyView:self];
    
    NSMutableArray *cycleDatasource = [self.datasourceCurrencies mutableCopy];
    [cycleDatasource insertObject:[self.datasourceCurrencies lastObject] atIndex:0];
    [cycleDatasource addObject:[self.datasourceCurrencies firstObject]];
    self.datasourceCurrencies = [cycleDatasource copy];
    for (NSInteger i = 0; i < self.datasourceCurrencies.count; i++) {
        CurrencyView *currencyView = [self.datasourceViews objectAtIndex:i];
        NSDecimalNumber *currency = [self.datasourceCurrencies objectAtIndex:i];
        currencyView.currencySum.text = [NSString stringWithFormat:@"You have %.2f", currency.floatValue];
    }
}

- (void)moveToTargetPosition:(CGFloat)targetX withAnimated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSInteger page = MIN(self.datasourceViews.count - 1, MAX(0, currentPage));
    
    [self setSwitchPage:page animated:animated withUserInterface:YES];
}

- (void)setSwitchPage:(NSInteger)switchPage animated:(BOOL)animated withUserInterface:(BOOL)userInterface {
    
    NSInteger page = -1;
    
    if (userInterface) {
        page = switchPage;
    }else {
        _currentSelectedPage++;
        page = _currentSelectedPage % (self.datasourceViews.count - 1);
    }
    
    if (self.datasourceViews.count > 1) {
        if (page >= (self.datasourceViews.count -2)) {
            page = self.datasourceViews.count - 3;
            _currentSelectedPage = 0;
            [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * (page + 2) withAnimated:animated];
        }else {
            [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * (page + 1) withAnimated:animated];
        }
    }else {
        [self moveToTargetPosition:0 withAnimated:animated];
    }
    
    [self scrollViewDidScroll:_scrollView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat targetX = scrollView.contentOffset.x;
    
    CGFloat item_width = CGRectGetWidth(scrollView.frame);
    
    if (self.datasourceViews.count >= 3) {
        if (targetX >= item_width * (self.datasourceViews.count - 1)) {
            targetX = item_width;
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        }else if (targetX <= 0) {
            targetX = item_width * (self.datasourceViews.count - 2);
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        }
    }
    
    NSInteger page = (scrollView.contentOffset.x + item_width * 0.5) / item_width;
    
    if (self.datasourceViews.count > 1) {
        page--;
        if (page >= _pageControl.numberOfPages) {
            page = 0;
        }else if (page < 0) {
            page = _pageControl.numberOfPages - 1;
        }
    }
    
    _currentSelectedPage = page;
    
    if (page != _pageControl.currentPage) {
        if ([self.delegate respondsToSelector:@selector(cycleBannerView:didScrollToIndex:)]) {
            [self.delegate cycleBannerView:self didScrollToIndex:page];
        }
    }
    self.currentView = [self.datasourceViews objectAtIndex:page+1];

    _pageControl.currentPage = page;
}

- (void)сurrencyView:(CurrencyView *)currencyView enteredValue:(NSString *)value {
    if ([self.delegate respondsToSelector:@selector(cycleBannerView:enteredValue:)]) {
        [self.delegate cycleBannerView:self enteredValue:value];
    }
}

@end
