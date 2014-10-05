//
//  LPAppDelegate.m
//  LPSimpleExample
//
//  Created by Karl Krukow on 07/10/11.
//  Copyright (c) 2011 Trifork. All rights reserved.
//

#import "LPAppDelegate.h"

#import "LPFirstViewController.h"

#import "LPSecondViewController.h"

#import "LPThirdViewController.h"
#import "LPFourthViewController.h"

@implementation LPAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc {
  [_window release];
  [_tabBarController release];
  [super dealloc];
}

- (NSString *) JSONStringWithArray:(NSArray *) aArray {
  NSData *data = [NSJSONSerialization dataWithJSONObject:aArray
                                                 options:0
                                                   error:nil];
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return string;
}

- (NSString *) JSONStringWithDictionary:(NSDictionary *) aDictionary {
  NSData *data = [NSJSONSerialization dataWithJSONObject:aDictionary
                                                 options:0
                                                   error:nil];
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return string;
}


- (NSString *) stringForDefaultsDictionary:(NSString *) aIgnore {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults synchronize];
  NSDictionary *dictionary = [defaults dictionaryRepresentation];
  return [self JSONStringWithDictionary:dictionary];
}

- (NSString *)simulatorPreferencesPath:(NSString *) aIgnore {
  static NSString *path = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *plistRootPath = nil, *relativePlistPath = nil;
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", [[NSBundle mainBundle] bundleIdentifier]];

    // 1. get into the simulator's app support directory by fetching the sandboxed Library's path

    NSArray *userLibDirURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];

    NSURL *userDirURL = [userLibDirURLs lastObject];
    NSString *userDirectoryPath = [userDirURL path];

    // 2. get out of our application directory, back to the root support directory for this system version
    if ([userDirectoryPath rangeOfString:@"CoreSimulator"].location == NSNotFound) {
      plistRootPath = [userDirectoryPath substringToIndex:([userDirectoryPath rangeOfString:@"Applications"].location)];
    } else {
      NSRange range = [userDirectoryPath rangeOfString:@"data"];
      plistRootPath = [userDirectoryPath substringToIndex:range.location + range.length];
    }

    // 3. locate, relative to here, /Library/Preferences/[bundle ID].plist
    relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];

    // 4. and unescape spaces, if necessary (i.e. in the simulator)
    NSString *unsanitizedPlistPath = [plistRootPath stringByAppendingPathComponent:relativePlistPath];
    path = [[unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
  });
  NSLog(@"sim pref path = %@", path);
  return path;
}

- (NSString *) stringForPathToDocumentsDirectory {
  NSArray *dirPaths =
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                      NSUserDomainMask,
                                      YES);
  return dirPaths[0];
}


- (NSString *) stringForPathToLibraryDirectoryForUserp:(BOOL) forUser {
  NSSearchPathDomainMask mask;
  if (forUser == YES) {
    mask = NSUserDomainMask;
  } else {
    mask = NSLocalDomainMask;
  }
  NSArray *dirPaths =
  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                      mask,
                                      YES);
  return dirPaths[0];
}

- (NSString *) stringForPathToSandboxDirectory:(NSString *) aSandboxDirectory {
  NSArray *allowed = @[@"tmp", @"Documents", @"Library"];
  NSUInteger idx = [allowed indexOfObject:aSandboxDirectory];
  if (idx == NSNotFound) {
    NSLog(@"expected '%@' to be one of '%@'", aSandboxDirectory, allowed);
    return nil;
  }
  NSString *path = nil;
  if ([aSandboxDirectory isEqualToString:@"Documents"]) {
    path = [self stringForPathToDocumentsDirectory];
  } else if ([aSandboxDirectory isEqualToString:@"Library"]) {
    path = [self stringForPathToLibraryDirectoryForUserp:YES];
  } else {
    NSString *libPath = [self stringForPathToLibraryDirectoryForUserp:YES];
    NSString *containingDir = [libPath stringByDeletingLastPathComponent];
    path = [containingDir stringByAppendingPathComponent:@"tmp"];
  }

  NSLog(@"path = %@", path);
  return path;
}

- (NSArray *) arrayForFilesInSandboxDirectory:(NSString *) aSandboxDirectory {
  NSString *path = [self stringForPathToSandboxDirectory:aSandboxDirectory];
  if (!path) { return nil; }
  NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                                   error:NULL];
  return directoryContents;
}


- (NSString *) addFileToSandboxDirectory:(NSString *) aJSONDictionary {
  NSData *argData = [aJSONDictionary dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *details = [NSJSONSerialization JSONObjectWithData:argData options:0 error:NULL];

  NSString *directory = details[@"directory"];
  if (!directory) {
    NSLog(@"Expected value for key 'directory' in %@", details);
    return nil;
  }
  NSString *filename = details[@"filename"];
  if (!filename) {
    NSLog(@"Expected value for key 'filename' in %@", details);
    return nil;
  }

  NSString *directoryPath = [self stringForPathToSandboxDirectory:directory];
  if (!directoryPath) { return nil; }

  NSString *path = [directoryPath stringByAppendingPathComponent:filename];
  NSString *contents = @"Boo!";
  NSData *fileData = [contents dataUsingEncoding:NSUTF8StringEncoding];
  [fileData writeToFile:path atomically:YES];
  return filename;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    UIViewController *viewController1 = [[[LPFirstViewController alloc] initWithNibName:@"LPFirstViewController" bundle:nil] autorelease];
    UIViewController *viewController2 = [[[LPSecondViewController alloc] initWithNibName:@"LPSecondViewController" bundle:nil] autorelease];
    
    UIViewController *viewController3 = [[[LPThirdViewController alloc] initWithNibName:@"LPThirdViewController" bundle:nil] autorelease];

    UIViewController *viewController4 = [[[LPFourthViewController alloc] initWithNibName:@"LPFourthViewController" bundle:nil] autorelease];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[viewController1, viewController2,viewController3,viewController4];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
        NSLog(@"RESIGNACTIVE");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"ENTERBACK");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
        NSLog(@"ENTERFORE");
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"BECOMEACTIVE");
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
