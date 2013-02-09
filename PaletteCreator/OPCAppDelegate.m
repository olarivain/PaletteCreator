//
//  OPCAppDelegate.m
//  PaletteCreator
//
//  Created by Olivier Larivain on 1/19/13.
//  Copyright (c) 2013 OpenTable, Inc. All rights reserved.
//

#import <CocoaLumberjack/DDTTYLogger.h>
#import "OPCAppDelegate.h"

#import "OPCPaletteWindowController.h"

const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface OPCAppDelegate ()
@property (nonatomic, readwrite, strong) OPCPaletteWindowController *windowController;
@end

@implementation OPCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.windowController = [[OPCPaletteWindowController alloc] initWithWindowNibName: @"OPCPaletteMainWindow"];
	self.window = self.windowController.window;

	[DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
