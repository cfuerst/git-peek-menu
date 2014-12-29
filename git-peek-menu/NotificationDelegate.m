//
//  NotificationDelegate.m
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "NotificationDelegate.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation NotificationDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (IBAction)showBuildNotification:(NSManagedObjectID*)projectId
{
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    NSManagedObject *project = [[delegate managedObjectContext] objectWithID:projectId];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[[projectId URIRepresentation] absoluteString], @"objectUri", nil]];
    notification.title = [project valueForKey:@"projectName"];
    notification.informativeText = @"Build command finished!";
    notification.soundName = NSUserNotificationDefaultSoundName;
    [notification setHasActionButton: YES];
    [notification setActionButtonTitle: @"output"];
    [notification setOtherButtonTitle: @"close"];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [delegate showMainWindow];
    NSURL *url = [[NSURL alloc] initWithString:[[notification userInfo] valueForKey:@"objectUri"]];
    NSManagedObjectID *projectId = [[delegate persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    LocalProject *project = (LocalProject*)[[delegate managedObjectContext] objectWithID:projectId];
    [ViewController runModalForBuildOutput:project];
}

@end
