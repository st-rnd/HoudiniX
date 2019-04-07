//
//  ThemesViewController.m
//  houdini
//
//  Created by Conor B on 07/04/2019.
//  Copyright © 2019 cheesecakeufo. All rights reserved.
//

#include "task_ports.h"
#include "triple_fetch_remote_call.h"
#include "apps_control.h"
#include "utilities.h"
#include "display.h"

#include <sys/param.h>
#include <sys/mount.h>
#import <UIKit/UIKit.h>

@interface ThemesViewController: UIViewController
@property (weak, nonatomic) IBOutlet UITableView *themesTableView;
@end

@interface ThemeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *packageIcon;

@property (weak, nonatomic) IBOutlet UILabel *packageTitle;
@property (weak, nonatomic) IBOutlet UILabel *packageSource;

@property (nonatomic, retain) ThemesViewController *mainViewController;

@end

@implementation ThemeCell

@end

@implementation ThemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)respringTapped:(id)sender {
    uicache();
}
- (IBAction)dismissPressed:(id)sender {
    [super dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ThemeCell *cell = (ThemeCell *)[tableView dequeueReusableCellWithIdentifier:@"ThemeCell"];
    
    [cell.packageTitle setText:@"Original"];
    [cell.packageSource setText:@"by Apple"];
    
    cell.mainViewController = self;
    
    return cell;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    ThemeCell *cell = (ThemeCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Change Theme?"
                                 message:[cell.textLabel.text stringByAppendingString:@" will be used as your theme"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    
    UIAlertAction* confirmButton = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    
    [alert addAction:cancelButton];
    [alert addAction:confirmButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
