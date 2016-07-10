//
//  CurrencyView.m
//  Revolut
//
//  Created by Samoilov Denis on 10.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "CurrencyView.h"

@interface CurrencyView () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *view;

@end

@implementation CurrencyView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize {
    [[NSBundle mainBundle] loadNibNamed:@"CurrencyView" owner:self options:nil];
    [self addSubview:self.view];
    
    self.valueTextField.delegate = self;
    [self.valueTextField addTarget:self
                  action:@selector(textFieldDidChange)
                  forControlEvents:UIControlEventEditingChanged];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)textFieldDidChange {
    if ([self.delegate respondsToSelector:@selector(сurrencyView:enteredValue:)]) {
        [self.delegate сurrencyView:self enteredValue:self.valueTextField.text];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newStr = [NSString stringWithFormat:@"-%@", [self.valueTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    self.valueTextField.text = newStr;
    
    return YES;
}

@end
