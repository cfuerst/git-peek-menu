//
//  AppDelegate.m
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "AppDelegate.h"
#import "LocalProject.h"
#import "ProjectSyncer.h"
#import "ProjectsMenuItem.h"

@implementation AppDelegate {
    bool isRefreshing;
}

@synthesize mainWindow, notificationDeletage, currentMenuTheme, refreshIntervalTimer, statusItem, statusMenu, refreshItem, projectsMenuItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.notificationDeletage = [[NotificationDelegate alloc] init];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self.notificationDeletage];
    
    //save window reference
    mainWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
    
    //user settings
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    
    //refresh interval
    float interval = [data integerForKey:@"refreshInterval"];
    if (interval < 5) {
        [data setInteger:5 forKey:@"refreshInterval"];
        interval = 5;
    }
    [self setRefreshIntervalTime:(float) interval];
    
    //menu item
    [self renderStatusBar];
    [self updateMenuTitle];
    
    [self refreshApp];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [self showMainWindow];
    return YES;
}

- (void)showMainWindow
{
    [mainWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setRefreshIntervalTime: (float) seconds {
    self.refreshIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:seconds * 60 target:self selector:@selector(refreshApp) userInfo:nil repeats:YES];
}

- (void)invalidateRefreshIntervalTimer {
    [[self refreshIntervalTimer] invalidate];
    self.refreshIntervalTimer = nil;
}

- (void)refreshApp {
    
    if (isRefreshing == true) {
        return;
    }
    isRefreshing = true;
    
    //main entry point to refresh projects and views
    NSLog(@"refresh app");
    [statusItem setTitle:@"♺"];
    [refreshItem setAction:nil];
    
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //user settings
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    
    NSArray *projects = [self getAllProjects];
    
    //update all projects in seperate thread
    for (LocalProject *project in projects) {
        
        if ([project path] == nil) continue;
        NSString *projectPath = [[NSString alloc] initWithString:[project path]];
        
        dispatch_group_async(d_group, bg_queue, ^{
            
            NSLog(@"start thread for: %@", projectPath);
            
            //refresh if enabled
            if ([data integerForKey:@"autoRefreshEnabled"] == 1) {
                NSLog(@"remote fetch: %@", projectPath);
                [ProjectSyncer fetchRemote:projectPath];
            }
            
            //get data
            NSDictionary *dict = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                [ProjectSyncer getBranchName:     projectPath], @"branch",
                [ProjectSyncer getRevision:       projectPath], @"revision",
                [ProjectSyncer getCommitsAhead:   projectPath], @"commitsAhead",
                [ProjectSyncer getCommitsBehind:  projectPath], @"commitsBehind",
                [ProjectSyncer hasUntrackedFiles: projectPath], @"hasUntrackedFiles",
                [ProjectSyncer hasModifiedFiles:  projectPath], @"hasModifiedFiles",
                [ProjectSyncer hasStagedFiles:    projectPath], @"hasStagedFiles",
            nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateProject:[project objectID] data:dict];
                NSLog(@"finished thread for: %@", projectPath);
            });
        });
    }
    
    //executed when all threads are finished
    dispatch_group_notify(d_group, dispatch_get_main_queue(), ^{
        NSLog(@"done refresing app");
        [self updateMenuTitle];
        [refreshItem setAction:@selector(refreshApp)];
        [projectsMenuItem performSelector:@selector(renderProjects) withObject:nil];
        isRefreshing = false;
    });
    
}

- (void)updateProject: (NSManagedObjectID*) objectId data: (NSDictionary*)data {
    //update project with data
    id project = [[self managedObjectContext] objectWithID:objectId];
    if (project) {
        for (NSString *key in data) {
            [project setValue:[data objectForKey:key] forKey:key];
        }
    }
}

- (void)pullProject:(NSArray*)arguments {
    NSManagedObject *project = [[self managedObjectContext] objectWithID:[arguments objectAtIndex:0]];
    NSButton *sender = [arguments objectAtIndex:1];
    //do not pull while updateing
    while (isRefreshing == true) {
        sleep(1);
    }
    [ProjectSyncer pull:[project valueForKey:@"path"]];
    [sender setHidden:TRUE];
    [self performSelectorOnMainThread:@selector(refreshApp) withObject:nil waitUntilDone:NO];
}

- (void)buildProject:(NSArray*)arguments {
    NSManagedObject *project = [[self managedObjectContext] objectWithID:[arguments objectAtIndex:0]];
    NSButton *sender = [arguments objectAtIndex:1];
    //do not build while updateing
    while (isRefreshing == true) {
        sleep(1);
    }
    NSString *output = [ProjectSyncer runCommand:[project valueForKey:@"buildCommand"]];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: output, @"lastBuildCommandOutput", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProject:[project objectID] data:dict];
        [self.notificationDeletage showBuildNotification:[project objectID]];
    });
    [sender setEnabled:TRUE];
    [sender setTitle:@"build"];
}

- (NSArray*)getAllProjects {
    //get all projects from Managed Object context
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LocalProject" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    return array;
}

-(void)renderStatusBar
{
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSView *titleView     = [[NSView alloc] initWithFrame:CGRectMake(0.f, 0.f, 80.f, 20.f)];
    NSMenuItem *titleItem = [[NSMenuItem alloc] init];
    NSTextField *field = [[NSTextField alloc] initWithFrame:CGRectMake(20.f, 0.f, 80.f, 20.f)];
    [field setBezeled:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setStringValue:@"Projects:"];
    [field setFont:[NSFont systemFontOfSize:14]];
    [titleView addSubview:field];
    [titleItem setView:titleView];
    
    [menu addItem:titleItem];
    [menu addItem:[NSMenuItem separatorItem]];
    
    projectsMenuItem = [[ProjectsMenuItem alloc] init];
    [projectsMenuItem performSelector:@selector(renderProjects) withObject:nil];
    [menu addItem:projectsMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    refreshItem = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(refreshApp) keyEquivalent:@""];
    
    [menu addItem:refreshItem];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"Preferences" action:@selector(showMainWindow) keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"↑ ↓"];
    [statusItem setHighlightMode:YES];
    statusItem.menu = menu;
    
    [menu cancelTracking];
    
    //@todo how can this be observed properly not depending what is drawn before
    currentMenuTheme = [[NSAppearance currentAppearance] name];
}

-(void)updateMenuTitle
{
    //change title
    int ahead  = 0;
    int behind = 0;
    for (id project in [self getAllProjects]) {
        ahead  += [[project valueForKey:@"commitsAhead"]  intValue];
        behind += [[project valueForKey:@"commitsBehind"] intValue];
    }
    NSString * aheadTitle = @"↑";
    if (ahead > 0) {
        aheadTitle = [NSString stringWithFormat:@"↑%d", ahead];
    }
    NSString * behindTitle = @"↓";
    if (behind > 0) {
        behindTitle = [NSString stringWithFormat:@"↓%d", behind];
    }
    [statusItem setTitle:[NSString stringWithFormat:@"%@ %@", aheadTitle, behindTitle]];
}

- (IBAction)showNotification:(id)sender{
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Hello, World!";
    notification.informativeText = @"A notification";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "cfuerst.git_peek_menu" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"cfuerst.git_peek_menu"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"git_peek_menu" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
