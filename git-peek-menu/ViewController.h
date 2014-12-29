//
//  ViewController.h
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "LocalProject.h"

@interface ViewController : NSViewController

- (IBAction)refreshIntervalAction:(id)sender;
- (IBAction)projectPreferenceAction:(id)sender;
- (IBAction)projectInfoAction:(id)sender;
+ (void) runModalForBuildOutput: (LocalProject*)project;

@property (weak) IBOutlet NSSlider *intervalSlider;
@property (weak) IBOutlet NSTextField *intervalIndicator;
@property (weak) IBOutlet NSButton *intervalCheckbox;

@property (weak) IBOutlet NSTableView *projectsTableView;
@property (weak) IBOutlet NSTableColumn *projectsTableColumn;
@property (strong) IBOutlet NSArrayController *projectsArrayController;

@end

