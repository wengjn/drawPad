#import "SmoothLine.h"

@implementation SmoothLine

@synthesize pickedImage,screenImage,arrayStrokes,arrayAbandonedStrokes,currentColor,currentSize;


-(BOOL)isMultipleTouchEnabled {
	return NO;
}

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
    }
    
    return  self;
}

-(void) viewJustLoaded {
	NSLog(@"viewJustLoaded");
	
	// color picker and popover
//	colorPC = [[ColorPickerController alloc] init];
//	colorPC.pickedColorDelegate = self;
//	colorPopoverController = [[UIPopoverController alloc] initWithContentViewController:colorPC];
//	[colorPopoverController setPopoverContentSize:colorPC.view.frame.size];
	
	// share view controller and popover
//	shareVC = [[ShareViewController alloc] init];
//	shareVC.delegate = self;
//	sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:shareVC];
//	[sharePopoverController setPopoverContentSize:shareVC.view.frame.size];
	
	// image picker and popover
//    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"image1.jpg"]]];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		imagePC = [[UIImagePickerController alloc] init];
		imagePC.delegate = self;
		imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePC];
		//[imagePopoverController setPopoverContentSize:imagePC.view.frame.size];
	}
	
	self.arrayStrokes = [NSMutableArray array];
	self.arrayAbandonedStrokes = [NSMutableArray array];
	self.currentSize = 5.0;
//	self.labelSize.text = @"Size: 5";
	[self setColor:[UIColor redColor]];
//	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//	activityIndicator.center = CGPointMake(512, 384);
	
//	facebook = [[Facebook alloc] init];
//	permissions =  [[NSArray arrayWithObjects: 
//                     @"read_stream", @"offline_access",nil] retain];
//	isLoggedIn = NO;
	//shareVC.buttonLog.titleLabel.text = @"Facebook Log In";
//	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateNormal];
//	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateHighlighted | UIControlStateSelected];
//	shareVC.buttonUpload.enabled = NO;
//	shareVC.buttonUpload.hidden = YES;
}

-(void) setColor:(UIColor*)theColor {
//	self.buttonColor.backgroundColor = theColor;
	self.currentColor = theColor;
}


// Start new dictionary for each touch, with points and color
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
	NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
	[dictStroke setObject:arrayPointsInStroke forKey:@"points"];
	[dictStroke setObject:self.currentColor forKey:@"color"];
	[dictStroke setObject:[NSNumber numberWithFloat:self.currentSize] forKey:@"size"];
	
	CGPoint point = [[touches anyObject] locationInView:self];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	
	[self.arrayStrokes addObject:dictStroke];
}

// Add each point to points array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
	NSMutableArray *arrayPointsInStroke = [[self.arrayStrokes lastObject] objectForKey:@"points"];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	
	CGRect rectToRedraw = CGRectMake(\
									 ((prevPoint.x>point.x)?point.x:prevPoint.x)-currentSize,\
									 ((prevPoint.y>point.y)?point.y:prevPoint.y)-currentSize,\
									 fabs(point.x-prevPoint.x)+2*currentSize,\
									 fabs(point.y-prevPoint.y)+2*currentSize\
									 );
	[self setNeedsDisplayInRect:rectToRedraw];
	//[self setNeedsDisplay];
}


// Send over new trace when the touch ends
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
	[self.arrayAbandonedStrokes removeAllObjects];
}




// Draw all points, foreign and domestic, to the screen
- (void) drawRect: (CGRect) rect
{	
	int width = self.pickedImage.size.width;
	int height = self.pickedImage.size.height;
	CGRect rectForImage = CGRectMake(512-width/2, 384-height/2, width, height);
	[self.pickedImage drawInRect:rectForImage];
	
	if (self.arrayStrokes)
	{
		int arraynum = 0;
		// each iteration draw a stroke
		// line segments within a single stroke (path) has the same color and line width
		for (NSDictionary *dictStroke in self.arrayStrokes)
		{
			NSArray *arrayPointsInstroke = [dictStroke objectForKey:@"points"];
			UIColor *color = [dictStroke objectForKey:@"color"];
			float size = [[dictStroke objectForKey:@"size"] floatValue];
			[color set];		// equivalent to both setFill and setStroke
			
            //			// won't draw a line which is too short
            //			if (arrayPointsInstroke.count < 3)	{
            //				arraynum++; 
            //				continue;		// if continue is executed, the program jumps to the next dictStroke
            //			}
			
			// draw the stroke, line by line, with rounded joints
			UIBezierPath* pathLines = [UIBezierPath bezierPath];
			CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
			[pathLines moveToPoint:pointStart];
			for (int i = 0; i < (arrayPointsInstroke.count - 1); i++)
			{
				CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
				[pathLines addLineToPoint:pointNext];
			}
			pathLines.lineWidth = size;
			pathLines.lineJoinStyle = kCGLineJoinRound;
			pathLines.lineCapStyle = kCGLineCapRound;
			[pathLines stroke];
			
			arraynum++;
		}
	}
}

-(void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	self.pickedImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
	
	[imagePopoverController dismissPopoverAnimated:YES];
	
	[self setNeedsDisplay];
}


-(void)undo {
	if ([arrayStrokes count]>0) {
		NSMutableDictionary* dictAbandonedStroke = [arrayStrokes lastObject];
		[self.arrayAbandonedStrokes addObject:dictAbandonedStroke];
		[self.arrayStrokes removeLastObject];
		[self setNeedsDisplay];
	}
}


-(void)redo {
	if ([arrayAbandonedStrokes count]>0) {
		NSMutableDictionary* dictReusedStroke = [arrayAbandonedStrokes lastObject];
		[self.arrayStrokes addObject:dictReusedStroke];
		[self.arrayAbandonedStrokes removeLastObject];
		[self setNeedsDisplay];
	}
}

-(void)clearCanvas {
	self.pickedImage = nil;
	[self.arrayStrokes removeAllObjects];
	[self.arrayAbandonedStrokes removeAllObjects];
	[self setNeedsDisplay];
}


-(void)dealloc {
	[pickedImage release];
	[screenImage release];
	[arrayStrokes release];
	[arrayAbandonedStrokes release];
	[currentColor release];
//	[sliderSize release];
//	[buttonColor release];
//	[toolBar release];
//	[labelSize release];
//	[colorPC release];
//	[colorPopoverController release];
//	[shareVC release];
//	[sharePopoverController release];
//	[imagePC release];
//	[imagePopoverController release];
//	[activityIndicator release];
//	[facebook release];
//	[permissions release];
	[super dealloc];
}


@end
