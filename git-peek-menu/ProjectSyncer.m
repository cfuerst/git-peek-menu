//
//  ProjectSyncer.m
//  local-git-project-viewer
//
//  Created by Christian Fuerst on 28.11.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProjectSyncer.h"

@implementation ProjectSyncer

+ (void)pull:(NSString*)path
{
    [self runCommand:[NSString stringWithFormat:@"git -C %@ pull -q", path]];
}

+ (void)fetchRemote:(NSString*)path
{
    [self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ fetch 2>&1 | wc -l |  tr -d ' ')", path]];
}

+ (NSString*)getBranchName:(NSString*)path
{
    return [self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ rev-parse --abbrev-ref HEAD)", path]];
}

+ (NSString*)getRevision:(NSString*)path
{
    return [self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ log --pretty=format:'%%h' -n 1) ", path]];
}

+ (NSNumber*)getCommitsAhead:(NSString*)path
{
    return [NSNumber numberWithInteger:
        [[self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')", path]] integerValue]
    ];
}

+ (NSNumber*)getCommitsBehind:(NSString*)path
{
    return [NSNumber numberWithInteger:
        [[self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')", path]] integerValue]
    ];
}

+ (NSNumber*)hasUntrackedFiles:(NSString*)path
{
    return [NSNumber numberWithBool:
        ([[self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ ls-files --other --exclude-standard 2> /dev/null | wc -l | tr -d ' ')", path]] intValue] == 0) ? false : true
    ];
}

+ (NSNumber*)hasModifiedFiles:(NSString*)path
{
    return [NSNumber numberWithBool:
        ([[self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ diff 2> /dev/null | wc -l | tr -d ' ')", path]] intValue] == 0) ? false : true
    ];
}

+ (NSNumber*)hasStagedFiles:(NSString*)path
{
    return [NSNumber numberWithBool:
        ([[self runCommand:[NSString stringWithFormat:@"echo $(git -C %@ diff --cached 2> /dev/null | wc -l | tr -d ' ')", path]] intValue] == 0) ? false : true
    ];
}

+ (NSString*)runCommand:(NSString*)commandToRun
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@", commandToRun], nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
        
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}


@end
