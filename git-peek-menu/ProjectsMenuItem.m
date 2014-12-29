//
//  ProjectsMenuItem.m
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "ProjectsMenuItem.h"

@implementation ProjectsMenuItem {
    bool isDark;
    float height;
}

-(instancetype)init {
    self = [super init];
    self.mainView = [[NSView alloc] init];
    [self setView:[self mainView]];
    return self;
}

-(void)renderProjects
{
    //delegate
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    //remove any subviews before starting
    [[self.mainView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //@todo toolbar color theme hack (caused by rendering views yourself)
    isDark = false;
    if ([delegate currentMenuTheme] && [[delegate currentMenuTheme] containsString:@"NSAppearanceNameVibrantDark"]) {
        isDark  = true;
    }

    //get projects
    NSArray *projects = [delegate getAllProjects];
    
    NSRect f = self.mainView.frame;
    
    //no projects added display message
    if([projects count] == 0){
        f.size.height = 20.f;
        f.size.width = 150.f;
        self.mainView.frame = f;
        [self.mainView addSubview:[self getNoProjectsView]];
        return;
    }
    
    f.size.width = 0.f;
    
    //get max left sizes
    height = 0.f;
    NSNumber *minProjectNameSize = [self getCalcMinSize:projects forSelector:@"projectName" isBold:YES];
    NSNumber *minBranchSize = [self getCalcMinSize:projects forSelector:@"branch" isBold:YES];
    NSNumber *minRevisionSize = [self getCalcMinSize:projects forSelector:@"revision" isBold:YES];
    NSNumber *minAheadSize = [self getCalcMinSize:projects forSelector:@"commitsAhead" isBold:YES];
    NSNumber *minBehindSize = [self getCalcMinSize:projects forSelector:@"commitsBehind" isBold:YES];
    
    //iterate projects and add subviews
    for (LocalProject *project in projects) {
        
        ProjectItemView *projectItemView = [[ProjectItemView alloc] initWithFrame:CGRectMake(0.f, height, 0.f, 0.f)];
        [projectItemView setMinProjectNameSize:minProjectNameSize];
        [projectItemView setMinBranchSize:minBranchSize];
        [projectItemView setMinRevisionSize:minRevisionSize];
        [projectItemView setMinAheadSize:minAheadSize];
        [projectItemView setMinBehindSize:minBehindSize];
        [projectItemView setIsDark:[NSNumber numberWithBool:isDark]];
        [projectItemView renderView:project];
        
        [self.mainView addSubview:projectItemView];
        
        NSRect subframe = projectItemView.frame;
        
        if (f.size.width < subframe.size.width) {
            f.size.width = subframe.size.width;
        }
        
        height += 20.f;
    }
    
    f.size.height = height;
    self.mainView.frame = f;
}

- (NSView*)getNoProjectsView
{
    NSView *view = [[NSView alloc] init];
    NSRect f = view.frame;
    f.size.height = 20.f;
    f.size.width = 140.f;
    view.frame = f;
    NSColor *color = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    if (isDark == true) {
        color = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.4f];
    }
    NSTextField *field = [[NSTextField alloc] initWithFrame:CGRectMake(20.f, 0.f, 120.f, 20.f)];
    [field setBezeled:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setStringValue:@"no projects added"];
    [field setTextColor:color];
    [field setNeedsDisplay:YES];
    [view addSubview:field];
    return view;
}

- (NSNumber*)getCalcMinSize:(NSArray*)projects forSelector:(NSString*)selector isBold:(BOOL)isBold
{
    NSFont *font = [NSFont systemFontOfSize:14];
    if (isBold == true) {
        font = [NSFont boldSystemFontOfSize:14];
    }
    float lenght = 0.f;
    for (id project in projects) {
        CGRect rect;
        
        id originalValue = [project valueForKey:selector];
        NSString *value = [[NSString alloc] init];
        
        if ([[originalValue class] isSubclassOfClass:[NSString class]]) {
            value = originalValue;
        } else {
            value = [NSString stringWithFormat:@"%d", [originalValue intValue]];
        }
        
        rect.size = [value sizeWithAttributes:@{NSFontAttributeName: font}];
        if (lenght < rect.size.width) {
            lenght = rect.size.width;
        }
    }
    return [NSNumber numberWithFloat:lenght];
}

@end
