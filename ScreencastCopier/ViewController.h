//
//  ViewController.h
//  ScreencastCopier
//
//  Created by Fabio Nisci on 08/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "DDHotKeyCenter.h"
#import "DDHotKeyUtilities.h"
#import "DDHotKeyTextField.h"



//#import "MASShortcut/MASShortcutView.h"
//#import "MASShortcut/MASShortcutView+UserDefaults.h"
//#import "MASShortcut/MASShortcut+UserDefaults.h"
//#import "MASShortcut/MASShortcut+Monitoring.h"


@interface ViewController : NSViewController{
	NSPasteboard *pasteboard;

}

@property (strong) IBOutlet NSTextField *textField;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@end

