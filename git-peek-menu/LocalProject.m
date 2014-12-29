//
//  LocalProject.m
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "LocalProject.h"


@implementation LocalProject

@dynamic buildCommand;
@dynamic path;
@dynamic projectName;
@dynamic branch;
@dynamic revision;
@dynamic commitsAhead;
@dynamic commitsBehind;
@dynamic hasUntrackedFiles;
@dynamic hasModifiedFiles;
@dynamic hasStagedFiles;
@dynamic lastBuildCommandOutput;

- (NSComparisonResult)compare:(LocalProject *)item
{
    return [self.projectName localizedStandardCompare:item.projectName];
}

@end
