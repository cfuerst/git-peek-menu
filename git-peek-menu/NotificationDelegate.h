//
//  NotificationDelegate.h
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationDelegate : NSObject <NSUserNotificationCenterDelegate>

- (IBAction)showBuildNotification:(id)sender;

@end

