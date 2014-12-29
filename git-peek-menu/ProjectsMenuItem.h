//
//  ProjectsMenuItem.h
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LocalProject.h"
#import "ProjectItemView.h"

@interface ProjectsMenuItem : NSMenuItem

@property (nonatomic, strong) NSView *mainView;

-(void)renderProjects;

@end