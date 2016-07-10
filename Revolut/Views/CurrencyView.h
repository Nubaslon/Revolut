//
//  CurrencyView.h
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CurrencyView;

@protocol CurrencyViewDelegate <NSObject>

@optional
- (void)сurrencyView:(CurrencyView *)currencyView enteredValue:(NSString *)value;
@end

@interface CurrencyView : UIView

@property (weak, nonatomic) IBOutlet id<CurrencyViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *currencySum;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;

@end
