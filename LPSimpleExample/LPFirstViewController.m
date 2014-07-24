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

- (void) switchValueChanged:(UISwitch *) sender {
  NSLog(@"switch value changed");
  BOOL state = sender.isOn;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:state forKey:kUserDefaultsSwitchState];
  // would normally call this in the UIApplicationDelegate state changing
  // methods but I want to ensure the state is persisted even if the app
  // crashes
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
