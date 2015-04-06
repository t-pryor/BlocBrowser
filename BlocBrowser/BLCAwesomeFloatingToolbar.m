//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Tim on 2015-03-31.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

/* IMPLEMENTATION
 
 Will need to:
 -save the four titles
 -create four labels
 -align them in a 2x2 grid
 -if the delegate is set and it has implemented the optional method, call it when the user taps 
  any button
 -respond to any requests to enable or disable buttons
 
 */

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, unsafe_unretained) CGFloat currentScale;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end


#import "BLCAwesomeFloatingToolbar.h"

@implementation BLCAwesomeFloatingToolbar


int count = 0;

- (instancetype) initWithFourTitles:(NSArray *)titles
{
  self = [super init];
  
  if (self) {
    self.currentTitles = titles;
    self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                    [UIColor colorWithRed:240/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                    [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                    [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
  
    NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
    
    //Make the 4 labels
    for (NSString *currentTitle in self.currentTitles) {
      UILabel *label = [[UILabel alloc] init];
      // property that indicates whether a UIView receives touch events
      label.userInteractionEnabled = NO;
      // alpha represents the view's opacity between 0 (transparent) and 1 (opaque)
      label.alpha = 0.25;
      
      NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
      NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
      UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
      
      // represents a horizontal text alignment
      label.textAlignment = NSTextAlignmentCenter;
      // UIFont represents a font and its associated info; systemFontOfSize: returns the default system font in a given size
      label.font = [UIFont systemFontOfSize:10];
      label.text = titleForThisLabel;
      label.backgroundColor = colorForThisLabel;
      label.textColor = [UIColor whiteColor];
      
      [labelsArray addObject:label];
    }
    
    self.labels = labelsArray;
    
    for (UILabel *thisLabel in self.labels) {
      [self addSubview:thisLabel];
    }
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    [self addGestureRecognizer:self.tapGesture];
    
    // As a subview, BLCAFT shouldn't be trusted to move around in its superview
    // ->bad design practice
    // Changes made by objects should only affect themselves and the objects they own
    // If the toolbar moved itself around, it might collide with other objects it doesn't know about
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];

    self.userInteractionEnabled = YES;
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinches:)];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleLongPressGestures:)];
    
    
    self.longPressGestureRecognizer.numberOfTouchesRequired = 1;
    
    self.longPressGestureRecognizer.allowableMovement = 20;
    
    self.longPressGestureRecognizer.minimumPressDuration = 1.0;
    
    [self addGestureRecognizer:self.longPressGestureRecognizer];
  }
  
  return self;
}

- (void) layoutSubviews
{
  // set the frames for the 4 labels
  for (UILabel *thisLabel in self.labels) {
    NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
    
    CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
    CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    // adjust labelX and labelY for each label
    if (currentLabelIndex <2) {
      // 0 or 1, so on top
      labelY = 0;
    } else {
      // 2 or 3, so on bottom
      labelY = CGRectGetHeight(self.bounds) / 2;
    }
    
    if (currentLabelIndex % 2 == 0) {
      // 0 or 2, so on the left
      labelX = 0;
    } else {
      // 1 or 3, so on the right
      labelX = CGRectGetWidth(self.bounds) / 2;
    }
    
    thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    
  }
}

#pragma mark - Touch Handling

// get the label for the button currently being touched

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:self];
  UIView *subview = [self hitTest:location withEvent:event];
  // we know that all our subviews are UILabels so we can safely inform the compiler
  // without the cast, compiler would warn us: Incompatible pointer types returning 'UIView'
  // from a function with result type 'UILabel'
  
  //$ Ask Steve
  if ([subview isMemberOfClass:[UILabel class]]) {
    return (UILabel *)subview;
  } else {
    return nil;
  }
  
}

- (void) tapFired:(UITapGestureRecognizer *)recognizer
{
  // check for the proper state
  // a gesture recognizezer has several states it can be in and UIGestureRecognizerStateRecognized
  // is the state it which the type of gesture it recognizes has been detected
  if (recognizer.state == UIGestureRecognizerStateRecognized) {
    // this gives us an x-y coordinate where the gesture occured with respect to our bounds
    // (a tap detected in the top-left corner of the toolbar will register as (0,0)
    CGPoint location = [recognizer locationInView:self];
    // invoke hitTest:withEvent: to discover which view received the tap at that location
    UIView *tappedView = [self hitTest:location withEvent:nil];
    
    // check if the view that was tapped was one of our toolbar labels
    // if so, verify our delegate for compatibility before performing appropriate method call
    if ([self.labels containsObject:tappedView]) {
      if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
      }
    }
  }
}

// we no longer care where the gesture occurred
// what's important now is which direction it travelled in
// A pan gesture recognizer's translation is how far the user's finger has moved in each direction
//  since the touch event began
// This method is called often during a pan gesture because a "full" pan as we perceive it is
// actually a linear collection of small pans travelling a few pixels at a time
- (void) panFired:(UIPanGestureRecognizer *)recognizer
{
//  if (recognizer.state == UIGestureRecognizerStateChanged) {
//    
//    CGPoint translation = [recognizer translationInView:self];
//    
//    NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
//    
//    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
//      [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
//    }
//    // reset this translation to zero such that we are able to get the difference of each mini-pan
//    // every time the method is called
//    [recognizer setTranslation:CGPointZero inView:self];
//  }

// BOOK
  if (recognizer.state != UIGestureRecognizerStateEnded &&
      recognizer.state != UIGestureRecognizerStateFailed) {
    CGPoint location = [recognizer
                        locationInView:recognizer.view.superview];
    recognizer.view.center = location;
    
  }

}

- (void) handlePinches:(UIPinchGestureRecognizer *)paramSender {
  NSLog(@"IN HANDLE PINCHES");
  if (paramSender.state == UIGestureRecognizerStateEnded) {
    self.currentScale = paramSender.scale;
  } else if (paramSender.state == UIGestureRecognizerStateBegan &&
             self.currentScale != 0.0f) {
    paramSender.scale = self.currentScale;
  }
  
  if (paramSender.scale != NAN &&
      paramSender.scale != 0.0) {
    paramSender.view.transform =
    CGAffineTransformMakeScale(paramSender.scale, paramSender.scale);
  }
}

- (void) handleLongPressGestures: (UILongPressGestureRecognizer *)paramSender
{
  // $ Ask Steve: why every long press has goes through two times?
  NSLog(@"COUNT   %i", count);
  
  NSLog(@"*********    handleLongPress   ************");
  
  UIColor *firstColor = [[UIColor alloc] init];
  firstColor = [self.labels[0] backgroundColor];
                                    
  
  for (int i = 0; i < self.labels.count; i++) {
    if (i == self.labels.count - 1) {
      [self.labels[i] setBackgroundColor:firstColor];
    } else {
      [self.labels[i] setBackgroundColor:[self.labels[i + 1] backgroundColor]];
    }
  }
  count++;

  
  
  
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
  NSUInteger index = [self.currentTitles indexOfObject:title];
  
  if (index != NSNotFound) {
    UILabel *label = [self.labels objectAtIndex:index];
    label.userInteractionEnabled = enabled;
    label.alpha = enabled ? 1.0 : 0.25;
  }
}


@end
