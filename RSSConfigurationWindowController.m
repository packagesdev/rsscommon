/*
 Copyright (c) 2015, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RSSConfigurationWindowController.h"

#import "RSSAboutBoxWindowController.h"

#import <ScreenSaver/ScreenSaver.h>

#import "RSSUserDefaults+Constants.h"

#import "RSSWindow.h"

@interface RSSConfigurationWindowController () <RSSWindowDelegate>
{
	BOOL _mainScreenSetting;
}

@end

@implementation RSSConfigurationWindowController

- (id)init
{
	self=[super init];
	
	if (self!=nil)
	{
		NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
		ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
		
		sceneSettings=[[[self settingsClass] alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]];
		
		_mainScreenSetting=[tDefaults boolForKey:RSSUserDefaultsMainDisplayOnly];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Class)settingsClass
{
	return [RSSSettings class];
}

- (NSString *)windowNibName
{
	return NSStringFromClass([self class]);
}

#pragma mark -

- (void)restoreUI
{
	[mainScreenCheckBox setState:(_mainScreenSetting==YES) ? NSOnState : NSOffState];
}

#pragma mark -

- (IBAction)showAboutBox:(id)sender
{
	static RSSAboutBoxWindowController * sAboutBoxWindowController=nil;
	
	if (sAboutBoxWindowController==nil)
		sAboutBoxWindowController=[RSSAboutBoxWindowController new];
	
	if ([sAboutBoxWindowController.window isVisible]==NO)
		[sAboutBoxWindowController.window center];
	
	[sAboutBoxWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)resetDialogSettings:(id)sender
{
	[sceneSettings resetSettings];
	
	_mainScreenSetting=NO;
	
	[self restoreUI];
}

- (IBAction)closeDialog:(id)sender
{
	NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
	
	if ([sender tag]==NSOKButton)
	{
		// Scene Settings
		
		NSDictionary * tDictionary=[sceneSettings dictionaryRepresentation];
		
		[tDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *bKey,id bObject, BOOL * bOutStop){
			[tDefaults setObject:bObject forKey:bKey];
		}];
		
		// Main Screen Only
		
		_mainScreenSetting=([mainScreenCheckBox state]==NSOnState);
		
		[tDefaults setBool:_mainScreenSetting forKey:RSSUserDefaultsMainDisplayOnly];
		
		[tDefaults synchronize];
	}
	else
	{
		sceneSettings=[[[self settingsClass] alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]];
		
		_mainScreenSetting=[tDefaults boolForKey:RSSUserDefaultsMainDisplayOnly];
	}
	
	[NSApp endSheet:self.window];
}

#pragma mark -

- (void)window:(NSWindow *)inWindow modifierFlagsDidChange:(NSEventModifierFlags) inModifierFlags
{
	NSRect tOriginalFrame=[self->cancelButton frame];
	
	if ((inModifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask)
	{
		[self->cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"Reset",@"Localizable",[NSBundle bundleForClass:[self class]],@"")];
		[self->cancelButton setAction:@selector(resetDialogSettings:)];
	}
	else
	{
		[self->cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel",@"Localizable",[NSBundle bundleForClass:[self class]],@"")];
		[self->cancelButton setAction:@selector(closeDialog:)];
	}
	
	[self->cancelButton sizeToFit];
	
	NSRect tFrame=[self->cancelButton frame];
	
	if (NSWidth(tFrame)<84.0)
		tFrame.size.width=84.0;
	
	tFrame.origin.x=NSMaxX(tOriginalFrame)-NSWidth(tFrame);
	
	[self->cancelButton setFrame:tFrame];
}

@end
