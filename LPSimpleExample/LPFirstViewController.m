//  LPFirstViewController.m
//  LPSimpleExample
//
//  Created by Karl Krukow on 07/10/11.
//  Copyright (c) 2011 Trifork. All rights reserved.

static NSString *const kUserDefaultsSwitchState = @"com.xamarin.lpsimpleexample Switch State";

#import "LPFirstViewController.h"

@interface LPFirstViewController ()

- (void) switchValueChanged:(UISwitch *) sender;

@end

@implementation LPFirstViewController

#pragma mark - Memory Management

@synthesize button = _button;
@synthesize uiswitch = _uiswitch;
@synthesize segControl = _segControl;
@synthesize textField = _textField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"First", @"First");
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
  }
  return self;
}


- (void)dealloc {
  [_textField release];
  [_segControl release];

  [_uiswitch release];
  [_button release];
  [super dealloc];
}

- (void)viewDidUnload {
  [self setTextField:nil];
  [self setSegControl:nil];

  [self setUiswitch:nil];
  [self setButton:nil];
  [super viewDidUnload];
}


# pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *) textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return YES;
}

#pragma mark - Actions

- (NSString *)simulatorPreferencesPath {
  static NSString *path = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    NSString *plistName = [NSString stringWithFormat:@"%@.plist", [[NSBundle mainBundle] bundleIdentifier]];

    // 1. Find the app's Library directory so we can deduce the plist path.
    NSArray *userLibDirURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL *userLibraryURL = [userLibDirURLs lastObject];
    NSString *userLibraryPath = [userLibraryURL path];

    // 2. Use the the library path to deduce the simulator environment.

    if ([userLibraryPath rangeOfString:@"CoreSimulator"].location == NSNotFound) {
      // 3. Xcode < 6 environment.
      NSString *sandboxPath = [userLibraryPath substringToIndex:([userLibraryPath rangeOfString:@"Applications"].location)];
      NSString *relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];
      NSString *unsanitizedPlistPath = [sandboxPath stringByAppendingPathComponent:relativePlistPath];
      path = [[unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
    } else {

      /*
       3. CoreSimulator environments

       * In Xcode 6.1 + iOS >= 8.1, UIAutomation and NSUserDefaults do IO on
       the same plist in the app's sandbox.
       * In Xcode 6.1 and iOS < 8.1, UIAutomation does IO on the a file in
       < SIM DIRECTORY >/data/Library/Preferences/ and NSUserDefaults does
       IO on a plist in the app's sandbox.
       * In Xcode 6.0*, NSUserDefaults and UIAutomation do IO on the same plist
       in < SIM DIRECTORY >/data/Library/Preferences.

       Since iOS 8.1 only ships with Xcode 6.1, we can check the system version
       at runtime and choose the correct plist.
       */

      NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
      if ([systemVersion compare:@"8.1" options:NSNumericSearch] != NSOrderedAscending) {
        NSString *relativePlistPath = [NSString stringWithFormat:@"Preferences/%@", plistName];
        NSString *unsanitizedPlistPath = [userLibraryPath stringByAppendingPathComponent:relativePlistPath];
        path = [[unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
      } else {
        NSRange range = [userLibraryPath rangeOfString:@"data"];
        NSString *simulatorDataPath = [userLibraryPath substringToIndex:range.location + range.length];
        NSString *relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];
        NSString *unsanitizedPlistPath = [simulatorDataPath stringByAppendingPathComponent:relativePlistPath];
        path = [[unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
      }
    }
  });
  NSLog(@"NSUserDefaults path = %@", path);
  return path;
}



- (void) switchValueChanged:(UISwitch *) sender {
  NSLog(@"switch value changed");
  BOOL state = sender.isOn;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:state forKey:kUserDefaultsSwitchState];
  [defaults synchronize];
}

#pragma mark - View Lifecycle

-(void) viewDidLoad {
  [super viewDidLoad];

  self.view.accessibilityIdentifier = @"first page";

  self.uiswitch.accessibilityIdentifier = @"switch";
  self.uiswitch.accessibilityLabel = @"On off switch";
  [self.uiswitch addTarget:self
                    action:@selector(switchValueChanged:)
          forControlEvents:UIControlEventValueChanged];
  
  
  self.button.accessibilityLabel = @"Login button";
  self.button.accessibilityIdentifier = @"login";
}

- (IBAction)foobar:(id)sender {
  
}

- (void) viewWillAppear:(BOOL)animated {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL lastSwitchState = [defaults boolForKey:kUserDefaultsSwitchState];
  [self.uiswitch setOn:lastSwitchState];
}

- (void) viewDidAppear:(BOOL)animated {

}

- (void) viewWillDisappear:(BOOL)animated {

}

- (void) viewDidDisappear:(BOOL)animated {

}


@end
