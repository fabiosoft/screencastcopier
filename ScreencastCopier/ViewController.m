//
//  ViewController.m
//  ScreencastCopier
//
//  Created by Fabio Nisci on 08/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];


	//register for cmd+v
	[[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSCommandKeyMask task:^(NSEvent *event) {
		
		//invoke cmd+v for real
		[self keyPress:kVK_ANSI_V includingCommandKey:YES];
	}];
	
}

//cmd-v for real
-(void)keyPress:(CGKeyCode)keycode includingCommandKey:(BOOL) includeCommandkey{
	//context
	CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
	//key down
	CGEventRef keyCommandDown = CGEventCreateKeyboardEvent(source, keycode, YES);
	if(includeCommandkey){
		//include "cmd" key
		CGEventSetFlags(keyCommandDown, kCGEventFlagMaskCommand);
	}
	//key up
	CGEventRef keyCommandUp = CGEventCreateKeyboardEvent(source, keycode, NO);
	
	//push and release key
	CGEventPost(kCGAnnotatedSessionEventTap, keyCommandDown);
	CGEventPost(kCGAnnotatedSessionEventTap, keyCommandUp);
	
	//free up
	CFRelease(keyCommandUp);
	CFRelease(keyCommandDown);
	CFRelease(source);
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	
	// Update the view, if already loaded.
}

- (IBAction)copy:(id)sender {
	
	BOOL success = [pasteboard setString:_textField.stringValue forType:NSPasteboardTypeString];
	if(success){
		NSLog(@"copied = %@", _textField.stringValue);
	}else{
		NSLog(@"not successfully copied");
	}
}

- (IBAction)paste:(id)sender {
	NSLog(@"pasted: %@",[pasteboard stringForType:NSPasteboardTypeString]);
}

@end
