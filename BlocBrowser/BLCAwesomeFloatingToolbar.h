//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Tim on 2015-03-31.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

/*
 This interface communicates four things to relevant classes:
 1. It should be initialized with four titles using the custom initializer, initWithFourTitles:
 2. It also implements a delegate protocol, so classes can optionally be informed when one of the titles is pressed.
 3. It allows other classes to enable and disable its buttons.
 4. It is a UIView subclass, which will let us add it to another view, set its frame, etc.
 
 
 */


#import <UIKit/UIKit.h>

// We're about to declare a delegate protocol, which references a class not defined yet
// because protocol definition is before the @interface
// We include this line as a promise to the compiler that it will learn what a BLCAwesomefloatingToolbar is later
@class BLCAwesomeFloatingToolbar;

// indicates that the definition of this delegate is beginning
// The <NSObject> indicates that this protocol inherits from the NSObject protocol
@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>

@optional

// one optional delegate method is declared.
// If the delegate implements it, it will be called when a user taps a button
- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface BLCAwesomeFloatingToolbar : UIView

// custom initializer, takes an array of four titles
- (instancetype) initWithFourTitles:(NSArray *)titles;

// a method that enables or disables a button based on the title passed in
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString*) title;

// a delegate property to use if a delegate is desired
@property (nonatomic, weak) id <BLCAwesomeFloatingToolbarDelegate> delegate;

@end
