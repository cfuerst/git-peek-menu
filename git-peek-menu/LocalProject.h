//
//  LocalProject.h
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalProject : NSManagedObject

@property (nonatomic, retain) NSString * buildCommand;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * revision;
@property (nonatomic, retain) NSNumber * commitsAhead;
@property (nonatomic, retain) NSNumber * commitsBehind;
@property (nonatomic, retain) NSNumber * hasUntrackedFiles;
@property (nonatomic, retain) NSNumber * hasModifiedFiles;
@property (nonatomic, retain) NSNumber * hasStagedFiles;
@property (nonatomic, retain) NSString * lastBuildCommandOutput;

- (NSComparisonResult)compare:(LocalProject *)item;

@end
