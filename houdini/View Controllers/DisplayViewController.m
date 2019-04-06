//
//  DisplayViewController.m
//  Houdini
//
//  Created by Abraham Masri on 11/22/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//




#include "utilities.h"
#include "display.h"
#include "apps_control.h"

@interface DisplayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *iPhoneSegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation DisplayViewController

int width = 750;
int height = 1334;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Warning"
                                 message:@"HoudiniX does NOT recommend changing your screen resolution unless you know what you are doing, by changing your screen resolution you accept that we have no responsibility over what happens to your device."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* quitButton = [UIAlertAction actionWithTitle:@"OK, I understand" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [alert dismissViewControllerAnimated:true completion:nil];
        
    }];
    
    [alert addAction:quitButton];
}

- (IBAction)iPhoneSegmentChanged:(id)sender {
    
    if (self.iPhoneSegmentControl.selectedSegmentIndex == 0) { // 8
        width = 750;
        height = 1334;
    } else if (self.iPhoneSegmentControl.selectedSegmentIndex == 1) { // 8 Plus
        width = 827;
        height = 1472;
    }

    [self.resolutionLabel setText:[NSString stringWithFormat:@"%dx%d", width, height]];
}

- (IBAction)rebootTapped:(id)sender {
    
    change_resolution(width, height);
    
    printf("[INFO]: finished changing the resolution. rebooting..\n");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        chosen_strategy.strategy_reboot();
    });
}

- (IBAction)dismissTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
