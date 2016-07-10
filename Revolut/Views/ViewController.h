//
//  ViewController.h
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CycleScrollView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet CycleScrollView *cycleViewTop;
@property (weak, nonatomic) IBOutlet CycleScrollView *cycleViewBottom;

@property (weak, nonatomic) IBOutlet UILabel *currencyStatsLabel;

@end

