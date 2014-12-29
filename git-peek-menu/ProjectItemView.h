//
//  ProjectItemView.h
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LocalProject.h"
#import "AppDelegate.h"

@interface ProjectItemView : NSView

@property (nonatomic, strong) NSManagedObjectID *projectId;

@property (nonatomic, strong) NSNumber *minProjectNameSize;
@property (nonatomic, strong) NSNumber *minBranchSize;
@property (nonatomic, strong) NSNumber *minRevisionSize;
@property (nonatomic, strong) NSNumber *minAheadSize;
@property (nonatomic, strong) NSNumber *minBehindSize;
@property (nonatomic, strong) NSNumber *isDark;

- (void)renderView: (LocalProject*) project;

- (void)setButtonTitleFor:(NSButton*)button toString:(NSString*)title withColor:(NSColor*)color;
- (IBAction)build:(NSButton*)sender;
- (IBAction)pull:(NSButton*)sender;

@end