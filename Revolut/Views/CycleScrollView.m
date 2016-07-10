//
//  CycleScrollView.m
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "CycleScrollView.h"
#import "CurrencyView.h"

@interface CycleScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *datasourceViews;
@property (assign, nonatomic) NSUInteger currentSelectedPage;

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
    
    [self loadData];
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

- (void)loadData {
    NSAssert(_datasource != nil, @"datasource must not nil");
    self.datasourceViews = [_datasource numberOfCurrencyView:self];
    
    _pageControl.numberOfPages = self.datasourceViews.count;
    _pageControl.currentPage = 0;
    
    NSMutableArray *cycleDatasource = [self.datasourceViews mutableCopy];
    [cycleDatasource insertObject:[self.datasourceViews lastObject] atIndex:0];
    [cycleDatasource addObject:[self.datasourceViews firstObject]];
    self.datasourceViews = [cycleDatasource copy];
    
    CGFloat contentWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat contentHeight = CGRectGetHeight(_scrollView.frame);
    
    _scrollView.contentSize = CGSizeMake(contentWidth * self.datasourceViews.count, contentHeight);
    
    for (NSInteger i = 0; i < self.datasourceViews.count; i++) {
        CGRect imgRect = CGRectMake(contentWidth * i, 0, contentWidth, contentHeight);
        CurrencyView *imageView = [[CurrencyView alloc] initWithFrame:imgRect];
        
        [_scrollView addSubview:imageView];
    }
    
    if (self.datasourceViews.count > 1) {
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    }
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
    
    _pageControl.currentPage = page;
}

@end
