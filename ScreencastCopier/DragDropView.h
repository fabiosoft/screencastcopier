//
//  DragDropView.h
//  ScreencastCopier
//
//  Created by Fabio Nisci on 09/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@protocol DragDropViewDelegate;


@interface DragDropView : NSView{
	BOOL highlight;
}

- (id)initWithFrame:(NSRect)frame withAllowedFileTypes:(NSArray *)fileTypes;

@property (nonatomic, assign) id<DragDropViewDelegate>  delegate;
@property (strong) NSMutableArray *draggedFilenames;
@property (strong) NSMutableArray *allowedFiletypes; //file extensions allowed to drop (default: txt)

@end

@protocol DragDropViewDelegate <NSObject>
@optional
-(void)dragOperationisOver:(DragDropView *)dropView;
@end


