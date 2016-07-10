//
//  ViewController.h
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CycleScrollView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet CycleScrollView *cycleViewTop;
@property (weak, nonatomic) IBOutlet CycleScrollView *cycleViewBottom;

@end

