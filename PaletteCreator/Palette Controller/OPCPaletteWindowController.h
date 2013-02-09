//
//  OPCPaletteWindowController.h
//  PaletteCreator
//
//  Created by Olivier Larivain on 1/19/13.
//  Copyright (c) 2013 OpenTable, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPCPaletteWindowController : NSWindowController<NSWindowDelegate>
- (IBAction)chooseFile:(id)sender;
- (IBAction)generatePalette:(id)sender;

@end
