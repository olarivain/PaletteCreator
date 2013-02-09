//
//  OTFGlobalConfiguration+PaletteCreator.m
//  PaletteCreator
//
//  Created by Olivier Larivain on 1/19/13.
//  Copyright (c) 2013 OpenTable, Inc. All rights reserved.
//

#import "OTFGlobalConfiguration+PaletteCreator.h"

@implementation OTFGlobalConfiguration (PaletteCreator)

+ (OTFGlobalConfiguration *) configurationWithPath: (NSString *) path {
	return [[OTFGlobalConfiguration alloc] initWithPath: path];
}

- (id) initWithPath: (NSString *) path {
	self = [super init];
	if(self) {
        // load if possible
        if(path == nil)
        {
            DDLogWarn(@"**** Fatal: Could not load Configuration.plist");
            _configuration = [NSMutableDictionary dictionary];
        }
        else
        {
            _configuration = [NSMutableDictionary dictionaryWithContentsOfFile: path];
        }
	}
	return self;
}

@end
