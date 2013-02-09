//
//  OPCPaletteWindowController.m
//  PaletteCreator
//
//  Created by Olivier Larivain on 1/19/13.
//  Copyright (c) 2013 OpenTable, Inc. All rights reserved.
//

#import <OTFoundation/NSString+Hexa.h>

#import "OTFGlobalConfiguration+PaletteCreator.h"

#import "OPCPaletteWindowController.h"

@interface OPCPaletteWindowController ()
@property (weak) IBOutlet NSTextField *pathField;
@property (weak) IBOutlet NSTextField *paletteNameField;
@property (weak) IBOutlet NSTextField *errorLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *generateButton;

@property (strong) NSOperationQueue *operationQueue;

@property (nonatomic, readwrite, strong) NSURL *plistPath;

@end

@implementation OPCPaletteWindowController

- (void) windowDidLoad {
	[super windowDidLoad];
	
	self.operationQueue = [[NSOperationQueue alloc] init];
	self.operationQueue.maxConcurrentOperationCount = 1;
	
	// set up the opened directory on the open panel
	NSURL *lastPath = [self previousPlistPath];
	self.plistPath = lastPath;
	self.pathField.stringValue = lastPath == nil ? @"" : [lastPath lastPathComponent];
}

- (IBAction)chooseFile:(id)sender {

	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.canChooseDirectories = NO;
	panel.canChooseFiles = YES;
	panel.resolvesAliases = YES;
	panel.allowsMultipleSelection = NO;

	// set up the opened directory on the open panel
	panel.directoryURL = [self previousPlistDirectory];
	
	[panel beginSheetModalForWindow: self.window completionHandler:^(NSInteger result) {
		[self panel: panel didChooseFile: result];
	}];
}

- (IBAction)generatePalette:(id)sender {
	if(self.plistPath == nil) {
		self.errorLabel.stringValue = @"Select a plist containing colors.";
		return;
	}
	
	NSString *paletteName = self.paletteNameField.stringValue;
	if(paletteName.length == 0) {
		self.errorLabel.stringValue = @"Select a palette name.";
		return;
	}
	
	self.errorLabel.stringValue = @"";

	[self.progressIndicator startAnimation: nil];
	self.progressIndicator.hidden = NO;
	self.generateButton.enabled = NO;
	
	OTFVoidBlock block = ^{
		[self generatePaletteWithName: paletteName];
	};
	[self.operationQueue addOperationWithBlock: block];
}

- (void) generatePaletteWithName: (NSString *) name {
	
	// create the color list
	NSColorList *colorList = [NSColorList colorListNamed: name];
	if(colorList != nil) {
		[colorList removeFile];
	}
	
	colorList = [[NSColorList alloc] initWithName: name];
	
	// load the configuration file
	NSString *configurationPath = [self.plistPath path];
	NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile: configurationPath];
	
	// go through all keys and look for colors
	for(NSString *key in configuration.allKeys) {
		NSString *value =[configuration objectForKey: key];
		if (![value isKindOfClass: NSString.class] || ![value hasPrefix: @"0x"]) {
			continue;
		}
		
		NSInteger hex = [value integerFromHexaValue];
		NSUInteger red = (hex & 0xFF0000) >> 16;
		NSUInteger green = (hex & 0x00FF00) >> 8;
		NSUInteger blue = (hex & 0x0000FF);
		NSColor *color = [NSColor colorWithDeviceRed: red / 255.0f
											   green: green / 255.0f
												blue: blue / 255.0f
											   alpha: 1.0f];
		[colorList setColor: color forKey: key];
	}
	
	NSString *paletteTargetPath = [NSString stringWithFormat: @"~/%@.clr", name];
	paletteTargetPath = [paletteTargetPath stringByExpandingTildeInPath];
	BOOL saved = [colorList writeToFile: nil];
	DDLogInfo(@"Saved: %i", saved);

	
	OTFVoidBlock completion = ^{
		[self.progressIndicator stopAnimation: nil];
		self.progressIndicator.hidden = YES;
		self.generateButton.enabled = YES;
	};
	DispatchMainThread(completion);
	
}

#pragma mark - NSOpenPanel 
- (void) panel: (NSOpenPanel *) panel didChooseFile: (NSInteger) result {
	if(result == NSFileHandlingPanelCancelButton){
		return;
	}
	
	self.plistPath = panel.URL;
	self.pathField.stringValue = [self.plistPath lastPathComponent];
	
	[self persistPlistPath];
}

#pragma mark - previous path persistence and convenience
- (NSURL *) previousPlistPath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *lastPathString = [defaults objectForKey: @"lastPlistPath"];
	if(lastPathString == nil) {
		return nil;
	}
	return [NSURL fileURLWithPath: lastPathString];
}

- (void) persistPlistPath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [self.plistPath path]
				 forKey: @"lastPlistPath"];
	[defaults synchronize];
}

- (NSURL *) previousPlistDirectory {
	NSURL *lastPath = [self previousPlistPath];
	if(lastPath == nil) {
		return [NSURL fileURLWithPath: [@"~/" stringByExpandingTildeInPath]];
	}
	
	return [lastPath URLByDeletingLastPathComponent];
}

@end
