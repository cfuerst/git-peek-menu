//
//  ViewController.m
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //@todo why does the default arraycontroller hold a intance of managedObjectContext
    //which is not the same then the app delegate one (this causes huge problems)
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [[self projectsArrayController] setManagedObjectContext:[delegate managedObjectContext]];
    
    [self adjustTableColumnWidth];
    [self updateSettingsView];
}

-(void)adjustTableColumnWidth {
    float lenght = 0.f;
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    NSArray *projects = [delegate getAllProjects];
    for (LocalProject *project in projects) {
        NSSize size = [[project path] sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:14]}];
        if (lenght < size.width) {
            lenght = size.width;
        }
    }
    [[self projectsTableColumn] setWidth:lenght];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)selectPathButtonAction:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setPrompt:@"Select"];
    [openDlg setAllowsMultipleSelection:YES];
    
    if ( [openDlg runModal] == NSModalResponseOK ) {
        
        NSArray* files = [openDlg URLs];
        
        for (NSURL* directory in files) {
        
            //check if there is a git folder present
            if ([[[NSFileManager alloc] init] fileExistsAtPath:[[directory path] stringByAppendingString:@"/.git"]]) {
            
                //add project
                NSManagedObjectContext *context = [[self projectsArrayController] managedObjectContext];
                NSManagedObject *localProject = [NSEntityDescription insertNewObjectForEntityForName:@"LocalProject" inManagedObjectContext:context];
                NSArray *tmp = [[directory path] componentsSeparatedByString:@"/"];
            
                //add project and set sane default values
                [localProject setValue:[directory path] forKey:@"path"];
                [localProject setValue:[tmp lastObject] forKey:@"projectName"];
                [localProject setValue:@"master" forKey:@"branch"];
                [localProject setValue:@"head" forKey:@"revision"];
                [localProject setValue:[NSNumber numberWithInt:0] forKey:@"commitsAhead"];
                [localProject setValue:[NSNumber numberWithInt:0] forKey:@"commitsBehind"];
                [localProject setValue:[NSNumber numberWithBool:FALSE] forKey:@"hasUntrackedFiles"];
                [localProject setValue:[NSNumber numberWithBool:FALSE] forKey:@"hasModifiedFiles"];
                [localProject setValue:[NSNumber numberWithBool:FALSE] forKey:@"hasStagedFiles"];
            
                //refresh
                [[self projectsArrayController] addObject:localProject];
                [self adjustTableColumnWidth];
            
            } else {
                //inform user about missing git folder
                NSAlert *alertView = [[NSAlert alloc] init];
                [alertView setMessageText:[NSString stringWithFormat:@"%@: directory is not a git repository", [directory path]]];
                [alertView runModal];
            }
            
        }
        
        //send rehresh of app
        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        [delegate performSelectorOnMainThread:@selector(refreshApp) withObject:nil waitUntilDone:NO];
    }
}

- (void) updateSettingsView
{
    self.intervalIndicator.stringValue = [[NSString alloc] initWithFormat:@"%d min", [[self intervalSlider] intValue] ];
}

- (IBAction)refreshIntervalAction:(id)sender {
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [delegate invalidateRefreshIntervalTimer];
    [delegate setRefreshIntervalTime:(float) [[self intervalSlider] intValue]];
    [self updateSettingsView];
}

- (IBAction)projectPreferenceAction:(id)sender {
    
    long selected = [[self projectsTableView] selectedRow];
    
    if (selected >= 0) {
        
        LocalProject *selectedProject = self.projectsArrayController.arrangedObjects[selected];
        
        //@todo create a better view to do this (maybe with testing options)
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"console build command:"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
        if ([selectedProject buildCommand]) {
            [input setStringValue:[selectedProject buildCommand]];
        }
        [alert setAccessoryView:input];
        [alert runModal];
        [selectedProject setBuildCommand:[input stringValue]];
        //send rehresh of app
        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        [delegate performSelectorOnMainThread:@selector(refreshApp) withObject:nil waitUntilDone:NO];
    }
}

- (IBAction)projectInfoAction:(id)sender {
    
    long selected = [[self projectsTableView] selectedRow];
    
    if (selected >= 0) {
        LocalProject *project = self.projectsArrayController.arrangedObjects[selected];
        [ViewController runModalForBuildOutput:project];
    }
}

+ (void) runModalForBuildOutput: (LocalProject*)project
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    if ([[project lastBuildCommandOutput] length] > 0) {
        
        [alert setMessageText:@"last build command output:"];
        
        NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)];
        NSSize contentSize = [scrollview contentSize];
        [scrollview setBorderType:NSNoBorder];
        [scrollview setHasVerticalScroller:YES];
        [scrollview setHasHorizontalScroller:YES];
        [scrollview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
        [textView setString:[project valueForKey:@"lastBuildCommandOutput"]];
        [textView setMinSize:NSMakeSize(0.0, contentSize.height)];
        [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [textView setAutoresizingMask:NSViewWidthSizable];
        [[textView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
        [[textView textContainer] setWidthTracksTextView:YES];
        [[textView enclosingScrollView] setHasHorizontalScroller:YES];
        [textView setHorizontallyResizable:YES];
        [textView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [[textView textContainer] setWidthTracksTextView:NO];
        [scrollview setDocumentView:textView];
        
        [alert setAccessoryView:scrollview];
        
    } else {
        [alert setMessageText:@"no build output yet!"];
    }
    [alert runModal];
}

@end
