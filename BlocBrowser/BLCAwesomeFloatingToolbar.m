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

@end



#import "BLCAwesomeFloatingToolbar.h"

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles
{
  self = [super init];
  
  if (self) {
    self.currentTitles = titles;
    self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                    [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
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

// when a touch begins, dim the label to make it look highlighted
// also keep track of which label was most recently touched:
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UILabel *label = [self labelFromTouches:touches withEvent:event];
  
  self.currentLabel = label;
  self.currentLabel.alpha = 0.5;
}

// when a touch moves, we check if the user is still touching the label
// if the user drags off the label, we'll reset the alpha
// If they drag back on, we'll dim it again

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UILabel *label = [self labelFromTouches:touches withEvent:event];
  
  if (self.currentLabel != label) {
    // The label being touched is no longer the initial label
    self.currentLabel.alpha = 1;
  } else {
    // The label being touched is the initial label
    self.currentLabel.alpha = 0.5;
  }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UILabel *label = [self labelFromTouches:touches withEvent:event];
  
  if (self.currentLabel == label) {
    NSLog(@"Label tapped: %@", self.currentLabel.text);
    
    //REQUIRED for optional protocol methods: check if the delegate has implemented the method
    // app will crash if you try to call a method without checking first
    // if no delegate has been set, self.delegate is nil, nothing will happen
    // ObjC, no one can hear your method invocations on a nil object
    // Other langs: similar behavior could cause a crash
    
    //$Ask Steve-slide 2
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
      [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
    }
  }
  
  self.currentLabel.alpha = 1;
  self.currentLabel = nil;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *) event
{
  self.currentLabel.alpha = 1;
  self.currentLabel = nil;
}

#pragma mark - Button Enabling

// try to find the index of the button using title
// if we find an index, use it to get the corresponding UILabel
// set the userInteractionEnabled and alpha properties depending on the value for enabled that was passed in

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
  NSUInteger index = [self.currentTitles indexOfObject:title];
  
  if (index != NSNotFound) {
    UILabel *label = [self.labels objectAtIndex:index];
    label.userInteractionEnabled = enabled;
    label.alpha = enabled ? 1.0 : 0.25;
  }
}



@end
