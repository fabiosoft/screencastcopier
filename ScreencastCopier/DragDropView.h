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

@property (nonatomic, assign) id<DragDropViewDelegate>  delegate;
@property (strong) NSMutableArray *draggedFilenames;

@end

@protocol DragDropViewDelegate <NSObject>
@optional
-(void)dragOperationisOver:(DragDropView *)dropView;
@end


