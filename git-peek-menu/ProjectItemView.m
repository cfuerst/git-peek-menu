//
//  ProjectItemView.m
//  git-peek-menu
//
//  Created by Christian Fürst on 23.12.14.
//  Copyright (c) 2014 Christian Fuerst. All rights reserved.
//

#import "ProjectItemView.h"

@implementation ProjectItemView {
    float left;
}

@synthesize projectId, minProjectNameSize, minBranchSize, minRevisionSize, minAheadSize, minBehindSize, isDark;

- (void)renderView: (LocalProject*) project {
    
    self.projectId = [project objectID];
    
    //user settings
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    long showPullButton = [data integerForKey:@"pullButtonEnabled"];
    long showBuildButton = [data integerForKey:@"buildButtonEnabled"];
    
    //some ui presets
    NSFont *fontNormal = [NSFont systemFontOfSize:14];
    NSFont *fontBold   = [NSFont boldSystemFontOfSize:14];
    NSColor *normal    = [NSColor colorWithRed:0 green:0 blue:0 alpha:1.f];
    NSColor *inactive  = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    NSColor *active    = [NSColor colorWithRed:0 green:0 blue:0 alpha:1.f];
    if ([[self isDark] boolValue] == true) {
        normal   = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.8f];
        inactive = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.4f];
        active   = [NSColor colorWithRed:1 green:1 blue:1 alpha:1.f];
    }
    
    //start intendation
    left = 20.f;
    
    [self addSubview:[self getProjectImage:([project.hasUntrackedFiles boolValue]) ? @"NSStatusUnavailable"        : @"NSStatusNone"]];
    [self addSubview:[self getProjectImage:([project.hasModifiedFiles boolValue]) ?  @"NSStatusPartiallyAvailable" : @"NSStatusNone"]];
    [self addSubview:[self getProjectImage:([project.hasStagedFiles boolValue]) ?    @"NSStatusAvailable"          : @"NSStatusNone"]];
    
    left += 5.f;
    
    [self addSubview:[self textFieldWithString:project.projectName
                      forColor:([[self isDark] boolValue] == true) ? active : normal
                      andFont:fontBold
                      andSize:self.minProjectNameSize]];
    
    [self addSubview:[self textFieldWithString:[NSString stringWithFormat:@"[%@]", [project.branch stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]]
                      forColor:normal
                      andFont:fontNormal
                      andSize:[NSNumber numberWithFloat:([self.minBranchSize floatValue] + 8.f)]]];
    
    [self addSubview:[self textFieldWithString:[@"↑A" stringByAppendingString:[NSString stringWithFormat: @"%d", [project.commitsAhead intValue]]]
                      forColor:([project.commitsAhead intValue] == 0) ? inactive : active
                      andFont:([project.commitsAhead intValue] == 0) ? fontNormal : fontBold
                      andSize:[NSNumber numberWithFloat:([self.minAheadSize floatValue] + 25.f)]]];
    
    [self addSubview:[self textFieldWithString:[@"↓B" stringByAppendingString:[NSString stringWithFormat: @"%d", [project.commitsBehind intValue]]]
                      forColor:([project.commitsBehind intValue] == 0) ? inactive : active
                      andFont:([project.commitsBehind intValue] == 0) ? fontNormal : fontBold
                      andSize:[NSNumber numberWithFloat:([self.minBehindSize floatValue] + 25.f)]]];
    
    [self addSubview:[self textFieldWithString:[NSString stringWithFormat:@"[%@]", [project.revision stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]]
                      forColor:normal
                      andFont:fontNormal
                      andSize:[NSNumber numberWithFloat:([self.minRevisionSize floatValue] + 8.f)]]];
    
    if (showPullButton == 1
        && [project.commitsBehind intValue] > 0
        && [project.commitsAhead intValue] == 0
        && [project.hasUntrackedFiles boolValue] == false
        && [project.hasModifiedFiles boolValue] == false
        && [project.hasStagedFiles boolValue] == false
    ) {
        
        left += 5.f;
        NSButton *pullButton = [[NSButton alloc] initWithFrame:CGRectMake(left, 0.f, 40.f, 20.f)];
        [pullButton setTitle:@"pull"];
        [pullButton setTarget:self];
        [pullButton setAction:@selector(pull:)];
        [pullButton setToolTip:@"git pull"];
        [pullButton setBezelStyle:NSTexturedSquareBezelStyle];
        [self addSubview:pullButton];
        left += 40.f;
    }
    
    if (showBuildButton == 1 && [project.buildCommand length] > 5) {
        
        left += 5.f;
        NSButton *buildButton = [[NSButton alloc] initWithFrame:CGRectMake(left, 0.f, 40.f, 20.f)];
        [buildButton setTitle:@"build"];
        [buildButton setTarget:self];
        [buildButton setAction:@selector(build:)];
        [buildButton setToolTip:@"custom command"];
        [buildButton setBezelStyle:NSTexturedSquareBezelStyle];
        [self addSubview:buildButton];
        left += 30.f;
    }
    
    NSRect f = self.frame;
    f.size.height = 20.f;
    f.size.width = left + 20.f;
    self.frame = f;
}

- (NSView*)getProjectImage:(NSString*)imageName
{
    NSImage *image = [NSImage imageNamed:imageName];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectMake(0.f, 2.f, 14.f, 14.f)];
    [imageView setImage:image];
    NSView  *view = [[NSView alloc] initWithFrame:CGRectMake(left, 0.f, 14.f , 14.f)];
    [view addSubview:imageView];
    left += 15.f;
    [view setNeedsDisplay:YES];
    return view;
}

- (NSTextField*)textFieldWithString:(NSString*)text forColor:(NSColor*)color andFont:(NSFont*)font andSize:(NSNumber*)size
{
    float lenght = 0.f;
    if ([size floatValue] > 0) {
        lenght = [size floatValue];
    } else {
        CGRect rect;
        rect.size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
        lenght = rect.size.width;
    }
    lenght += 10.f;
    NSTextField *field = [[NSTextField alloc] initWithFrame:CGRectMake(left, 0.f, lenght, 20.f)];
    [field setBezeled:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setStringValue:text];
    [field setFont:font];
    [field setTextColor:color];
    left += lenght;
    [field setNeedsDisplay:YES];
    return field;
}

- (IBAction)pull:(NSButton*)sender
{
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    [sender setEnabled:FALSE];
    [sender setTitle:@"wait"];
    [delegate performSelectorInBackground:@selector(pullProject:) withObject:[NSArray arrayWithObjects:self.projectId,sender,nil]];
}

- (IBAction)build:(NSButton*)sender
{
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    [sender setEnabled:FALSE];
    [sender setTitle:@"wait"];
    [delegate performSelectorInBackground:@selector(buildProject:) withObject:[NSArray arrayWithObjects:self.projectId,sender,nil]];
}

- (void)setButtonTitleFor:(NSButton*)button toString:(NSString*)title withColor:(NSColor*)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:title attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}

@end