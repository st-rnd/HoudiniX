//
//  JailbreakViewController.m
//  houdini
//
//  Created by Abraham Masri on 11/13/17.
//  Copyright © 2017 Abraham Masri. All rights reserved.
//

#include "utilities.h"
#include "sources_control.h"
#include "strategy_control.h"

typedef NS_ENUM(NSUInteger, PLWallpaperMode) {
    PLWallpaperModeBoth,
    PLWallpaperModeHomeScreen,
    PLWallpaperModeLockScreen
};

@interface PLWallpaperImageViewController : UIViewController // PLUIEditImageViewController

- (instancetype)initWithUIImage:(UIImage *)image;
- (void)_savePhoto;

@property BOOL saveWallpaperData;
@property PLWallpaperMode wallpaperMode;

@end

@interface PLStaticWallpaperImageViewController : PLWallpaperImageViewController

@property (nonatomic) bool colorSamplingEnabled;

- (void)_fetchImageForWallPaperAsset:(id)arg1 resultHandler:(id /* block */)arg2;
- (long long)_preferredWhitePointAdaptivityStyle;
- (id)_wallPaperPreviewControllerForAsset:(id)arg1;
- (id)_wallPaperPreviewControllerForPhotoIrisAsset:(id)arg1;
- (bool)colorSamplingEnabled;
- (id)initWithImage:(id)arg1 name:(id)arg2 video:(id)arg3 time:(double)arg4;
- (id)initWithPhoto:(id)arg1;
- (id)initWithUIImage:(id)arg1;
- (id)initWithUIImage:(id)arg1 name:(id)arg2;
- (void)photoTileViewControllerDidEndGesture:(id)arg1;
- (void)providerLegibilitySettingsChanged:(id)arg1;
- (void)setColorSamplingEnabled:(bool)arg1;
- (void)setWallpaperForLocations:(long long)arg1;
- (void)viewWillAppear:(bool)arg1;
- (id)wallpaperImage;

@end

@interface JailbreakViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property BOOL can_jailbreak;
@end

@implementation JailbreakViewController

// jailbreakd sets this (if running)
mach_port_t passed_priv_port = MACH_PORT_NULL;

- (void)addGradient {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:0.18 green:0.77 blue:0.82 alpha:0.5].CGColor, (id)[UIColor colorWithRed:0.10 green:0.42 blue:0.72 alpha:0.5].CGColor];
    
    [view.layer insertSublayer:gradient atIndex:0];
    [self.view insertSubview:view atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.image.layer.cornerRadius = 15;
    
    [self.versionLabel setText:[[UIDevice currentDevice] systemVersion]];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // set the view background (if we have it)
    NSData *currentWallpaper = get_saved_wallpaper();
    
    if(currentWallpaper != nil) {
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [[UIImage imageWithData:currentWallpaper] drawInRect:self.view.bounds];
        UIImage *wallpaperImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage: wallpaperImage]];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:0];
    } else {
        [self addGradient];
    }
    
    
    // set the strategy
    if(set_exploit_strategy() != KERN_SUCCESS) {
        [self.startButton setEnabled:NO];
        [self.startButton setTitle:@"not supported :(" forState:UIControlStateNormal];
        [self.startButton setBackgroundColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0]];
        self.can_jailbreak = NO;
        return;
    }
    
    NSString *system_version = [[UIDevice currentDevice] systemVersion];
    NSArray *async_wake_versions = @[@"11.0", @"11.0.1", @"11.0.3", @"11.1", @"11.1.2"];
    if ([async_wake_versions containsObject:system_version]) {
        self.can_jailbreak = NO;
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Warning"
                                     message:@"HoudiniX does not support iOS 11 -> 11.1.2 at the moment, we are working on a fix for the exploit used."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* quitButton = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            exit(0);
            
        }];
        
        [alert addAction:quitButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    self.can_jailbreak = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(!self.can_jailbreak)
        return;
    
    boolean_t jangojango_found = false;
    for(NSString *file_name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:NULL]) {
        
        if([file_name containsString:@".dylib"]) {
            
            jangojango_found = true;
            
            break;
        }

    }
    
    if(jangojango_found) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Warning"
                                     message:@"It seems like you are using a modified version of HoudiniX which might be unsafe. Get HoudiniX from houdinix.conorthedev.com!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* quitButton = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            exit(0);
            
        }];
        
        UIAlertAction* confirmButton = [UIAlertAction actionWithTitle:@"Ignore (unsafe)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [self jailbreakTapped:self.startButton];
            
        }];
        
        [alert addAction:quitButton];
        [alert addAction:confirmButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
        
    }
    [self jailbreakTapped:self.startButton];
}


- (void) showAlertViewController {
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AlertViewController"];
    viewController.providesPresentationContextTransitionStyle = YES;
    viewController.definesPresentationContext = YES;
    [viewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)jailbreakTapped:(id)sender {
    
    [sender setTitle:@"running..." forState:UIControlStateNormal];
    [sender setBackgroundColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0]];
    [sender setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] forState:UIControlStateNormal];
    [sender setEnabled:NO];
    
    // try to run the exploit
    dispatch_async(dispatch_get_main_queue(), ^{

        kern_return_t ret = chosen_strategy.strategy_start();
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if(ret != KERN_SUCCESS) {
                [self showAlertViewController];
                return;
            }
            
            [self.activityIndicator startAnimating];
            [sender setTitle:@"post-exploitation..." forState:UIControlStateNormal];
            
            kern_return_t ret = KERN_SUCCESS;
            
            // in iOS 11, we don't want to do this right away..
            if (![[[UIDevice currentDevice] systemVersion] containsString:@"11"]) {
                chosen_strategy.strategy_post_exploit();
            }
            
            if(ret != KERN_SUCCESS) {
                [self showAlertViewController];
                return;
            }
            //Do some final things
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitle:@"finishing up..." forState:UIControlStateNormal];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // reload sources
                    // yea thats broken let's not
                    //sources_control_init();
                
                    UIViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainUITabBarViewController"];
                    [self presentViewController:homeViewController animated:YES completion:nil];
                });
            });
            

        });    
    });
}

@end
