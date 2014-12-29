//
//  AppDelegate.h
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotificationDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindow *mainWindow;

@property (nonatomic, strong) NotificationDelegate *notificationDeletage;

@property (nonatomic, strong) NSString *currentMenuTheme;
@property (nonatomic, strong) NSTimer *refreshIntervalTimer;

@property (assign) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenuItem *refreshItem;
@property (nonatomic, strong) NSMenuItem *projectsMenuItem; //@todo why cant i typehint it to ProjectsMenuItem?

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (NSArray*)getAllProjects;

- (void)setRefreshIntervalTime: (float) minutes;
- (void)invalidateRefreshIntervalTimer;
- (void)refreshApp;

- (void)pullProject:(NSArray*)arguments;
- (void)buildProject:(NSArray*)arguments;

- (void)showMainWindow;


@end

