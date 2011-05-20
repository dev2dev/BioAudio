//
//  GraphView.m
//  BioAudio
//
//  Created by Brennon Bortz on 19/05/2011.
//  Copyright 2011 Queen's University Belfast. All rights reserved.
//

#import "GraphView.h"


@implementation GraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //Get the CGContext from this view
	CGContextRef context = UIGraphicsGetCurrentContext();
	//Set the stroke (pen) color
	CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	//Set the width of the pen mark
	CGContextSetLineWidth(context, 5.0);
    
	// Draw a line
	//Start at this point
	CGContextMoveToPoint(context, 10.0, 30.0);
    
	//Give instructions to the CGContext
	//(move "pen" around the screen)
	CGContextAddLineToPoint(context, 310.0, 30.0);
	CGContextAddLineToPoint(context, 310.0, 90.0);
	CGContextAddLineToPoint(context, 10.0, 90.0);
    
	//Draw it
	CGContextStrokePath(context);
    
	//Draw a rectangle
	CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
	//Define a rectangle
	CGContextAddRect(context, CGRectMake(10.0, 150.0, 60.0, 120.0));
	//Draw it
	CGContextFillPath(context);
}

- (void)dealloc
{
    [super dealloc];
}

@end
