//
//  ProjectSyncer.h
//  local-git-project-viewer
//
//  Created by Christian Fuerst on 28.11.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectSyncer : NSObject

+ (void)pull:(NSString*)path;
+ (void)fetchRemote:(NSString*)path;
+ (NSString*)getBranchName:(NSString*)path;
+ (NSString*)getRevision:(NSString*)path;
+ (NSNumber*)getCommitsAhead:(NSString*)path;
+ (NSNumber*)getCommitsBehind:(NSString*)path;
+ (NSNumber*)hasUntrackedFiles:(NSString*)path;
+ (NSNumber*)hasModifiedFiles:(NSString*)path;
+ (NSNumber*)hasStagedFiles:(NSString*)path;

+ (NSString*)runCommand:(NSString*)commandToRun;

@end