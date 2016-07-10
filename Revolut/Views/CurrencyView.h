//
//  CurrencyView.h
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyView : UIView

@property (weak, nonatomic) IBOutlet UILabel *currencySum;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;

@end
