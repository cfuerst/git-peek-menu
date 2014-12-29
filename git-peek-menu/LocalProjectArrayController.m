//
//  LocalProjectArrayController.m
//  git-peek-menu
//
//  Created by Christian Fuerst on 19.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "LocalProjectArrayController.h"


@implementation LocalProjectArrayController

-(void)remove:(id)sender {
    //remove from list
    [super remove:sender];
    
    //send rehresh of app
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [delegate performSelectorOnMainThread:@selector(refreshApp) withObject:nil waitUntilDone:NO];
}

@end
